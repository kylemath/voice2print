// Y-Splitter: 6" inlet to dual 4" outlets
// Designed for HVAC/plumbing applications
// All dimensions in mm

// Global parameters
$fn = 100; // High resolution for smooth curves

// Pipe dimensions (converting inches to mm: 1" = 25.4mm)
inlet_diameter = 6 * 25.4;      // 6" = 152.4mm
outlet_diameter = 4 * 25.4;     // 4" = 101.6mm
wall_thickness = 6;             // Wall thickness in mm
socket_depth = 25;              // Depth for pipe insertion

// Y-splitter geometry
split_angle = 30;               // Angle of each outlet from center (degrees)
transition_length = 80;         // Length of transition zone
outlet_length = 60;             // Length of outlet pipes
inlet_length = 40;              // Length of inlet pipe

// Main Y-splitter assembly
module y_splitter() {
    difference() {
        // Outer shell
        union() {
            // Main inlet pipe
            translate([0, 0, -inlet_length])
                cylinder(d = inlet_diameter + 2*wall_thickness, h = inlet_length + transition_length/2);
            
            // Transition body (tapered from inlet to outlets)
            transition_body();
            
            // Left outlet pipe
            rotate([0, split_angle, 0])
                translate([0, 0, transition_length/2])
                    cylinder(d = outlet_diameter + 2*wall_thickness, h = outlet_length);
            
            // Right outlet pipe  
            rotate([0, -split_angle, 0])
                translate([0, 0, transition_length/2])
                    cylinder(d = outlet_diameter + 2*wall_thickness, h = outlet_length);
        }
        
        // Hollow interior
        union() {
            // Inlet cavity
            translate([0, 0, -inlet_length - 1])
                cylinder(d = inlet_diameter, h = inlet_length + transition_length/2 + 2);
            
            // Transition cavity
            transition_cavity();
            
            // Left outlet cavity
            rotate([0, split_angle, 0])
                translate([0, 0, transition_length/2 - 1])
                    cylinder(d = outlet_diameter, h = outlet_length + 2);
            
            // Right outlet cavity
            rotate([0, -split_angle, 0])
                translate([0, 0, transition_length/2 - 1])
                    cylinder(d = outlet_diameter, h = outlet_length + 2);
        }
        
        // Pipe sockets (recessed areas for pipe insertion)
        pipe_sockets();
    }
}

// Transition body connecting inlet to outlets
module transition_body() {
    hull() {
        // Bottom of transition (inlet size)
        translate([0, 0, 0])
            cylinder(d = inlet_diameter + 2*wall_thickness, h = 1);
        
        // Top left (outlet size and position)
        rotate([0, split_angle, 0])
            translate([0, 0, transition_length/2])
                cylinder(d = outlet_diameter + 2*wall_thickness, h = 1);
        
        // Top right (outlet size and position)
        rotate([0, -split_angle, 0])
            translate([0, 0, transition_length/2])
                cylinder(d = outlet_diameter + 2*wall_thickness, h = 1);
    }
}

// Internal cavity for smooth airflow transition
module transition_cavity() {
    hull() {
        // Bottom of cavity (inlet size)
        translate([0, 0, -1])
            cylinder(d = inlet_diameter, h = 1);
        
        // Top left cavity
        rotate([0, split_angle, 0])
            translate([0, 0, transition_length/2])
                cylinder(d = outlet_diameter, h = 1);
        
        // Top right cavity
        rotate([0, -split_angle, 0])
            translate([0, 0, transition_length/2])
                cylinder(d = outlet_diameter, h = 1);
    }
}

// Pipe insertion sockets
module pipe_sockets() {
    // Inlet socket (slightly larger for pipe insertion)
    translate([0, 0, -inlet_length])
        cylinder(d = inlet_diameter + 1, h = socket_depth);
    
    // Left outlet socket
    rotate([0, split_angle, 0])
        translate([0, 0, transition_length/2 + outlet_length - socket_depth])
            cylinder(d = outlet_diameter + 1, h = socket_depth + 1);
    
    // Right outlet socket
    rotate([0, -split_angle, 0])
        translate([0, 0, transition_length/2 + outlet_length - socket_depth])
            cylinder(d = outlet_diameter + 1, h = socket_depth + 1);
}

// Optional: Create mounting flange at the base
module mounting_flange() {
    difference() {
        cylinder(d = inlet_diameter + 2*wall_thickness + 40, h = wall_thickness);
        cylinder(d = inlet_diameter + 2*wall_thickness + 2, h = wall_thickness + 1);
        
        // Mounting holes
        for (angle = [0:90:270]) {
            rotate([0, 0, angle])
                translate([inlet_diameter/2 + wall_thickness + 15, 0, -1])
                    cylinder(d = 8, h = wall_thickness + 2);
        }
    }
}

// Render the Y-splitter
y_splitter();

// Uncomment the line below to add a mounting flange
// translate([0, 0, -inlet_length - wall_thickness]) mounting_flange();

// Print information
echo("=== Y-Splitter Specifications ===");
echo(str("Inlet diameter: ", inlet_diameter, "mm (", inlet_diameter/25.4, " inches)"));
echo(str("Outlet diameter: ", outlet_diameter, "mm (", outlet_diameter/25.4, " inches)"));
echo(str("Split angle: ", split_angle, " degrees each side"));
echo(str("Wall thickness: ", wall_thickness, "mm"));
echo(str("Socket depth: ", socket_depth, "mm")); 