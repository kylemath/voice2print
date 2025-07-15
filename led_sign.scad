// LED Sign with Clear Face and LED Strip Holders
// Kyle Mathewson - Voice2Print Project

// ==== CONFIGURATION PARAMETERS ====

// Sign dimensions (mm)
sign_width = 300;
sign_height = 200;
total_thickness = 30;  // Three layers thick

// Layer thicknesses
front_layer_thickness = 3;      // Clear face layer
middle_layer_thickness = 20;    // Main structural layer  
back_layer_thickness = 7;       // LED holder layer

// LED strip specifications
led_strip_width = 10;           // Width of LED strip
led_strip_thickness = 3;        // Thickness of LED strip
led_strip_spacing = 100;        // 100mm spacing between strips
led_holder_depth = 5;           // How deep the LED channel goes

// Border and mounting
border_width = 10;
mounting_hole_diameter = 4;
mounting_hole_offset = 15;

// Text/logo cutout settings (customize these)
text_areas = [
    ["HELLO", 50, [sign_width/2, sign_height/2 + 30], 8],  // [text, size, [x,y], depth]
    ["WORLD", 40, [sign_width/2, sign_height/2 - 30], 8]
];

// Custom illuminated areas (rectangles) - [width, height, [x,y], depth]
illuminated_rectangles = [
    [80, 20, [sign_width/2 - 100, sign_height/2], 6],
    [80, 20, [sign_width/2 + 100, sign_height/2], 6]
];

// ==== UTILITY MODULES ====

module rounded_rect(width, height, thickness, radius=5) {
    linear_extrude(height=thickness) {
        offset(r=radius) {
            square([width-2*radius, height-2*radius], center=true);
        }
    }
}

module mounting_holes() {
    hole_positions = [
        [-sign_width/2 + mounting_hole_offset, -sign_height/2 + mounting_hole_offset],
        [sign_width/2 - mounting_hole_offset, -sign_height/2 + mounting_hole_offset],
        [-sign_width/2 + mounting_hole_offset, sign_height/2 - mounting_hole_offset],
        [sign_width/2 - mounting_hole_offset, sign_height/2 - mounting_hole_offset]
    ];
    
    for (pos = hole_positions) {
        translate([pos[0], pos[1], -1])
            cylinder(h=total_thickness + 2, d=mounting_hole_diameter);
    }
}

// ==== MAIN COMPONENTS ====

module front_layer() {
    difference() {
        // Main front panel
        rounded_rect(sign_width, sign_height, front_layer_thickness);
        
        // Text cutouts
        for (text_data = text_areas) {
            translate([text_data[2][0], text_data[2][1], -0.5])
                linear_extrude(height=text_data[3] + 1)
                    text(text_data[0], size=text_data[1], halign="center", valign="center");
        }
        
        // Rectangular illuminated areas
        for (rect = illuminated_rectangles) {
            translate([rect[2][0], rect[2][1], -0.5])
                cube([rect[0], rect[1], rect[3] + 1], center=true);
        }
        
        // Mounting holes
        mounting_holes();
    }
}

module middle_layer() {
    difference() {
        // Main structural layer
        rounded_rect(sign_width, sign_height, middle_layer_thickness);
        
        // Hollow out areas behind illuminated sections for light diffusion
        for (text_data = text_areas) {
            translate([text_data[2][0], text_data[2][1], middle_layer_thickness/2])
                linear_extrude(height=middle_layer_thickness/2 + 1)
                    offset(r=2)  // Slightly larger than text for light spread
                        text(text_data[0], size=text_data[1], halign="center", valign="center");
        }
        
        for (rect = illuminated_rectangles) {
            translate([rect[2][0], rect[2][1], middle_layer_thickness/2])
                cube([rect[0] + 4, rect[1] + 4, middle_layer_thickness/2 + 1], center=true);
        }
        
        // Mounting holes
        mounting_holes();
    }
}

module back_layer() {
    difference() {
        // Main back panel
        rounded_rect(sign_width, sign_height, back_layer_thickness);
        
        // Mounting holes
        mounting_holes();
    }
    
