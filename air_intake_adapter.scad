// Air Intake Adapter with Funnel and 45° Bent Neck
// 3mm male connector output with 3 inch bent neck
// Designed for air intake applications
// All dimensions in mm

// Global parameters
$fn = 100; // High resolution for smooth curves

// Connector and pipe dimensions
male_connector_diameter = 3.0;      // 3mm male connector outer diameter
internal_diameter = 1.8;            // Internal air passage diameter
wall_thickness = 2;                 // Wall thickness for strength
connector_length = 15;              // Length of male connector

// Funnel dimensions
funnel_inlet_diameter = 25;         // Wide funnel inlet (25mm)
funnel_height = 30;                 // Height of funnel transition
neck_outer_diameter = 8;            // Outer diameter of neck sections

// Neck dimensions (3 inch = 76.2mm total)
neck_length = 76.2;                 // 3 inch total neck length
bend_radius = 15;                   // Radius of the 45° bend
bend_angle = 45;                    // 45 degree bend
straight_section1 = 20;             // First straight section
straight_section2 = 20;             // Second straight section after bend

// Main assembly - much simpler approach
module air_intake_adapter() {
    union() {
        // 1. Funnel section
        difference() {
            // Outer funnel shape
            cylinder(h = funnel_height, 
                    d1 = funnel_inlet_diameter + 2*wall_thickness, 
                    d2 = neck_outer_diameter);
            
            // Inner cavity
            translate([0, 0, -0.1])
                cylinder(h = funnel_height + 0.2, 
                        d1 = funnel_inlet_diameter, 
                        d2 = internal_diameter);
        }
        
        // 2. First straight section
        translate([0, 0, funnel_height])
            difference() {
                cylinder(h = straight_section1, d = neck_outer_diameter);
                translate([0, 0, -0.1])
                    cylinder(h = straight_section1 + 0.2, d = internal_diameter);
            }
        
        // 3. 45° Elbow section
        translate([0, 0, funnel_height + straight_section1])
            elbow_45_degree();
        
        // 4. Final straight section with male connector
        translate([bend_radius * sin(bend_angle), 0, 
                   funnel_height + straight_section1 + bend_radius * (1 - cos(bend_angle))])
            rotate([0, bend_angle, 0])
                final_section();
    }
}

// Simple 45° elbow using hull between cylinders
module elbow_45_degree() {
    // Create smooth elbow by hulling multiple cylinders along the curve
    steps = 10;
    for (i = [0:steps-1]) {
        angle = (bend_angle / steps) * i;
        next_angle = (bend_angle / steps) * (i + 1);
        
        hull() {
            // Current position
            translate([bend_radius * sin(angle), 0, bend_radius * (1 - cos(angle))])
                rotate([0, angle, 0])
                    cylinder(h = 0.1, d = neck_outer_diameter, center = true);
            
            // Next position
            translate([bend_radius * sin(next_angle), 0, bend_radius * (1 - cos(next_angle))])
                rotate([0, next_angle, 0])
                    cylinder(h = 0.1, d = neck_outer_diameter, center = true);
        }
    }
    
    // Hollow out the elbow
    for (i = [0:steps-1]) {
        angle = (bend_angle / steps) * i;
        next_angle = (bend_angle / steps) * (i + 1);
        
        hull() {
            translate([bend_radius * sin(angle), 0, bend_radius * (1 - cos(angle))])
                rotate([0, angle, 0])
                    cylinder(h = 0.12, d = internal_diameter, center = true);
            
            translate([bend_radius * sin(next_angle), 0, bend_radius * (1 - cos(next_angle))])
                rotate([0, next_angle, 0])
                    cylinder(h = 0.12, d = internal_diameter, center = true);
        }
    }
}

// Final straight section and male connector
module final_section() {
    difference() {
        union() {
            // Straight section after bend
            cylinder(h = straight_section2, d = neck_outer_diameter);
            
            // Male connector
            translate([0, 0, straight_section2])
                cylinder(h = connector_length, d = male_connector_diameter + wall_thickness);
            
            // Tapered tip for easy insertion
            translate([0, 0, straight_section2 + connector_length])
                cylinder(h = 3, d1 = male_connector_diameter + wall_thickness, d2 = male_connector_diameter);
        }
        
        // Internal air passage through everything
        translate([0, 0, -0.1])
            cylinder(h = straight_section2 + connector_length + 4, d = internal_diameter);
    }
}

// Even simpler version using rotate_extrude properly
module air_intake_adapter_v2() {
    union() {
        // 1. Funnel section
        difference() {
            cylinder(h = funnel_height, 
                    d1 = funnel_inlet_diameter + 2*wall_thickness, 
                    d2 = neck_outer_diameter);
            translate([0, 0, -0.1])
                cylinder(h = funnel_height + 0.2, 
                        d1 = funnel_inlet_diameter, 
                        d2 = internal_diameter);
        }
        
        // 2. First straight section
        translate([0, 0, funnel_height])
            difference() {
                cylinder(h = straight_section1, d = neck_outer_diameter);
                translate([0, 0, -0.1])
                    cylinder(h = straight_section1 + 0.2, d = internal_diameter);
            }
        
        // 3. 90° bend using rotate_extrude (simpler)
        translate([0, 0, funnel_height + straight_section1]) {
            difference() {
                rotate_extrude(angle = bend_angle, $fn = 100)
                    translate([bend_radius, 0])
                        circle(d = neck_outer_diameter);
                
                rotate_extrude(angle = bend_angle + 1, $fn = 100)
                    translate([bend_radius, 0])
                        circle(d = internal_diameter);
            }
        }
        
        // 4. Final section
        translate([bend_radius, 0, funnel_height + straight_section1])
            rotate([0, 0, bend_angle])
                rotate([90, 0, 0]) {
                    difference() {
                        union() {
                            cylinder(h = straight_section2, d = neck_outer_diameter);
                            translate([0, 0, straight_section2])
                                cylinder(h = connector_length, d = male_connector_diameter + wall_thickness);
                            translate([0, 0, straight_section2 + connector_length])
                                cylinder(h = 3, d1 = male_connector_diameter + wall_thickness, d2 = male_connector_diameter);
                        }
                        translate([0, 0, -0.1])
                            cylinder(h = straight_section2 + connector_length + 4, d = internal_diameter);
                    }
                }
    }
}

// Render the adapter
air_intake_adapter_v2();

// Print specifications
echo("=== Air Intake Adapter Specifications ===");
echo(str("Male connector diameter: ", male_connector_diameter, "mm"));
echo(str("Internal air diameter: ", internal_diameter, "mm"));
echo(str("Funnel inlet diameter: ", funnel_inlet_diameter, "mm"));
echo(str("Total length: ~", funnel_height + straight_section1 + straight_section2 + connector_length, "mm"));
echo(str("Bend angle: ", bend_angle, " degrees"));
echo(str("Wall thickness: ", wall_thickness, "mm")); 