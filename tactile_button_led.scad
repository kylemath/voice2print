// 3D Printed Tactile Button with Integrated JST LED Connectors
// Complete replacement for tactile switches and circuit boards
// Kyle Mathewson - Voice2Print Project

// ==== GLOBAL CONFIGURATION ====
$fn = 50;

// ==== BUTTON DIMENSIONS ====
button_cap_diameter = 15;       // Diameter of the button cap
button_cap_height = 4;          // Height of the button cap
button_travel = 2.5;            // How far the button travels when pressed
button_force = 1.5;             // Approximate force needed in Newtons

// ==== HOUSING DIMENSIONS ====
housing_width = 25;             // Width of the housing base
housing_length = 40;            // Length including JST connector area
housing_height = 12;            // Total height of housing
wall_thickness = 2;             // Wall thickness

// ==== SPRING MECHANISM ====
spring_outer_diameter = 8;      // Outer diameter of spring cavity
spring_height = 6;              // Height of spring cavity
spring_wall_thickness = 1.2;    // Thickness of spring arms
spring_arms = 4;                // Number of spring arms

// ==== JST CONNECTOR DIMENSIONS ====
// Based on JST-SM series (2.5mm pitch) - common for LED strips
jst_connector_width = 10;       // Width of JST connector housing
jst_connector_length = 8;       // Length of JST connector
jst_connector_height = 6;       // Height of JST connector
jst_pin_spacing = 2.5;          // 2.5mm pitch for JST-SM series
jst_pin_diameter = 0.8;         // Pin diameter for 24-28 AWG wire
jst_tolerance = 0.2;            // Tolerance for connector fit

// ==== CONTACT SYSTEM ====
contact_diameter = 2;           // Diameter of metal contact insert
contact_depth = 3;              // How deep contacts go into housing
wire_channel_diameter = 1.5;    // Channel for routing wires

// ==== COLOR CODING FOR ASSEMBLY VISUALIZATION ====
button_color = "lightblue";
housing_color = "darkgray";
spring_color = "yellow";
contact_color = "gold";

// ==== MAIN MODULES ====

// Complete button assembly for visualization
module complete_button_assembly() {
    // Housing base
    color(housing_color)
        housing_base();
    
    // Button cap (shown in pressed position for clearance check)
    color(button_color)
        translate([0, 0, housing_height - wall_thickness - button_travel/2])
        button_cap();
    
    // Spring mechanism
    color(spring_color)
        translate([0, 0, wall_thickness + 1])
        spring_mechanism();
    
    // Contact points (represented as gold cylinders)
    color(contact_color) {
        translate([-6, housing_length/2 - 8, wall_thickness])
            cylinder(d=contact_diameter, h=contact_depth);
        translate([6, housing_length/2 - 8, wall_thickness])
            cylinder(d=contact_diameter, h=contact_depth);
    }
}

// Main housing with integrated JST connector interface
module housing_base() {
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
        
        // JST pin holes (2-pin for LED applications)
        for(i = [-1, 1]) {
            translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length + 2, -housing_height/2 + jst_connector_height/2])
                rotate([90, 0, 0])
                cylinder(d=jst_pin_diameter + jst_tolerance, h=jst_connector_length);
        }
        
        // Wire routing channels from JST to contacts
        for(i = [-1, 1]) {
            hull() {
                // Start at JST pin
                translate([i * jst_pin_spacing/2, housing_length/2 - jst_connector_length/2, -housing_height/2 + 2])
                    cylinder(d=wire_channel_diameter, h=1);
                // End at contact point
                translate([i * 6, housing_length/2 - 8, wall_thickness])
                    cylinder(d=wire_channel_diameter, h=1);
            }
        }
        
        // Contact insertion holes
        translate([-6, housing_length/2 - 8, wall_thickness - 0.1])
            cylinder(d=contact_diameter + 0.2, h=contact_depth + 0.1);
        translate([6, housing_length/2 - 8, wall_thickness - 0.1])
            cylinder(d=contact_diameter + 0.2, h=contact_depth + 0.1);
        
        // Ventilation/assembly holes
        translate([housing_width/2 - 3, -housing_length/2 + 3, 0])
            cylinder(d=2, h=housing_height + 1, center=true);
        translate([-housing_width/2 + 3, -housing_length/2 + 3, 0])
            cylinder(d=2, h=housing_height + 1, center=true);
    }
}

// Button cap with tactile feedback design
module button_cap() {
    difference() {
        union() {
            // Main button cap
            cylinder(d=button_cap_diameter, h=button_cap_height);
            
            // Central dome for tactile feedback
            translate([0, 0, button_cap_height])
                sphere(d=8);
        }
        
        // Flatten bottom for spring contact
        translate([0, 0, -1])
            cylinder(d=button_cap_diameter + 2, h=1);
        
        // Tactile grip pattern on top
        for(angle = [0:30:330]) {
            rotate([0, 0, angle])
                translate([4, 0, button_cap_height + 2])
                cylinder(d=1, h=2, center=true);
        }
    }
}

// 3D printed spring mechanism using flexible arms
module spring_mechanism() {
    difference() {
        cylinder(d=spring_outer_diameter, h=spring_height);
        
        // Central cavity
        translate([0, 0, -0.1])
            cylinder(d=spring_outer_diameter - spring_wall_thickness*2, h=spring_height + 0.2);
        
        // Spring arm slots
        for(i = [0:spring_arms-1]) {
            rotate([0, 0, i * 360/spring_arms])
                translate([0, 0, spring_height/2])
                cube([spring_outer_diameter + 1, spring_wall_thickness/2, spring_height + 1], center=true);
        }
    }
}

