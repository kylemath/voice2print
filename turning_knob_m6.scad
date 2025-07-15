// Turning Knob with M6 Female Thread Insert
// Designed to be printed upside down with thread at top
// Base puck + flared knob with ridges for grip

use <bbs/threads.scad>

// Parameters
puck_height = 10;       // 1cm puck height
insert_depth = 10;      // 1.5cm insert depth
knob_height = 4;       // Height of the knob portion

puck_diameter = 12;     // Diameter of the base puck
knob_base_diameter = 28; // Knob starts at puck diameter
knob_top_diameter = 30;  // Knob flares out to this diameter

m6_thread_diameter = 6;  // M6 thread
m6_thread_pitch = 1.0;   // Standard M6 pitch

// Ridge parameters
ridge_count = 16;        // Number of ridges around circumference
ridge_depth = 2.5;       // How deep the ridges cut into the surface
ridge_width = 2;         // Width of each ridge

// Main knob shape
module knob_body() {
    union() {
        // Base puck (cylinder)
        cylinder(h = puck_height, d = puck_diameter, $fn = 64);
        
        // Flared knob portion
        translate([0, 0, puck_height]) {
            cylinder(h = knob_height, 
                    d1 = knob_base_diameter, 
                    d2 = knob_top_diameter, 
                    $fn = 64);
        }
    }
}

// Ridges for grip
module grip_ridges() {
    for (i = [0 : ridge_count - 1]) {
        rotate([0, 0, i * 360 / ridge_count]) {
            translate([0, 0, puck_height]) {
                // Create vertical ridge along the flared surface
                hull() {
                    translate([knob_base_diameter/2 - ridge_depth/2, 0, 0]) {
                        cylinder(h = ridge_width, d = ridge_depth, $fn = 16);
                    }
                    translate([knob_top_diameter/2 - ridge_depth/2, 0, knob_height - ridge_width]) {
                        cylinder(h = ridge_width, d = ridge_depth, $fn = 16);
                    }
                }
            }
        }
    }
}

// Main module
module turning_knob_m6() {
    // M6 threaded hole from bottom, inset 1.5cm
    ScrewHole(m6_thread_diameter, 
             insert_depth, 
             position = [0, 0, 0], 
             rotation = [0, 0, 0], 
             pitch = m6_thread_pitch,
             tolerance = 0.8) {
        union() {
            knob_body();
            grip_ridges();
        }
    }
}

// Render the part
turning_knob_m6(); 