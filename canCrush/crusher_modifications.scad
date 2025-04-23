// Parameters for modifications
scale_factor = 1.0;  // Scale the entire model
x_offset = 0;        // Translation in X direction
y_offset = 0;        // Translation in Y direction
z_offset = 0;        // Translation in Z direction
rotation_x = 0;      // Rotation around X axis
rotation_y = 90;     // Reset rotation to 0 for proper alignment
rotation_z = 0;      // Rotation around Z axis

// Hole parameters
center_hole_diameter = 25.4 * 1.25;  // 1.25 inches in mm
hole_height = 50;                    // Make sure it's thick enough to cut through
head_height = 6;
m6_hole_diameter = 6.5;              // Slightly larger than 6mm for M6 screws
m6_head_diameter = 10;

// Pocket parameters
pocket_size = 50.5;                  // Square pocket size in mm
pocket_depth = 10;                   // Depth of the recessed pocket
inset = 25.4/4;                      // 1/4 inch inset from edges
hole_position = pocket_size/2 - inset; // Position of holes from center

// Import and transform the STL
module transformed_model() {
    translate([x_offset, y_offset, z_offset])
    rotate([rotation_x, rotation_y, rotation_z])
    scale([scale_factor, scale_factor, scale_factor])
    import("CrusherTop.stl");
}

// Module for creating through holes
module through_holes() {
    // Center hole
    translate([0, 0, 10])
    cylinder(h=hole_height, d=center_hole_diameter, center=true, $fn=64);
    
    // Four corner holes, inset from edges
    for(x = [-hole_position, hole_position]) {
        for(y = [-hole_position, hole_position]) {
            translate([x, y, 10])
            cylinder(h=hole_height, d=m6_hole_diameter, center=true, $fn=32);
            translate([x, y, 0])
            cylinder(h=head_height, d=m6_head_diameter, center=true, $fn=32);
        }
    }
}

// Module for creating the recessed pocket
module pocket() {
    translate([0, 0, 10 + hole_height/4])  // Position for proper recession
    linear_extrude(height=pocket_depth, center=true)
    square([pocket_size, pocket_size], center=true);
}

// Module to fill in the unwanted side holes
module fill_side_holes() {
    cube_size = 25;  // Make sure it's large enough to cover the holes
    cube_height = 19;
    
    // Fill left and right holes
    translate([-(pocket_size/2 + 18), -10, 9.5])
    cube([cube_size, cube_size, cube_height], center=true);
    
    translate([pocket_size/2 + 18, 10, 9.5])
    cube([cube_size, cube_size, cube_height], center=true);
}

// Create the model with all features
union() {
    difference() {
        union() {
            transformed_model();
            fill_side_holes();  // Add the filling cubes
        }
        through_holes();  // Add the through holes
        pocket();         // Add the recessed pocket
    }
}

