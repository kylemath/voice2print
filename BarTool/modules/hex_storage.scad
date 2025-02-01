include <../config.scad>

// Hex Bit Parameters
HEX_BIT_LENGTH = 25;        // Standard length for hex bits
HEX_BIT_DIAMETER = 6.35;    // Standard 1/4" hex bit diameter
HEX_DEPRESSION = 20;        // How deep bits sit in the block
HEX_SPACING = 2;           // Space between hex holes
HEX_COUNT = 6;             // Number of hex bits to store

// Module for creating hex bit storage
module hex_storage(x=0, y=0, z=0) {
    translate([x, y, z]) {
        difference() {
            // Main storage block with rounded corners
            minkowski() {
                translate([0, 0, BLOCK_DEPTH/2])
                cube([CASE_WIDTH + WALL_THICKNESS/2 - CORNER_RADIUS*2, 
                      CASE_DEPTH/3, 
                      BLOCK_DEPTH - CORNER_RADIUS*2], center=true);
                sphere(r=CORNER_RADIUS);
            }
            
            // Hex bit holes
            translate([-(HEX_COUNT * (HEX_BIT_DIAMETER + HEX_SPACING))/2 + HEX_BIT_DIAMETER/2, 0, BLOCK_DEPTH - HEX_DEPRESSION/2])
            for(i = [0:HEX_COUNT-1]) {
                translate([i * (HEX_BIT_DIAMETER + HEX_SPACING), 0, 0])
                cylinder(d=HEX_BIT_DIAMETER, h=HEX_BIT_LENGTH, center=true, $fn=6);
            }
        }
    }
}

// For testing individual component
// if ($preview) {
//     hex_storage();
// } 