include <../config.scad>

// Local parameters
CORNER_RADIUS = 3;  // Radius for rounded corners

// Module for creating the bar mount cavity
module bar_mount_cavity() {
    total_width = MOUNT_SPACING + MOUNT_WIDTH * 2;  // Total width including both mounts
    
    difference() {
        // Main body with rounded corners
        minkowski() {
            translate([-CASE_WIDTH/2, -CASE_DEPTH/2, -23])
            cube([total_width + WALL_THICKNESS * 2 + SIDEWALL_EXTRATHICKNESS - CORNER_RADIUS*2, 
                  CASE_DEPTH + 1.5, 
                  CAVITY_DEPTH - CORNER_RADIUS*2+6]);
            sphere(r=CORNER_RADIUS);
        }
        
        // Combined cavity for handlebar and mounts with rounded edges
        minkowski() {
            hull() {
                // Handlebar cavity
                translate([0, 0, 2-HANDLEBAR_DIAMETER/2+MOUNT_GAP_DEPTH])
                rotate([0, 90, 0])
                cylinder(d=HANDLEBAR_DIAMETER + TPU_TOLERANCE - CORNER_RADIUS*2, 
                        h=total_width + WALL_THICKNESS * 4 - CORNER_RADIUS*2, 
                        center=true);
            }
            sphere(r=CORNER_RADIUS);
        }
        
        // Mount cavities with continuous space between and rounded edges
        translate([0, 0, 3.45])
            minkowski() {
                hull() {
                    // Left mount cavity
                    translate([-MOUNT_SPACING/2 - MOUNT_WIDTH/2, 0, -CAVITY_DEPTH/2])
                    cube([MOUNT_WIDTH + TPU_TOLERANCE - CORNER_RADIUS*2, 
                        MOUNT_HEIGHT + TPU_TOLERANCE - CORNER_RADIUS*2, 
                        3+CAVITY_DEPTH], center=true);
                    
                    // Right mount cavity
                    translate([MOUNT_SPACING/2 + MOUNT_WIDTH/2, 0, -CAVITY_DEPTH/2])
                    cube([MOUNT_WIDTH + TPU_TOLERANCE - CORNER_RADIUS*2, 
                        MOUNT_HEIGHT + TPU_TOLERANCE - CORNER_RADIUS*2, 
                        3+ CAVITY_DEPTH], center=true);
                }
                sphere(r=CORNER_RADIUS);
            }
    }
}

// Main handlebar interface module
module handlebar_interface() {
    rotate([0, 180, 0]) {
        bar_mount_cavity();
    }
}
