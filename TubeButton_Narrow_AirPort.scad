include <threads.scad>

// Add NPT threaded hole
module npt_hole() {

}


// Add side pieces to partially close the window
module side_piece() {
    height = 50;  
    width = 10;    
    depth = 4;    
    
    cube([width, depth, height]);
}


module tubeSides() {
    // Left side piece
    translate([-10, -42, -18]) rotate([0,0,-5])side_piece();
    // Left side piece
    translate([-18, -39, -18]) rotate([0,0,-20]) side_piece();
    // Right side piece
    // Left side piece
    translate([-10, 38, -18]) rotate([0,0,3])side_piece();
    // Left side piece
    translate([-18, 34.5, -18]) rotate([0,0,20]) side_piece();
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
// NPT thread parameters
module npt_thread(size="1/4", thread_length=undef) {
    // NPT thread specifications
    base_specs = (size == "1/4") ? [
        13.716,  // Major diameter at start
        11.862,  // Minor diameter at start
        18.6,    // Thread length
        1.411,   // Thread pitch
        60       // Thread angle
    ] : [        // 1/8 NPT
        10.287,  // Major diameter at start
        8.679,   // Minor diameter at start
        16.3,    // Thread length
        0.907,   // Thread pitch
        60       // Thread angle
    ];
    
    // Use provided thread length or default from specs
    specs = [
        base_specs[0],
        base_specs[1], 
        thread_length == undef ? base_specs[2] : thread_length,
        base_specs[3],
        base_specs[4]
    ];
    
    // Add taper angle for NPT (1.7897 degrees per side)
    rotate([0, 0, 0])
        difference() {
            // Create tapered thread using ScrewThread
            ScrewThread(
                outer_diam=specs[0], 
                height=specs[2], 
                pitch=specs[3],
                tooth_angle=specs[4],
                tooth_height=(specs[0]-specs[1])/2,
                tip_height=0,
                tolerance=0.4
            );
            // Add the taper by intersecting with a cone
            translate([0, 0, -0.1])
                cylinder(
                    h=specs[2] + 0.2,
                    d1=specs[0],
                    d2=specs[0] - (specs[2] * tan(1.7897 * 2)),
                    $fn=64
                );
        }
}

// Modified union with smooth transition
union() {
    translate([12.2, 0, 0])
    difference() {
        fixedTube();
        // Clearance holes for NPT threads
        translate([-30, 0, 0]) 
        rotate([0, 90, 0])
        translate([0, 0, 60]) 
            cylinder(h=11.6, d1=30, d2=18, $fn=64);
                 // Add 1/4" NPT thread
           translate([-30, 0, 0]) 
        rotate([0, 90, 0])
        translate([0, 0, 60]) 
            cylinder(h=12.9, d1=13.7, d2=13.7, $fn=64);

    }
    
    difference() {
        difference() {
            // Main fitting body
            translate([-10, 0, 0]) 
            rotate([0, 90, 0])
            translate([0, 0, 60]) 
                cylinder(h=20, d1=23, d2=15, $fn=64);

            // Smoothing cylinder for transition
            translate([-10, 0, 0])
            rotate([0, 90, 0])
            translate([0, 0, 30])  // Slightly before the nipple starts
            rotate([90, 0, 90])     // Rotate to cut horizontally
                cylinder(h=50, r=35, center=true, $fn=64);  // Adjust radius (8) to control curve smoothness
            
        }
        
        union() {
            // Add 1/4" NPT thread
            translate([-6, 0, 0]) 
            rotate([0, 90, 0])
                translate([0, 0, 60]) 
                    cylinder(h=8, d1=13.7, d2=12.3, $fn=64);
                    // Add 1/4" NPT thread
            translate([-6, 0, 0]) 
            rotate([0, 90, 0])
                translate([0, 0, 60]) 
                    cylinder(h=16.5, d1=13.7, d2=10.3, $fn=64);
        }
    }
    
    // // Add 1/8" NPT thread for the outer hole
    translate([-22, 0, 0])
    rotate([0, 90, 0])
    translate([0, 0, 85])
        npt_thread("1/8", 7);

    // Add 1/4" NPT thread for the inner hole
    translate([153, 0, 0])
    rotate([0, 90, 0])
    rotate([0, 180, 0])
    translate([0, 0, 85])
        npt_thread("1/4", 16);
}

