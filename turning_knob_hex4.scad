// Turning Knob with Hex 4 Protrusion
// Designed to be printed upside down with hex protrusion at top
// Base puck + flared knob with ridges for grip + hex 4 protrusion

use <bbs/threads.scad>

// Parameters
puck_height = 5;       // 1cm puck height
hex_protrusion_length = 2;  // 2mm hex protrusion length
knob_height = 4;        // Height of the knob portion

puck_diameter = 15;     // Diameter of the base puck
knob_base_diameter = 28; // Knob starts at this diameter
knob_top_diameter = 30;  // Knob flares out to this diameter

// Hex 4 parameters
hex_size = 4;           // 4mm hex across flats
hex_tolerance = 0.1;    // Tolerance for hex fit

// Screw head recession parameters
screw_head_diameter = 12;  // 11.8mm diameter for screw head
screw_head_depth = 3;        // 4mm deep recession (>3mm as requested)
screw_head_tolerance = 0.1; // Tolerance for screw head fit

// Ridge parameters
ridge_count = 16;        // Number of ridges around circumference
ridge_depth = 2.5;       // How deep the ridges cut into the surface
ridge_width = 2;         // Width of each ridge

// Main knob shape
module knob_body() {
    difference() {
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
        
        // Screw head recession
        translate([0, 0, -0.01]) {
            cylinder(h = screw_head_depth + 0.01, 
                    d = screw_head_diameter + screw_head_tolerance, 
                    $fn = 32);
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

// Hex 4 protrusion
module hex_protrusion() {
    translate([0, 0, screw_head_depth - hex_protrusion_length]) {
        cylinder(h = hex_protrusion_length, 
                d = (hex_size - hex_tolerance) / cos(30), 
                $fn = 6);
    }
}

// Main module
module turning_knob_hex4() {
    union() {
        knob_body();
        grip_ridges();
        hex_protrusion();
    }
}

// Render the part
turning_knob_hex4(); 