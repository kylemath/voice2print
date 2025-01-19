// Basic parameters
$fn = 50;  // Smoothness of curves

// Text parameters
text_height = 20;      // Height of the text
extrusion_depth = 4;   // How thick/deep the text will be

// Individual letter spacing adjustments
c_l_spacing = .85;    // Space between C and L
l_a_spacing = 0.7;    // Space between L and A
a_i_spacing = 2;    // Space between A and I
i_r_spacing = 0.5;    // Space between I and R
r_e_spacing = .95;    // Space between R and E

// Font parameters
font = "Miju:style=Bold";  // Using Miju font

// Create the 3D text by combining individual letters
linear_extrude(height = extrusion_depth, center = true) {
    translate([0, 0, 0]) {
        // Calculate total width for centering
        total_width = 
            len("C") * text_height * 0.6 +
            len("L") * text_height * 0.6 * (c_l_spacing) +
            len("A") * text_height * 0.6 * (l_a_spacing) +
            len("I") * text_height * 0.6 * (a_i_spacing) +
            len("R") * text_height * 0.6 * (i_r_spacing) +
            len("E") * text_height * 0.6 * (r_e_spacing);
        
        // Center the entire text
        translate([-total_width/2, 0, 0]) {
            // Individual letters with custom spacing
            text("C", size = text_height, font = font);
            translate([text_height * 0.6 * (c_l_spacing), 0, 0])
                text("L", size = text_height, font = font);
            translate([text_height * 0.6 * (c_l_spacing + l_a_spacing), 0, 0])
                text("A", size = text_height, font = font);
            translate([text_height * 0.6 * (c_l_spacing + l_a_spacing + a_i_spacing), 0, 0])
                text("I", size = text_height, font = font);
            translate([text_height * 0.6 * (c_l_spacing + l_a_spacing + a_i_spacing + i_r_spacing), 0, 0])
                text("R", size = text_height, font = font);
            translate([text_height * 0.6 * (c_l_spacing + l_a_spacing + a_i_spacing + i_r_spacing + r_e_spacing), 0, 0])
                text("E", size = text_height, font = font);
        }
    }
}

// Optional: Add a base plate
// Uncomment these lines if you want a base plate
/*
translate([0, 0, -extrusion_depth/2 - 1])
    cube([text_height * 3.5, text_height * 1.2, 2], center = true);
*/ 