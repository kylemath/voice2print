// Pointed Tip with M6 Female Thread Insert
// Total height: 3cm (2cm cone + 1cm puck)
// M6 threaded insert 1.5cm deep from bottom

use <bbs/threads.scad>

// Parameters
total_height = 35;      // 3cm total height
cone_height = 25;       // 2cm cone height  
puck_height = 10;       // 1cm puck height
insert_depth = 15;      // 1.5cm insert depth

puck_diameter = 12;     // Diameter of the base puck
cone_base_diameter = 12; // Cone base matches puck
cone_tip_diameter = 0.5; // Very small tip for sharp point

m6_thread_diameter = 6;  // M6 thread
m6_thread_pitch = 1.0;   // Standard M6 pitch

// Main module
module pointed_tip_m6() {
    // M6 threaded hole from bottom, inset 1.5cm
    ScrewHole(m6_thread_diameter, 
             insert_depth, 
             position = [0, 0, 0], 
             rotation = [0, 0, 0], 
             pitch = m6_thread_pitch,
             tolerance = 0.8) {
        union() {
            // Base puck (cylinder)
            cylinder(h = puck_height, d = puck_diameter, $fn = 64);
            
            // Pointed cone on top
            translate([0, 0, puck_height]) {
                cylinder(h = cone_height, 
                        d1 = cone_base_diameter, 
                        d2 = cone_tip_diameter, 
                        $fn = 64);
            }
        }
    }
}

// Render the part
pointed_tip_m6(); 