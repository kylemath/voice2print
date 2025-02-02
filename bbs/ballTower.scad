// Basic parameters
$fn = 100;  // Smoothness of circles

// Configuration for ball sizes
hole_sizes = [
    2.38, 3.18, 3.97, 4.76, 5.56, 6.35, 7.14, 7.94, 8.73, 9.53, 10.32
];

// Segment parameters
wall_thickness = 2;
min_segment_height = 15;    // Minimum height (for bottom segment)
max_segment_height = 40;    // Maximum height (for top segment)
diameter_step = 6.8;         // How much diameter changes per level
initial_diameter = 30;      // Starting diameter
cone_taper = 10;           // How much wider the top is than bottom

// Nesting parameters
nesting_clearance = 0.4;    // Clearance between nested segments
wall_separation = wall_thickness+.6;        // Separation between back walls
floor_clearance = 0.4;      // Vertical clearance between segments

// Hole pattern parameters
hex_spacing_factor = 2.2;   // Spacing between holes as multiple of hole size
depression_size_factor = 1.1;  // Depression diameter as multiple of hole size
depression_depth = 1;       // Depth of depression around holes

// Function to calculate diameters
function get_bottom_diameter(level) = 
    initial_diameter + ((len(hole_sizes)-1-level) * diameter_step);

function get_top_diameter(level) =
    get_bottom_diameter(level) + cone_taper;

// Function to calculate height for each level
function get_height(level) =
    min_segment_height + (level * ((max_segment_height - min_segment_height) / (len(hole_sizes)-1)));

// Function to calculate number of holes that fit in a row
function get_hex_row_count(diameter, hole_size) =
    floor(diameter / (hole_size * hex_spacing_factor));

// Module for creating hexagonal hole pattern
module create_hole_pattern(diameter, hole_size, floor_thickness, is_rectangular = false) {
    effective_diameter = diameter - wall_thickness * 2;
    row_count = get_hex_row_count(effective_diameter, hole_size);
    hex_spacing = hole_size * hex_spacing_factor;
    safety_margin = hole_size * 4;  // Increased safety margin to prevent balls from reaching wall
    
    for(row = [-row_count:row_count]) {
        for(col = [-row_count:row_count]) {
            x = col * hex_spacing + (row % 2) * (hex_spacing/2);
            y = row * hex_spacing * sqrt(3)/2;
            
            if(sqrt(x*x + y*y) <= effective_diameter/2 && 
               (is_rectangular ? 
                    (x >= 0 && x <= effective_diameter/4 - safety_margin) : // Reduced area for holes in rectangular section
                    x <= 0)) {
                translate([x, y, -.1]) {
                    // Depression around hole
                    translate([0, 0, floor_thickness - depression_depth])
                        cylinder(h=depression_depth + 0.1, 
                               d=hole_size * depression_size_factor);
                    
                    // Hole
                    cylinder(h=floor_thickness*2, d=hole_size);
                }
            }
        }
    }
}

// Module for semicircular part
module segment_circle_half(
    top_diameter,
    bottom_diameter,    
    height,       
    hole_size,         
    is_lower = false,
    level = 0
) {
    actual_top_diameter = top_diameter - (level * nesting_clearance * 2);
    actual_bottom_diameter = bottom_diameter - (level * nesting_clearance * 2);
    
    difference() {
        intersection() {
            cylinder(h=height, 
                    d1=actual_bottom_diameter,
                    d2=actual_top_diameter);
            
            translate([-actual_top_diameter/2, -actual_top_diameter/2, -1])
                cube([actual_top_diameter/2, actual_top_diameter, height + 2]);
        }
        
        translate([0, 0, wall_thickness])
            cylinder(h=height+1, 
                d1=actual_bottom_diameter-wall_thickness*2,
                d2=actual_top_diameter-wall_thickness*2);
            
        create_hole_pattern(actual_bottom_diameter, hole_size, wall_thickness);
    }
}

// Module for rectangular part
module segment_rect_half(
    top_diameter,
    bottom_diameter,    
    height,       
    level = 0,
    hole_size
) {
    actual_top_diameter = top_diameter - (level * nesting_clearance * 2);
    actual_bottom_diameter = bottom_diameter - (level * nesting_clearance * 2);
    
    base_extension = wall_thickness;
    progressive_separation = level * wall_separation;
    extension_length = base_extension + progressive_separation;
    
    difference() {
        union() {
            intersection() {
                difference() {
                    translate([0, -actual_top_diameter/2, 0])
                        cube([extension_length,
                              actual_top_diameter, 
                              height]);
                    
                    translate([-.2,
                              -actual_top_diameter/2 + wall_thickness, 
                              wall_thickness])
                        cube([extension_length - wall_thickness-.2,
                              actual_top_diameter - wall_thickness*2, 
                              height + 1]);
                }
                
                hull() {
                    translate([0, 0, 0])
                        scale([2, 1, 1])
                            cylinder(h=0.1, d=actual_bottom_diameter);
                    
                    translate([0, 0, height])
                        scale([2, 1, 1])
                            cylinder(h=0.1, d=actual_top_diameter);
                }
            }
            
            // Angled walls on both sides
            for(side = [-1, 1]) {
                intersection() {
                    difference() {
                        if (side == 1) {
                            hull() {
                                translate([0, side * actual_bottom_diameter/2-wall_thickness, 0])
                                    cube([extension_length, wall_thickness, 0.1]);
                                translate([0, side * actual_top_diameter/2-wall_thickness, height])
                                    cube([extension_length, wall_thickness, 0.1]);
                            }
                        } else {
                            hull() {
                                translate([0, side * actual_bottom_diameter/2, 0])
                                    cube([extension_length, wall_thickness, 0.1]);
                                translate([0, side * actual_top_diameter/2, height])
                                    cube([extension_length, wall_thickness, 0.1]);
                            }
                        }
                        
                
                    }
                    
                    hull() {
                        translate([0, 0, 0])
                            scale([2, 1, 1])
                                cylinder(h=0.1, d=actual_bottom_diameter + wall_thickness*2);
                        
                        translate([0, 0, height])
                            scale([2, 1, 1])
                                cylinder(h=0.1, d=actual_top_diameter + wall_thickness*2);
                    }
                }
            }
        }
        
        create_hole_pattern(actual_bottom_diameter, hole_size, wall_thickness, true);
    }
}

// Module for complete segment
module complete_segment(
    top_diameter,
    bottom_diameter,    
    height,       
    hole_size,         
    is_lower = false,
    level = 0
) {
    union() {
        segment_circle_half(
            top_diameter = top_diameter,
            bottom_diameter = bottom_diameter,
            height = height,
            hole_size = hole_size,
            is_lower = is_lower,
            level = level
        );
        
        segment_rect_half(
            top_diameter = top_diameter,
            bottom_diameter = bottom_diameter,
            height = height,
            level = level,
            hole_size = hole_size
        );
    }
}

// Render all segments
for (i = [0:len(hole_sizes)-9]) {
    z_lift = (len(hole_sizes)-1-i) * (wall_thickness + floor_clearance);
    
    translate([0, 0, z_lift])
        complete_segment(
            top_diameter = get_top_diameter(len(hole_sizes)-1-i),
            bottom_diameter = get_bottom_diameter(len(hole_sizes)-1-i),
            height = get_height(i),
            hole_size = hole_sizes[i],
            is_lower = (i < len(hole_sizes)-1),
            level = i
        );
} 