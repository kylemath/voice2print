include <threads.scad>

// Add side pieces to partially close the window
module side_piece() {
    height = 50;  
    width = 10;    
    depth = 3.8;    
    
    cube([width, depth, height]);
}


module tubeSides() {
    // Left side piece
    translate([-10, -42, -18]) rotate([0,0,-5])side_piece();
    // Left side piece
    translate([-18, -39, -18]) rotate([0,0,-20]) side_piece();
    // Right side piece
    // Left side piece
    translate([-10, 37.8, -18]) rotate([0,0,10])side_piece();
    // Left side piece
    translate([-18.8, 34.5, -18]) rotate([0,0,20]) side_piece();
}



module fixedTube() {
    union() {
        // Import the base tube and rotate it 90 degrees around Y axis
        rotate([90, 90, 0]) 
            translate([-220, 0, 0])
                import("TubeBottom.stl");
        tubeSides();
    }
}

// union() {
// difference() {
    // Modified union with smooth transition
    
    union() {
        translate([-4, 0, 0]) {
            difference() {
                fixedTube();
                // Large clearance hole for air socket and npt threads
                translate([-30, 0, -2]) 
                rotate([0, 90, 0])
                translate([0, 0, 60]) 
                    cylinder(h=16, d1=35, d2=17, $fn=64);
            }
        }
        translate([-2, 0, -2]) {
            translate([-8, 0, 0]) {
                rotate([0, 90, 0])
                translate([0, 0, 60]) 
                TaperedScrewHole(
                    outer_diam_top = 14,
                    outer_diam_bottom = 13.5,
                    height = 8.5,
                    pitch = 1.411,  // NPT pitch
                    tooth_angle = 60  // NPT uses 60° thread angle
                ) {
                    cylinder(h=8.5, d1=22, d2=20, $fn=64);
                }
            }
            translate([-16.5, 0, 0]) {
                rotate([0, 90, 0])
                translate([0, 0, 60]) 
                TaperedScrewHole(
                    outer_diam_top = 13.5,
                    outer_diam_bottom = 14,
                    height = 8.5,
                    pitch = 1.411,  // NPT pitch
                    tooth_angle = 60  // NPT uses 60° thread angle
                ) {
                    cylinder(h=8.5, d1=24, d2=22, $fn=64);
                }
            }
        }
    
     

        // Extra wall for air socket inset
        translate([-24, 0, -2]) {
            difference() {
                    rotate([0, 90, 0])
                    translate([0, 0, 60]) 
                    cylinder(h=7, d1=26, d2=23, $fn=64);
                        // Extra inset for air socket
                    translate([-.1, 0, 0]) 
                    rotate([0, 90, 0])
                    translate([0, 0, 60]) 
                        cylinder(h=7.3, d1=23, d2=20.2, $fn=64);
                }
        }
    }