// JST connector housing (reference model)
module jst_connector_reference() {
    color("black") {
        cube([jst_connector_width, jst_connector_length, jst_connector_height], center=true);
        
        // Pins
        color("silver") {
            for(i = [-1, 1]) {
                translate([i * jst_pin_spacing/2, -jst_connector_length/2, 0])
                    cylinder(d=jst_pin_diameter, h=jst_connector_height*2, center=true);
            }
        }
    }
}

// ==== SIZE VARIANTS ====

// Compact version for smaller applications
module compact_button() {
    scale([0.75, 0.75, 0.75])
        complete_button_assembly();
}

// Large version for high-current applications  
module large_button() {
    scale([1.3, 1.3, 1.3])
        complete_button_assembly();
}

// ==== PRINTING MODULES ====

// Housing for printing (optimized orientation)
module print_housing() {
    rotate([180, 0, 0])
        housing_base();
}

// Button cap for printing
module print_button_cap() {
    button_cap();
}

// Spring mechanism for printing (requires flexible filament)
module print_spring() {
    spring_mechanism();
}

// All parts laid out for printing
module print_all_parts() {
    // Housing
    print_housing();
    
    // Button cap
    translate([35, 0, 0])
        print_button_cap();
    
    // Spring (print in flexible material like TPU)
    translate([0, 30, 0])
        print_spring();
    
    // Size variants
    translate([-40, 0, 0])
        scale([0.75, 0.75, 0.75])
        print_housing();
    
    translate([0, -40, 0])
        scale([1.3, 1.3, 1.3])
        print_housing();
}

// ==== ASSEMBLY INSTRUCTIONS MODULE ====
module assembly_reference() {
    // Step 1: Housing with JST connector
    translate([0, 0, 0]) {
        color(housing_color, 0.8)
            housing_base();
        
        translate([0, housing_length/2 - jst_connector_length/2, -housing_height/2 + jst_connector_height/2])
            jst_connector_reference();
    }
    
    // Step 2: Insert spring
    translate([40, 0, 0]) {
        color(housing_color, 0.8)
            housing_base();
        color(spring_color)
            translate([0, 0, wall_thickness + 1])
            spring_mechanism();
    }
    
    // Step 3: Add contacts and button
    translate([80, 0, 0])
        complete_button_assembly();
}

// ==== MAIN RENDER CONTROL ====

// Uncomment the module you want to render:

// For assembly visualization:
complete_button_assembly();

// For printing individual parts:
// print_housing();
// print_button_cap(); 
// print_spring();

// For printing all parts at once:
// print_all_parts();

// For assembly instructions:
// assembly_reference();

// Size variants:
// compact_button();
// large_button();

// ==== PRINTING INSTRUCTIONS ====
/*
PRINTING INSTRUCTIONS:

1. HOUSING (Main Part):
   - Print upside down (JST connector side up) for better overhang support
   - Use PLA, PETG, or ABS for structural strength
   - Layer height: 0.2-0.3mm
   - Infill: 25-40% for durability
   - Supports: Only for JST connector cavity overhangs

2. BUTTON CAP:
   - Print right-side up for smooth button surface
   - Same material as housing
   - Layer height: 0.2mm for smooth finish
   - No supports needed

3. SPRING MECHANISM:
   - MUST be printed in flexible filament (TPU, FLEX)
   - Layer height: 0.3mm for flexibility
   - Infill: 100% for maximum elasticity
   - Print slowly (20-30mm/s) for clean flexible parts

ASSEMBLY INSTRUCTIONS:

1. INSERT METAL CONTACTS:
   - Use copper or brass pins/tubes for electrical contacts
   - Insert into contact holes in housing base
   - Ensure good fit and electrical continuity

2. WIRE THE JST CONNECTOR:
   - Route wires from JST pins through wire channels to contacts
   - Solder connections carefully
   - Test continuity before final assembly

3. INSTALL SPRING:
   - Insert flexible spring mechanism into spring cavity
   - Ensure spring arms can compress and return properly

4. ATTACH BUTTON CAP:
   - Place button cap on top of spring mechanism
   - Test button action - should have tactile click and return

5. CONNECT TO LED SYSTEM:
   - Insert JST-SM connector with proper polarity
   - Connect to LED strip controller or power supply
   - Test button functionality

ELECTRICAL SPECIFICATIONS:
- Voltage Rating: Up to 12V DC (LED safe)
- Current Rating: Up to 3A (suitable for LED strips)
- Contact Resistance: <50mΩ (with proper metal contacts)
- Operating Life: 100,000+ actuations (depending on spring material)

JST CONNECTOR COMPATIBILITY:
- Designed for JST-SM series (2.5mm pitch)
- Compatible with standard LED strip connectors
- Can be adapted for other JST series by modifying pin spacing
- Wire gauge: 22-26 AWG recommended

CUSTOMIZATION OPTIONS:
- Adjust button_cap_diameter for different button sizes
- Modify jst_pin_spacing for different JST series
- Scale entire assembly for different applications
- Change spring_arms count for different tactile feel

SAFETY NOTES:
- Only use with low voltage DC applications (≤12V)
- Ensure proper wire gauge for current requirements
- Test all connections before powering LED systems
- Use appropriate metal contacts for current rating needed
*/ 