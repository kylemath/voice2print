include <threads.scad>

// Basic parameters
$fn = 100;  // Smoothness of circles

// Thread parameters
thread_pitch = 3;           // Thread pitch in mm
thread_height = 5;          // Height of threaded section
thread_tolerance = 0.4;     // Clearance between threads
thread_angle = 60;         // Standard thread angle (not wall angle)
helix_angle = 20;          // 90° - 70° = 20° helix angle

// Configuration for ball sizes
hole_sizes = [
    2.38, 3.18, 3.97, 4.76, 5.56, 6.35, 7.14, 7.94, 8.73, 9.53, 10.32
];

// Segment parameters
wall_thickness = 1.5;
min_segment_height = 15;    // Minimum height (for bottom segment)
max_segment_height = 20;    // Maximum height (for top segment)
diameter_step = 5;         // How much diameter changes per level
initial_diameter = 20;      // Starting diameter
cone_taper = 6;           // Reduced taper to minimize wall contact

// Nesting parameters
nesting_clearance = 0;    // Increased clearance between nested segments
floor_clearance = 2;      // Vertical clearance between segments
lip_height = 0;           // Height of the interlocking lip

// Hole pattern parameters
hex_spacing_factor = 2.2;   // Spacing between holes as multiple of hole size
depression_size_factor = 1.1;  // Depression diameter as multiple of hole size
depression_depth = 1;       // Depth of depression around holes

// Function to calculate diameters
function get_base_diameter(level) = 
    initial_diameter + ((len(hole_sizes)-1-level) * diameter_step);

function get_top_diameter(level) =
    get_base_diameter(level-1) + (wall_thickness * 4) + (nesting_clearance * 2);

// Function to calculate height for each level
function get_height(level) =
    min_segment_height + (level * ((max_segment_height - min_segment_height) / (len(hole_sizes)-1)));

// Function to calculate number of holes that fit in a row
function get_hex_row_count(diameter, hole_size) =
    floor(diameter / (hole_size * hex_spacing_factor));

// Module for creating hexagonal hole pattern
module create_hole_pattern(diameter, hole_size, floor_thickness, is_rectangular = false) {
    wall_safety_margin = wall_thickness + hole_size;  // Increased safety margin from walls
    effective_diameter = diameter - (wall_safety_margin * 2);  // Reduce usable area by safety margin
    row_count = get_hex_row_count(effective_diameter, hole_size);
    hex_spacing = hole_size * hex_spacing_factor;
    
    for(row = [-row_count:row_count]) {
        for(col = [-row_count:row_count]) {
            x = col * hex_spacing + (row % 2) * (hex_spacing/2);
            y = row * hex_spacing * sqrt(3)/2;
            
            if(sqrt(x*x + y*y) <= effective_diameter/2) {  // Check against reduced diameter
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
    
    // Calculate thread pitch based on diameter and helix angle
    local_pitch = tan(helix_angle) * PI * ((actual_top_diameter + actual_bottom_diameter)/4);
    mid_diameter_outer = (actual_top_diameter - actual_bottom_diameter) * (thread_height/height) + actual_bottom_diameter + wall_thickness*1;
    mid_diameter_inner = actual_top_diameter - (actual_top_diameter - actual_bottom_diameter) * (thread_height/height) - wall_thickness*1;
    
    difference() {
        // Internal threads at top using tapered hole
        TaperedScrewHole(
            outer_diam_top = mid_diameter_outer ,
            outer_diam_bottom = actual_bottom_diameter,
            height = height,
            pitch = 1.411,
            tooth_angle = 60,
            position=[0,0,0]
        ) { 

                //     // Main body
                    TaperedScrewMale(
                        outer_diam_top = 
                            mid_diameter_outer,
                        outer_diam_bottom = 
                            actual_bottom_diameter + 
                            wall_thickness * 1,                        
                        height = thread_height,
                        pitch = 1.811,
                        tooth_angle = 50
                    ) { 
                        cylinder(h=height, 
                                d1=actual_bottom_diameter,
                                d2=actual_top_diameter);
                    };
              

        }


        // create_hole_pattern(actual_bottom_diameter, hole_size, wall_thickness);
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
    segment_circle_half(
        top_diameter = top_diameter,
        bottom_diameter = bottom_diameter,
        height = height,
        hole_size = hole_size,
        is_lower = is_lower,
        level = level
    );
        
}

// Render all segments
for (i = [9:len(hole_sizes)-1]) {
    // z_lift = (len(hole_sizes)-1-i) * (wall_thickness + floor_clearance);
    z_lift = (len(hole_sizes)-1-i) * (-get_height(i)-1);

    translate([0, 0, z_lift])
        complete_segment(
            top_diameter = get_top_diameter(len(hole_sizes)-1-i)+2*wall_thickness,
            bottom_diameter = get_top_diameter(len(hole_sizes)-1-i+1)-3*wall_thickness,
            height = get_height(i),
            hole_size = hole_sizes[i],
            is_lower = (i < len(hole_sizes)-1),
            level = i
        );
} 