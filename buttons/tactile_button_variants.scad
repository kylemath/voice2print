// 3D Printed Tactile Button Variants for Different JST Connectors
// Additional connector types and specialized applications
// Kyle Mathewson - Voice2Print Project

include <tactile_button_led.scad>

// ==== JST-PH SERIES (2.0mm pitch) - Battery/Small Device Applications ====
module jst_ph_button() {
    // Override JST connector dimensions for PH series
    jst_connector_width = 8;
    jst_connector_length = 6;
    jst_connector_height = 5;
    jst_pin_spacing = 2.0;        // 2.0mm pitch for JST-PH
    jst_pin_diameter = 0.6;       // Smaller pins for PH series
    
    // Smaller housing for compact applications
    housing_width = 22;
    housing_length = 35;
    housing_height = 10;
    
    button_cap_diameter = 12;     // Smaller button
    
    difference() {
        union() {
            // Main housing body
            cube([housing_width, housing_length, housing_height], center=true);
            
            // JST connector mounting boss
            translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
                cube([jst_connector_width + 2, jst_connector_length + 2, jst_connector_height], center=true);
        }
        
        // Hollow out interior
        translate([0, 0, wall_thickness])
            cube([housing_width - wall_thickness*2, 
                  housing_length - wall_thickness*2, 
                  housing_height], center=true);
        
        // Button cap cavity
        translate([0, 0, housing_height/2 - button_cap_height/2 + 0.5])
            cylinder(d=button_cap_diameter + 1, h=button_cap_height + 1, center=true);
        
        // Spring cavity
        translate([0, 0, wall_thickness + spring_height/2])
            cylinder(d=spring_outer_diameter + 2, h=spring_height + 1, center=true);
        
        // JST connector cavity
        translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
            cube([jst_connector_width + jst_tolerance, 
                  jst_connector_length + jst_tolerance, 
                  jst_connector_height + jst_tolerance], center=true);
        
        // JST pin holes (2-pin for battery applications)
        for(i = [-1, 1]) {
            translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length + 2, -housing_height/2 + jst_connector_height/2])
                rotate([90, 0, 0])
                cylinder(d=jst_pin_diameter + jst_tolerance, h=jst_connector_length);
        }
        
        // Wire routing channels
        for(i = [-1, 1]) {
            hull() {
                translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length/2, -housing_height/2 + 2])
                    cylinder(d=wire_channel_diameter, h=1);
                translate([i * 5, housing_length/2 - 6, wall_thickness])
                    cylinder(d=wire_channel_diameter, h=1);
            }
        }
        
        // Contact insertion holes
        translate([-5, housing_length/2 - 6, wall_thickness - 0.1])
            cylinder(d=contact_diameter + 0.2, h=contact_depth + 0.1);
        translate([5, housing_length/2 - 6, wall_thickness - 0.1])
            cylinder(d=contact_diameter + 0.2, h=contact_depth + 0.1);
    }
}

// ==== JST-XH SERIES (2.5mm pitch) - RC/3D Printer Applications ====
module jst_xh_button() {
    // XH series dimensions (same as default SM but optimized for higher current)
    jst_connector_width = 12;
    jst_connector_length = 9;
    jst_connector_height = 7;
    jst_pin_spacing = 2.5;        // 2.5mm pitch for JST-XH
    jst_pin_diameter = 1.0;       // Larger pins for higher current
    
    // Robust housing for RC applications
    housing_width = 28;
    housing_length = 45;
    housing_height = 14;
    
    button_cap_diameter = 18;     // Larger button for easier use
    
