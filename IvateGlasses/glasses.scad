// Sports-style Sunglasses with Hinged Arms
// Standard lens dimensions for sports sunglasses
lens_width = 55;
lens_height = 35;
lens_curve_radius = 85; // Radius for the curved lens
frame_thickness = 5;
frame_depth = 2;
bridge_width = 15;
temple_length = 140;
temple_width = 5;
temple_thickness = 3;
hinge_radius = 2;
hinge_thickness = 3;
lens_offset = 5; // Vertical offset for lenses

// Main frame with curved shape
module frame() {
    difference() {
        // Frame outline - main body
        hull() {
            // Left eye frame
            translate([-bridge_width/2 - lens_width/2, 0, 0])
                linear_extrude(height=frame_depth)
                difference() {
                    offset(r=frame_thickness) 
                        ellipse(lens_width/2, lens_height/2);
                    offset(r=frame_thickness/4) 
                        ellipse(lens_width/2, lens_height/2);
                }
            
            // Right eye frame
            translate([bridge_width/2 + lens_width/2, 0, 0])
                linear_extrude(height=frame_depth)
                difference() {
                    offset(r=frame_thickness) 
                        ellipse(lens_width/2, lens_height/2);
                    offset(r=frame_thickness/4) 
                        ellipse(lens_width/2, lens_height/2);
                }
        }
        
        // Left lens cutout
        translate([-bridge_width/2 - lens_width/2, 0, -0.5])
            linear_extrude(height=frame_depth+1)
            ellipse(lens_width/2, lens_height/2);
        
        // Right lens cutout
        translate([bridge_width/2 + lens_width/2, 0, -0.5])
            linear_extrude(height=frame_depth+1)
            ellipse(lens_width/2, lens_height/2);
    }
}

// Helper module for ellipse
module ellipse(width, height) {
    scale([width, height]) circle(1, $fn=100);
}

// Temple/arm piece with bend
module temple() {
    straight_length = temple_length * 0.6;
    bend_length = temple_length * 0.4;
    
    // Straight part
    cube([straight_length, temple_width, temple_thickness]);
    
    // Bent part
    translate([straight_length, 0, 0])
        rotate([0, -15, 0])
        cube([bend_length, temple_width, temple_thickness]);
}

// Hinge mechanism
module hinge() {
    difference() {
        union() {
            cylinder(h=hinge_thickness, r=hinge_radius, $fn=20);
            translate([0, 0, hinge_thickness + 1])
                cylinder(h=hinge_thickness, r=hinge_radius, $fn=20);
        }
        // Hinge pin hole
        translate([0, 0, -0.5])
            cylinder(h=hinge_thickness*2 + 2, r=hinge_radius/3, $fn=20);
    }
}

// Temple hinge connection
module temple_with_hinge() {
    translate([0, temple_width/2, 0]) hinge();
    
    translate([0, 0, hinge_thickness]) 
        temple();
}

// Final assembly
module sunglasses() {
    frame();
    
    // Left temple with hinge
    translate([-bridge_width/2 - lens_width/2 - frame_thickness, 0, 0]) 
        mirror([1, 0, 0])
        temple_with_hinge();
    
    // Right temple with hinge
    translate([bridge_width/2 + lens_width/2 + frame_thickness, 0, 0])
        temple_with_hinge();
}

// Render the sunglasses
sunglasses();