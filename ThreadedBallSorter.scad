// Basic parameters
$fn = 100;  // Smoothness of circles

// Configuration
hole_sizes = [
    2.38, 3.18, 3.97, 4.76, 5.56, 6.35, 7.14, 7.94, 8.73, 9.53, 10.32
];

// // Configuration
// hole_sizes = [
//     8.73, 9.53, 10.32
// ];

// Segment parameters
wall_thickness = 2;
min_segment_height = 15;    // Minimum height (for bottom segment)
max_segment_height = 40;    // Maximum height (for top segment)
diameter_step = 15;         // Changed from 6 to 12 for faster narrowing
height_step = 2;          // How much to decrease height per level
cone_taper = 10;         // How much wider the top diameter is
initial_diameter = 30;

// Added parameters for interlocking
lip_height = 3;        // Height of interlocking lip
lip_tolerance = .4;   // Tolerance for press fit
press_fit_reduction = 1.0;  // How much narrower the bottom is than the lip

// New parameters for printability
flat_cut_depth = 0.8;     // Reduce cut depth to be closer to cup edge
wall_clearance = 0.4;     // Clearance between walls of nested cups
slot_width = 0;       // Width of ball removal slots
slot_height = 0;      // Height of ball removal slots
break_support_thickness = 0.8;  // Thickness of breakaway supports
support_count = 3;       // Number of breakaway supports between segments

// Add parameters for hole pattern
hex_spacing_factor = 2.2;  // Spacing between holes as multiple of hole size
depression_size_factor = 1.1;  // Depression diameter as multiple of hole size
depression_depth = 1;      // Depth of depression around holes

// Add nesting parameters
nesting_clearance = 0.4;  // Clearance between nested segments
wall_angle = 5;          // Angle of walls to ensure clean separation

// Add parameter for vertical clearance
floor_clearance = 0.4;  // Clearance between floor and next cup

// Add new parameter for wall separation
wall_separation = 4;  // Increased from 2 to 4mm for better printing clearance

// Function to calculate bottom diameter for each level (widest at bottom)
function get_bottom_diameter(level) = 
    initial_diameter + ((len(hole_sizes)-1-level) * diameter_step);  // Increased base diameter from 80 to 100

// Function to calculate top diameter (conical shape)
function get_top_diameter(level) =
    get_bottom_diameter(level) + cone_taper;

// Function to calculate actual bottom diameter (for press fit)
function get_actual_bottom_diameter(level) =
    get_bottom_diameter(level) - press_fit_reduction;

// Function to calculate height for each level (thickest at top)
function get_height(level) =
    min_segment_height + (level * ((max_segment_height - min_segment_height) / (len(hole_sizes)-1)));

// Function to calculate number of holes that fit in a row
function get_hex_row_count(diameter, hole_size) =
    floor(diameter / (hole_size * hex_spacing_factor));

// Module for the circular (semicircular) part of a segment
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
        // Main body
        intersection() {
            cylinder(h=height, 
                    d1=actual_bottom_diameter,
                    d2=actual_top_diameter);
            
            // Cut to make semicircle
            translate([-actual_top_diameter/2, -actual_top_diameter/2, -1])
                cube([actual_top_diameter/2, actual_top_diameter, height + 2]);
        }
        
        // Hollow out inside
        translate([0, 0, wall_thickness])
            intersection() {
                cylinder(h=height+1, 
                        d1=actual_bottom_diameter-wall_thickness*2,
                        d2=actual_top_diameter-wall_thickness*2);
                translate([-actual_top_diameter/2, -actual_top_diameter/2, -1])
                    cube([actual_top_diameter/2, actual_top_diameter, height + 2]);
            }
            
        // Add holes (only in semicircular part)
        create_hole_pattern(actual_bottom_diameter, hole_size, wall_thickness);
    }
}

// Module for the rectangular part of a segment
module segment_rect_half(
    top_diameter,
    bottom_diameter,    
    height,       
    level = 0
) {
    actual_top_diameter = top_diameter - (level * nesting_clearance * 2);
    actual_bottom_diameter = bottom_diameter - (level * nesting_clearance * 2);
    
    // Calculate base extension and add progressive separation
    base_extension = wall_thickness * 3;  // Keep minimum extension
    progressive_separation = level * wall_separation;
    extension_length = base_extension + progressive_separation;
    
    difference() {
        // Solid rectangular part - extension increases with size
        translate([0, -actual_top_diameter/2, 0])
            cube([extension_length,
                  actual_top_diameter, 
                  height]);
        
        // Hollow out inside - adjusted for variable length
        translate([0,
                  -actual_top_diameter/2 + wall_thickness, 
                  wall_thickness])
            cube([extension_length - wall_thickness,
                  actual_top_diameter - wall_thickness*2, 
                  height + 1]);
    }
}

// Module for complete segment combining both halves
module complete_segment(
    top_diameter,
    bottom_diameter,    
    height,       
    hole_size,         
    is_lower = false,
    level = 0
) {
    union() {
        // Semicircular half
        segment_circle_half(
            top_diameter = top_diameter,
            bottom_diameter = bottom_diameter,
            height = height,
            hole_size = hole_size,
            is_lower = is_lower,
            level = level
        );
        
        // Rectangular half
        segment_rect_half(
            top_diameter = top_diameter,
            bottom_diameter = bottom_diameter,
            height = height,
            level = level
        );
    }
}

// Add this module for creating the hexagonal hole pattern
module create_hole_pattern(diameter, hole_size, floor_thickness) {
    effective_diameter = diameter - wall_thickness * 2;
    row_count = get_hex_row_count(effective_diameter, hole_size);
    hex_spacing = hole_size * hex_spacing_factor;
    
    // Create hexagonal pattern of holes with depressions
    for(row = [-row_count:row_count]) {
        for(col = [-row_count:row_count]) {
            // Calculate hex grid position
            x = col * hex_spacing + (row % 2) * (hex_spacing/2);
            y = row * hex_spacing * sqrt(3)/2;
            
            // Check if position is within the semicircle
            if(sqrt(x*x + y*y) <= effective_diameter/2 && x <= 0) {  // x <= 0 ensures holes only in semicircle
                translate([x, y, 0]) {
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

// Render all segments
for (i = [0:len(hole_sizes)-1]) {
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