    difference() {
        union() {
            // Main housing body with reinforced corners
            hull() {
                for(x = [-1, 1], y = [-1, 1]) {
                    translate([x * (housing_width/2 - 3), y * (housing_length/2 - 3), 0])
                        cylinder(d=6, h=housing_height, center=true);
                }
            }
            
            // JST connector mounting boss
            translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
                cube([jst_connector_width + 3, jst_connector_length + 3, jst_connector_height], center=true);
        }
        
        // Hollow out interior
        translate([0, 0, wall_thickness])
            cube([housing_width - wall_thickness*2, 
                  housing_length - wall_thickness*2, 
                  housing_height], center=true);
        
        // Button cap cavity
        translate([0, 0, housing_height/2 - button_cap_height/2 + 0.5])
            cylinder(d=button_cap_diameter + 1, h=button_cap_height + 1, center=true);
        
        // Larger spring cavity for more robust mechanism
        translate([0, 0, wall_thickness + spring_height/2])
            cylinder(d=10 + 2, h=spring_height + 1, center=true);
        
        // JST connector cavity
        translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
            cube([jst_connector_width + jst_tolerance, 
                  jst_connector_length + jst_tolerance, 
                  jst_connector_height + jst_tolerance], center=true);
        
        // JST pin holes (2-pin for power applications)
        for(i = [-1, 1]) {
            translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length + 2, -housing_height/2 + jst_connector_height/2])
                rotate([90, 0, 0])
                cylinder(d=jst_pin_diameter + jst_tolerance, h=jst_connector_length);
        }
        
        // Wire routing channels (larger for thicker wires)
        for(i = [-1, 1]) {
            hull() {
                translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length/2, -housing_height/2 + 2])
                    cylinder(d=2, h=1);  // Larger channel
                translate([i * 7, housing_length/2 - 10, wall_thickness])
                    cylinder(d=2, h=1);
            }
        }
        
        // Contact insertion holes (larger for higher current)
        translate([-7, housing_length/2 - 10, wall_thickness - 0.1])
            cylinder(d=3, h=contact_depth + 0.1);  // Larger contacts
        translate([7, housing_length/2 - 10, wall_thickness - 0.1])
            cylinder(d=3, h=contact_depth + 0.1);
    }
}

// ==== JST-VH SERIES (3.96mm pitch) - High Power Applications ====
module jst_vh_button() {
    // VH series for high-current applications
    jst_connector_width = 16;
    jst_connector_length = 12;
    jst_connector_height = 9;
    jst_pin_spacing = 3.96;       // 3.96mm pitch for JST-VH
    jst_pin_diameter = 1.2;       // Large pins for high current
    
    // Large robust housing
    housing_width = 35;
    housing_length = 55;
    housing_height = 18;
    
    button_cap_diameter = 22;     // Large button
    
    difference() {
        union() {
            // Reinforced housing body
            hull() {
                for(x = [-1, 1], y = [-1, 1]) {
                    translate([x * (housing_width/2 - 4), y * (housing_length/2 - 4), 0])
                        cylinder(d=8, h=housing_height, center=true);
                }
            }
            
            // Large JST connector mounting boss
            translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
                cube([jst_connector_width + 4, jst_connector_length + 4, jst_connector_height], center=true);
        }
        
        // Hollow out interior
        translate([0, 0, wall_thickness])
            cube([housing_width - wall_thickness*2, 
                  housing_length - wall_thickness*2, 
                  housing_height], center=true);
        
        // Button cap cavity
        translate([0, 0, housing_height/2 - button_cap_height/2 + 0.5])
            cylinder(d=button_cap_diameter + 1, h=button_cap_height + 1, center=true);
        
        // Large spring cavity
        translate([0, 0, wall_thickness + spring_height/2])
            cylinder(d=12 + 2, h=spring_height + 1, center=true);
        
        // JST connector cavity
        translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
            cube([jst_connector_width + jst_tolerance, 
                  jst_connector_length + jst_tolerance, 
                  jst_connector_height + jst_tolerance], center=true);
        
        // JST pin holes
        for(i = [-1, 1]) {
            translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length + 2, -housing_height/2 + jst_connector_height/2])
                rotate([90, 0, 0])
                cylinder(d=jst_pin_diameter + jst_tolerance, h=jst_connector_length);
        }
        
        // Large wire routing channels
        for(i = [-1, 1]) {
            hull() {
                translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length/2, -housing_height/2 + 3])
                    cylinder(d=2.5, h=1);
                translate([i * 8, housing_length/2 - 12, wall_thickness])
                    cylinder(d=2.5, h=1);
            }
        }
        
        // Large contact insertion holes for high current
        translate([-8, housing_length/2 - 12, wall_thickness - 0.1])
            cylinder(d=4, h=contact_depth + 0.1);
        translate([8, housing_length/2 - 12, wall_thickness - 0.1])
            cylinder(d=4, h=contact_depth + 0.1);
    }
}

// ==== MULTI-BUTTON ARRAY ====
module button_array_2x2() {
    spacing = 35;
    for(x = [-1, 1], y = [-1, 1]) {
        translate([x * spacing/2, y * spacing/2, 0])
            complete_button_assembly();
    }
}

