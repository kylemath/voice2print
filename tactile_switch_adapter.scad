// 3D Printed Tactile Switch Adapter
// Creates a large button and holder for a small tactile switch.
// Kyle Mathewson - Voice2Print Project

// ==== GLOBAL CONFIGURATION ====
$fn = 100; // Increase for smoother circles

// ==== TACTILE SWITCH DIMENSIONS (to be customized by user) ====
switch_width = 6;      // Width of the tactile switch body (e.g., 6mm for a 6x6mm switch)
switch_length = 6;     // Length of the tactile switch body
switch_height = 5;     // Height of the tactile switch body (excluding plunger)
switch_plunger_height = 2; // Height of the switch's own button/plunger
switch_plunger_diameter = 3; // Diameter of the switch's plunger

// ==== CUSTOM BUTTON DIMENSIONS ====
button_diameter = 30;  // Diameter of the large button cap
button_height = 8;     // Height of the large button cap
button_plunger_extension = 3; // How far the plunger extends from the button's underside

// ==== HOLDER DIMENSIONS ====
holder_diameter = button_diameter + 8; // Diameter of the holder base
holder_height = switch_height + 5;     // Total height of the holder
wall_thickness = 2;                  // Wall thickness for the holder

// ==== TOLERANCES ====
tolerance = 0.4; // Clearance for parts to fit together

// ==== COLORS FOR VISUALIZATION ====
button_color = "SteelBlue";
holder_color = "Silver";
switch_color = "Black";

// ============== MODULE DEFINITIONS ==============

// --- Tactile Switch Model (for visualization) ---
module tactile_switch() {
    color(switch_color) {
        // Switch Body
        cube([switch_width, switch_length, switch_height], center=true);
        // Switch Plunger
        translate([0, 0, switch_height/2]) {
            cylinder(d=switch_plunger_diameter, h=switch_plunger_height, center=false);
        }
    }
}

// --- Switch Holder ---
module switch_holder() {
    difference() {
        // Main holder body
        cylinder(d=holder_diameter, h=holder_height);

        // Hollow out the inside for the button
        translate([0, 0, wall_thickness]) {
            cylinder(d=holder_diameter - wall_thickness*2, h=holder_height);
        }

        // Create opening for the button plunger
        cylinder(d=switch_plunger_diameter + tolerance, h=holder_height*2, center=true);

        // Cavity for the tactile switch at the bottom
        translate([0, 0, -0.01]) { // -0.01 to ensure cut
            cube([switch_width + tolerance, switch_length + tolerance, switch_height + tolerance], center=true);
        }

        // Opening at the bottom to insert the switch
        translate([0,0, -holder_height/2])
        cube([switch_width + tolerance, switch_length + tolerance, holder_height], center=true);

    }
}


// --- Large Button ---
module large_button() {
    difference() {
        // Main button cap
        cylinder(d=button_diameter, h=button_height);
        
        // Plunger that presses the switch
        translate([0, 0, -button_plunger_extension]) {
            cylinder(d=switch_plunger_diameter, h=button_plunger_extension + 0.01);
        }
    }
    // Add a chamfer for a nicer look and feel
    rotate_extrude(convexity=10) {
        translate([button_diameter/2, button_height, 0]) {
            polygon(points=[[0,0], [-1,0], [0,-1]]);
        }
    }
}

// ============== ASSEMBLY & PRINTING ==============

// --- Assembly View ---
module assembly() {
    // Holder
    color(holder_color, 0.7)
    translate([0, 0, 0]) {
        switch_holder();
    }

    // Button (in place, slightly raised)
    color(button_color)
    translate([0, 0, holder_height - button_height/2]) {
        large_button();
    }
    
    // Tactile switch inside the holder
    translate([0, 0, switch_height/2]) {
        tactile_switch();
    }
}

// --- Print Layout ---
module print_layout() {
    // Place holder flat on the bed
    switch_holder();

    // Place button next to it, top up
    translate([holder_diameter, 0, button_height]) {
        rotate([180, 0, 0])
            large_button();
    }
}


// ============== RENDER CONTROL ==============

// --- Uncomment the desired module to render ---

// assembly();
print_layout();
// switch_holder();
// large_button(); 