    // LED strip holders
    led_holder_channels();
}

module led_holder_channels() {
    // Calculate number of LED strips that fit
    num_strips = floor((sign_width - 2*border_width) / led_strip_spacing) + 1;
    start_x = -sign_width/2 + border_width;
    
    for (i = [0:num_strips-1]) {
        x_pos = start_x + i * led_strip_spacing;
        
        // LED channel
        translate([x_pos, 0, back_layer_thickness]) {
            difference() {
                // Channel walls
                translate([0, 0, led_holder_depth/2])
                    cube([led_strip_width + 4, sign_height - 2*border_width, led_holder_depth], center=true);
                
                // Channel groove for LED strip
                translate([0, 0, led_holder_depth/2 + 1])
                    cube([led_strip_width, sign_height - 2*border_width + 2, led_strip_thickness + 0.5], center=true);
            }
        }
    }
    
    // Wire management channels
    wire_management_channels();
}

module wire_management_channels() {
    // Horizontal wire channel at bottom
    translate([0, -sign_height/2 + border_width/2, back_layer_thickness + 2])
        cube([sign_width - 2*border_width, 6, 4], center=true);
    
    // Vertical wire channels connecting to horizontal
    num_strips = floor((sign_width - 2*border_width) / led_strip_spacing) + 1;
    start_x = -sign_width/2 + border_width;
    
    for (i = [0:num_strips-1]) {
        x_pos = start_x + i * led_strip_spacing;
        translate([x_pos, -sign_height/4, back_layer_thickness + 2])
            cube([4, sign_height/2 - border_width, 4], center=true);
    }
    
    // Cable exit port
    translate([sign_width/2 - 20, -sign_height/2 + border_width/2, back_layer_thickness + 1])
        cube([15, 8, 6], center=true);
}

// ==== ASSEMBLY ====

module complete_sign() {
    // Front layer (print in clear/transparent material)
    color("clear", 0.7)
        translate([0, 0, middle_layer_thickness + back_layer_thickness])
            front_layer();
    
    // Middle layer (print in opaque material)
    color("white")
        translate([0, 0, back_layer_thickness])
            middle_layer();
    
    // Back layer with LED holders (print in opaque material)
    color("gray")
        back_layer();
}

// ==== PRINTING MODULES ====

module print_front_layer() {
    front_layer();
}

module print_middle_layer() {
    middle_layer();
}

module print_back_layer() {
    back_layer();
}

// ==== MAIN RENDER CONTROL ====

// Uncomment the module you want to render/print:

// For assembly preview:
complete_sign();

// For individual layer printing:
// print_front_layer();    // Print this in clear/transparent material
// print_middle_layer();   // Print this in white or light-colored material
// print_back_layer();     // Print this in any opaque material

// ==== PRINTING INSTRUCTIONS ====
/*
PRINTING INSTRUCTIONS:

1. FRONT LAYER (Clear Face):
   - Print in transparent PETG, clear PLA, or clear resin
   - Use 0.2mm layer height for smooth finish
   - Print face-down for best surface quality
   - No supports needed

2. MIDDLE LAYER (Light Diffusion):
   - Print in white or light-colored PLA/PETG
   - Use 0.2-0.3mm layer height
   - 20-30% infill for good light diffusion
   - No supports needed

3. BACK LAYER (LED Holders):
   - Print in any opaque material (PLA/PETG/ABS)
   - Use 0.3mm layer height for faster printing
   - Print with LED channels facing up
   - Use supports for overhangs if needed

ASSEMBLY:
1. Install LED strips in the back layer channels
2. Connect wiring through the wire management channels
3. Stack layers: back → middle → front
4. Secure with screws through mounting holes
5. Connect power to LED strips

LED STRIP REQUIREMENTS:
- 10mm wide LED strips (standard 12V/24V)
- Cut to fit sign height minus borders
- Space strips 100mm apart as designed
- Use adhesive backing or additional clips if needed
*/ 