module button_array_1x4() {
    spacing = 35;
    for(i = [-1.5, -0.5, 0.5, 1.5]) {
        translate([i * spacing, 0, 0])
            complete_button_assembly();
    }
}

// ==== SPECIALIZED APPLICATIONS ====

// Momentary switch for LED strip dimming
module led_dimmer_button() {
    // Includes a rotary encoder-like texture for dimming feedback
    button_cap_diameter = 20;
    
    difference() {
        complete_button_assembly();
        
        // Add dimmer texture to button cap
        translate([0, 0, housing_height - wall_thickness]) {
            for(angle = [0:15:345]) {
                rotate([0, 0, angle])
                    translate([8, 0, 0])
                    cylinder(d=2, h=3);
            }
        }
    }
}

// Illuminated button with LED cutout
module illuminated_button() {
    difference() {
        complete_button_assembly();
        
        // LED cutout in button cap
        translate([0, 0, housing_height - wall_thickness + button_cap_height/2])
            cylinder(d=5, h=button_cap_height + 1, center=true);
    }
    
    // LED holder ring
    translate([0, 0, housing_height - wall_thickness + button_cap_height - 1]) {
        difference() {
            cylinder(d=7, h=2);
            cylinder(d=5, h=3, center=true);
        }
    }
}

// Waterproof version with sealed housing
module waterproof_button() {
    difference() {
        // Sealed housing
        hull() {
            complete_button_assembly();
            // Add gasket channels
            translate([0, 0, housing_height/2 - 1])
                torus(housing_width/2 + 2, 1);
        }
        
        // O-ring groove
        translate([0, 0, housing_height/2 - 0.5])
            torus(housing_width/2 + 1, 0.8);
    }
}

// Helper module for torus (O-ring groove)
module torus(major_radius, minor_radius) {
    rotate_extrude()
        translate([major_radius, 0, 0])
        circle(r=minor_radius);
}

// ==== PRINTING LAYOUTS FOR VARIANTS ====

module print_jst_variants() {
    // JST-PH (small/battery)
    translate([0, 0, 0])
        rotate([180, 0, 0])
        jst_ph_button();
    
    // JST-XH (RC/3D printer)  
    translate([50, 0, 0])
        rotate([180, 0, 0])
        jst_xh_button();
    
    // JST-VH (high power)
    translate([100, 0, 0])
        rotate([180, 0, 0])
        jst_vh_button();
}

module print_specialized_buttons() {
    // LED dimmer button
    translate([0, 0, 0])
        rotate([180, 0, 0])
        led_dimmer_button();
    
    // Illuminated button
    translate([40, 0, 0])
        rotate([180, 0, 0])
        illuminated_button();
    
    // Waterproof button
    translate([80, 0, 0])
        rotate([180, 0, 0])
        waterproof_button();
}

// ==== RENDER CONTROL ====

// Uncomment what you want to see:

// Individual variants:
// jst_ph_button();
// jst_xh_button(); 
// jst_vh_button();

// Arrays:
// button_array_2x2();
// button_array_1x4();

// Specialized:
// led_dimmer_button();
// illuminated_button();
// waterproof_button();

// For printing:
print_jst_variants();
// print_specialized_buttons();

// ==== VARIANT SPECIFICATIONS ====
/*
JST-PH SERIES (Battery/Small Device):
- 2.0mm pin pitch
- Voltage: Up to 50V DC
- Current: Up to 2A
- Applications: Drone batteries, camera batteries, small electronics
- Wire gauge: 24-30 AWG

JST-XH SERIES (RC/3D Printer):
- 2.5mm pin pitch  
- Voltage: Up to 250V DC
- Current: Up to 3A
- Applications: RC cars, 3D printer connections, motor controllers
- Wire gauge: 22-28 AWG

JST-VH SERIES (High Power):
- 3.96mm pin pitch
- Voltage: Up to 250V DC
- Current: Up to 10A
- Applications: Industrial equipment, high-power LED arrays, motor drives
- Wire gauge: 16-22 AWG

SPECIALIZED VARIANTS:
- LED Dimmer: Textured button for tactile dimming feedback
- Illuminated: Built-in LED indicator in button cap
- Waterproof: Sealed housing with O-ring groove for outdoor use
- Arrays: Multiple buttons in organized layouts for control panels

CUSTOMIZATION:
All variants can be scaled and modified by adjusting the parameters
at the top of each module. Mix and match features as needed for your
specific application.
*/ 