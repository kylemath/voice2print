// Specialized Comb - Flat Body with Curved Handle
// Rectangular comb body, tines extending downward, curved handle extending horizontally

// Parameters for customization
body_width = 40;        // Width of rectangular comb body
body_length = 25;       // Length of rectangular comb body  
body_thickness = 6;     // Thickness of the comb body

// Tine parameters
tine_rows = 2;          // Two rows of tines
tines_per_row = 4;      // Number of tines per row
tine_length = 25;       // Length of tines extending downward
tine_width = 4;         // Width of each tine
tine_thickness = 3;     // Thickness of tine walls
channel_depth = 1.5;    // Depth of the channels
row_spacing = 8;        // Spacing between rows
tine_spacing = 6;       // Spacing between tines in a row

// Handle parameters
handle_length = 50;     // Length of handle extending horizontally
handle_width = 12;      // Width of handle
handle_thickness = 6;   // Thickness of handle
curve_radius = 15;      // Radius of curve connecting handle to body

// Rendering quality
$fn = 32;

module comb() {
    union() {
        // Main rectangular comb body
        comb_body();
        
        // Curved handle extending horizontally
        handle();
        
        // Tines extending downward from body
        tines();
    }
}

module comb_body() {
    // Create flat rectangular comb body
    translate([0, 0, 0])
        cube([body_width, body_length, body_thickness], center=true);
}

module handle() {
    // Handle with curved connection to comb body
    hull() {
        // Connection point at comb body
        translate([body_width/2, 0, 0])
            cylinder(d=handle_thickness, h=body_thickness, center=true);
        
        // Curve control point
        translate([body_width/2 + curve_radius, curve_radius, 0])
            cylinder(d=handle_thickness, h=body_thickness*0.9, center=true);
        
        // Handle end
        translate([body_width/2 + handle_length, curve_radius, 0])
            cylinder(d=handle_width, h=handle_thickness, center=true);
    }
    
    // Add grip texture to handle
    for(i = [curve_radius+5:3:handle_length-5]) {
        translate([body_width/2 + i, curve_radius, 0]) {
            // Crosshatch pattern
            rotate([0, 0, 45])
                cube([handle_width*0.7, 0.8, handle_thickness+1], center=true);
            rotate([0, 0, -45])
                cube([handle_width*0.7, 0.8, handle_thickness+1], center=true);
        }
    }
}

module tines() {
    // Top row - rectangular channels
    for(i = [0:tines_per_row-1]) {
        x_pos = (i - (tines_per_row-1)/2) * tine_spacing;
        translate([x_pos, row_spacing/2, -body_thickness/2])
            rectangular_channel_tine();
    }
    
    // Bottom row - rounded channels  
    for(i = [0:tines_per_row-1]) {
        x_pos = (i - (tines_per_row-1)/2) * tine_spacing;
        translate([x_pos, -row_spacing/2, -body_thickness/2])
            rounded_channel_tine();
    }
}

module rectangular_channel_tine() {
    difference() {
        // Main tine body extending downward
        hull() {
            // Base at comb body
            translate([0, 0, 0])
                cube([tine_width, tine_thickness, 2], center=true);
            
            // Tip (tapered)
            translate([0, 0, -tine_length])
                cube([tine_width*0.4, tine_thickness*0.4, 1], center=true);
        }
        
        // Rectangular channel
        hull() {
            translate([0, 0, 0])
                cube([tine_width*0.6, channel_depth, 3], center=true);
            translate([0, 0, -tine_length+2])
                cube([tine_width*0.3, channel_depth*0.5, 1], center=true);
        }
    }
}

module rounded_channel_tine() {
    difference() {
        // Main tine body extending downward
        hull() {
            // Base at comb body
            translate([0, 0, 0])
                cube([tine_width, tine_thickness, 2], center=true);
            
            // Tip (tapered)
            translate([0, 0, -tine_length])
                cube([tine_width*0.4, tine_thickness*0.4, 1], center=true);
        }
        
        // Rounded channel
        hull() {
            translate([0, 0, 0])
                cylinder(d=tine_width*0.6, h=3, center=true);
            translate([0, 0, -tine_length+2])
                cylinder(d=tine_width*0.3, h=1, center=true);
        }
    }
}

// Generate the comb
comb(); 