// Air Filter: 373mm wide × 235mm long × 15mm tall
// Honeycomb pattern with solid border
// Created for voice2print project

// Parameters
width = 373;
length = 235;
height = 15;
border_width = 10;  // Solid border width
hex_radius = 8;     // Hexagon radius
hex_spacing = 16;   // Distance between hexagon centers

// Main module
difference() {
    // Base rectangle
    cube([width, length, height]);
    
    // Honeycomb cutouts
    translate([border_width, border_width, -0.5])
        honeycomb_pattern(width - 2*border_width, length - 2*border_width, height + 1);
}

// Module to create honeycomb pattern
module honeycomb_pattern(pattern_width, pattern_length, pattern_height) {
    rows = floor(pattern_length / (hex_spacing * 0.866));
    cols = floor(pattern_width / hex_spacing);
    
    for (row = [0 : rows-1]) {
        for (col = [0 : cols-1]) {
            // Offset every other row by half the horizontal spacing
            offset_x = (row % 2) * hex_spacing/2;
            offset_y = hex_spacing/2;
            x = col * hex_spacing + offset_x/2;
            y = row * hex_spacing * 0.866 * .5;
            
            if (x >= 0 && x <= pattern_width - hex_radius*2 && 
                y >= 0 && y <= pattern_length - hex_radius*2) {
                translate([x + hex_radius, y + hex_radius, 0])
                    hexagon(hex_radius, pattern_height);
            }
        }
    }
}

// Module to create a hexagon
module hexagon(radius, height) {
    cylinder(h=height, r=radius, $fn=6);
} 