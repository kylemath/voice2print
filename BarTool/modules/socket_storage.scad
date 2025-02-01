include <../config.scad>

// Socket Parameters
SOCKET_LENGTH = 24.8;        // Length of sockets
BLOCK_DEPTH = 25;          // Total height of socket block
SOCKET_DEPRESSION = 20;      // How deep sockets sit in the block
SOCKET_SPACING = 2;         // Space between socket edges
SIDE_SPACE = 15;            // Space between socket array and side of case
CORNER_RADIUS = 3;         // Radius for rounded corners
// Socket sizes (diameter, not drive size)
SOCKET_DIAMETERS = [17.82, 16.66, 13.73, 11.68, 11.61, 11.69];  // 1/2", 12mm, 10mm, 8mm, 6mm, 1/4" sockets

// Hex Bit Parameters
HEX_BIT_LENGTH = 25;        // Standard length for hex bits
HEX_BIT_DIAMETER = 6.35;    // Standard 1/4" hex bit diameter
HEX_DEPRESSION = 20;        // How deep bits sit in the block
HEX_SPACING = 3;           // Space between hex holes
HEX_COUNT = 10;             // Number of hex bits to store

// Helper function to sum an array
function sum(v, i = 0, r = 0) = i < len(v) ? sum(v, i + 1, r + v[i]) : r;

// Calculate total width of sockets plus spacing
function total_width() = sum(SOCKET_DIAMETERS) + (SOCKET_SPACING * (len(SOCKET_DIAMETERS)-1));

// Module for creating socket storage
module socket_storage(x=0, y=0, z=0) {
    translate([x, y, z]) {
        difference() {
            // Main storage block with rounded corners
            minkowski() {
                translate([0, 0, BLOCK_DEPTH/2])
                cube([CASE_WIDTH + WALL_THICKNESS/2 - CORNER_RADIUS*2, 
                      CASE_DEPTH + WALL_THICKNESS/2 - CORNER_RADIUS*2, 
                      BLOCK_DEPTH - CORNER_RADIUS*2], center=true);
                sphere(r=CORNER_RADIUS);
            }
            
            // Socket depressions (sharp edges)
            translate([0, -CASE_DEPTH/2 + 3 + SIDE_SPACE, 0]) {
                // Find the largest diameter to use as reference for alignment
                max_diameter = max([for (d = SOCKET_DIAMETERS) d]);
                
                for(i = [0:len(SOCKET_DIAMETERS)-1]) {
                    pos_x = (i == 0) ? SOCKET_DIAMETERS[0]/2 :
                           sum([for(j = [0:i-1]) SOCKET_DIAMETERS[j]]) + 
                           (i * SOCKET_SPACING) + 
                           SOCKET_DIAMETERS[i]/2;
                    
                    // Calculate Y offset to align tops (negative to move smaller sockets down)
                    y_offset = -(max_diameter - SOCKET_DIAMETERS[i])/2;
                    
                    translate([pos_x, y_offset, BLOCK_DEPTH - SOCKET_DEPRESSION/2])
                    rotate([0, 0, 0])
                    cylinder(d=SOCKET_DIAMETERS[i], 
                            h=SOCKET_LENGTH, 
                            center=true);
                }
            }
            
            // Hex bit holes (in a row behind the sockets)
            translate([CASE_WIDTH/4.2-(HEX_COUNT * (HEX_BIT_DIAMETER + HEX_SPACING))/2 + HEX_BIT_DIAMETER/2, 
                      CASE_DEPTH/2.8, 
                      BLOCK_DEPTH - HEX_DEPRESSION/2])
            for(i = [0:HEX_COUNT-1]) {
                translate([i * (HEX_BIT_DIAMETER + HEX_SPACING), 0, 0])
                cylinder(d=HEX_BIT_DIAMETER, h=HEX_BIT_LENGTH, center=true, $fn=6);
            }
        }
    }
}

// // For testing individual component
// if ($preview) {
//     socket_storage();
// }

