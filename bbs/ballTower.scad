include <threads.scad>

// Basic parameters - Use lower $fn for preview, higher for final STL
$fn = $preview ? 16 : 32;  // 32 for preview, 100 for final render

// Configuration for ball sizes
hole_sizes = [
    1, 2.38, 3.18, 3.97, 4.76, 5.56, 6.35, 7.14, 7.94, 8.73, 9.53, 10.32
];

// Segment parameters
wall_thickness = 1;
min_segment_height = 15;    // Minimum height (for bottom segment)
max_segment_height = 20;    // Maximum height (for top segment)
diameter_step = 6.6;         // How much diameter changes per level
initial_diameter = 25;      // Starting diameter

// Hole pattern parameters
hex_spacing_factor = 1.8;   // Spacing between holes as multiple of hole size
depression_size_factor = 1.1;  // Depression diameter as multiple of hole size
depression_depth = 1.5;       // Depth of depression around holes

// Function to calculate diameters
function get_base_diameter(level) = 
    initial_diameter + ((len(hole_sizes)-1-level) * diameter_step);

function get_top_diameter(level) =
    get_base_diameter(level-1) + (wall_thickness * 4) ;

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
                    translate([0, 0, floor_thickness])
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
    level = 0,
    next_bottom_diameter = 0  // Added parameter for next cup's bottom diameter
) {
    actual_top_diameter = top_diameter;
    actual_bottom_diameter = bottom_diameter;
    
    // Main body
    TaperedScrewHole(
        // Use next cup's bottom diameter for inner thread if available,
        // otherwise use this cup's dimensions
        outer_diam_top = next_bottom_diameter > 0 ? 
            next_bottom_diameter + wall_thickness*3 : 
            actual_bottom_diameter + wall_thickness*3,
        outer_diam_bottom = next_bottom_diameter > 0 ? 
            next_bottom_diameter + wall_thickness*1 : 
            actual_bottom_diameter + wall_thickness*1,
        height = 4,
        pitch = 1.411,
        tooth_angle = 60,
        position=[0,0,height-4]
    ) { 
        difference() {
            difference() {
                TaperedScrewMale(
                    outer_diam_top = actual_bottom_diameter -1.5 + wall_thickness * 3 ,
                    outer_diam_bottom = actual_bottom_diameter -1.5 + wall_thickness * 1,                        
                    height = 4,
                    pitch = 1.411,
                    tooth_angle = 60, 
                    position=[0,0,0]
                ) { 
                    cylinder(h=height, 
                                    d1=actual_bottom_diameter-2.1,
                                    d2=actual_top_diameter+2);

                };
                translate([0,0,1.8])
                    cylinder(h=height+2, d1=actual_bottom_diameter-6, d2= (level > 0) ?  next_bottom_diameter : actual_bottom_diameter+2);
            };
            if (level > 0) {
                create_hole_pattern(actual_bottom_diameter, hole_size, wall_thickness);
            }
        };
    }
     
}

// Module for complete segment
module complete_segment(
    top_diameter,
    bottom_diameter,    
    height,       
    hole_size,         
    is_lower = false,
    level,
    next_bottom_diameter = 0  // Added parameter
) {
    segment_circle_half(
        top_diameter = top_diameter,
        bottom_diameter = bottom_diameter,
        height = height,
        hole_size = hole_size,
        is_lower = is_lower,
        level = level,
        next_bottom_diameter = next_bottom_diameter
    );
        
}

// Module for lid that threads onto the largest cup
module lid_for_largest_cup() {
    // Calculate dimensions for the largest cup (i=0)
    largest_cup_level = 12;
    largest_cup_bottom_diameter = get_top_diameter(len(hole_sizes)-1-largest_cup_level+1)-3*wall_thickness;
    lid_height = 6; // Height of the lid including threads (4x thicker: was 2, now 8)
    lid_top_thickness = 0; // Thickness of the top plate
    
    // Create male threads that match what the largest cup expects
    TaperedScrewMale(
        outer_diam_top = largest_cup_bottom_diameter -2 + wall_thickness * 3,
        outer_diam_bottom = largest_cup_bottom_diameter -2 + wall_thickness * 1,                        
        height = 2,
        pitch = 1.411,
        tooth_angle = 60, 
        position=[0,0,0]
    ) { 
        difference() {
            // Lid body - flat top instead of tapered
            cylinder(h=lid_height, 
                    d1=largest_cup_bottom_diameter-2,
                    d2=largest_cup_bottom_diameter);
            
            // Create inset plus pattern for grip
            plus_width = 8;  // Width of each arm of the plus
            plus_length = (largest_cup_bottom_diameter-2) * .8;  // Length of plus arms
            plus_depth = 4;  // How deep the plus is inset
            
            // Horizontal bar of plus
            translate([0, 0, lid_height])
                cube([plus_length, plus_width, plus_depth + 0.1], center=true);
            
            // Vertical bar of plus
            translate([0, 0, lid_height])
                cube([plus_width, plus_length, plus_depth + 0.1], center=true);
        }
    }
}

// Render all segments with cross section
difference() {
    union() {
        for (i = [0:len(hole_sizes)-1]) { 
            // Calculate x offset based on the maximum diameter of each segment plus some spacing
            z_offset = i* -5.5* (wall_thickness);

            // Calculate the bottom diameter of the next cup up (if it exists)
            next_bottom_diameter = (i < len(hole_sizes)) ? (get_top_diameter(len(hole_sizes)-1-i)-5*wall_thickness) : 0;

            translate([0, 0, z_offset-20])
                complete_segment(
                    top_diameter = get_top_diameter(len(hole_sizes)-1-i),
                    bottom_diameter = get_top_diameter(len(hole_sizes)-1-i+1)-3*wall_thickness,
                    height = get_height(i),
                    hole_size = hole_sizes[i],
                    is_lower = (i < len(hole_sizes)-1),
                    level = i,
                    next_bottom_diameter = next_bottom_diameter
                );
        }
        
        // Add the lid positioned above the largest cup
        translate([0, 0, -max_segment_height - 68])
            lid_for_largest_cup();
    }
    // // Cut in half horizontally
    // translate([-500, 0, -500])
    //     cube([1000, 500, 1000]);
}