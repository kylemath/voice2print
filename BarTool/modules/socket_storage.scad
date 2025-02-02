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
HEX_COUNT = 5;             // Number of hex bits per row
HEX_ROW_SPACING = 15;      // Spacing between rows of hex bits

// Extension Parameters
EXT_TOTAL_LENGTH = 76.33;   // Total length of extension
EXT_MAIN_DIAMETER = 8.2;    // Main shaft diameter
EXT_MAIN_LENGTH = 50;       // Length of main section
EXT_MALE_LENGTH = 7.5;      // Length of male end
EXT_MALE_WIDTH = 6.35;      // 1/4" square male end
EXT_MALE_TAPER = 2.5;       // Taper length to male end
EXT_FEMALE_LENGTH = 13.4;   // Length of female end
EXT_FEMALE_DIAMETER = 12;   // Outer diameter of female end
EXT_FEMALE_TAPER = 3;       // Taper length to female end
EXT_DEPRESSION = 20;        // How deep extension sits in block

// Long Depression Parameters
LONG_DEPRESSION_LENGTH = 130;  // Length of the long depression
LONG_DEPRESSION_WIDTH = 13.6;  // Width of the long depression
LONG_DEPRESSION_DEPTH = 18;    // Depth of the long depression

// Triangle Depression Parameters
TRIANGLE_BASE = 76.23;        // Base length of triangle
TRIANGLE_HEIGHT = 130;        // Height of triangle
TRIANGLE_DEPTH = 10;          // Depth of depression

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
            
            // Hex bit holes (in two rows behind the sockets)
            translate([CASE_WIDTH/3-(HEX_COUNT * (HEX_BIT_DIAMETER + HEX_SPACING))/2 + HEX_BIT_DIAMETER/2, 
                      CASE_DEPTH/2.8, 
                      BLOCK_DEPTH - HEX_DEPRESSION/2]) {
                // First row (original)
                for(i = [0:HEX_COUNT-1]) {
                    translate([i * (HEX_BIT_DIAMETER + HEX_SPACING), 0, 0])
                    cylinder(d=HEX_BIT_DIAMETER, h=HEX_BIT_LENGTH, center=true, $fn=6);
                }
                // Second row (new, above the first)
                for(i = [0:HEX_COUNT-1]) {
                    translate([i * (HEX_BIT_DIAMETER + HEX_SPACING), -HEX_ROW_SPACING, 0])
                    cylinder(d=HEX_BIT_DIAMETER, h=HEX_BIT_LENGTH, center=true, $fn=6);
                }
            }
            
            // 1/4" extension depression
            translate([CASE_WIDTH/2 - EXT_TOTAL_LENGTH/1.5, -3, BLOCK_DEPTH - EXT_DEPRESSION/2]) {
                union() {

                    // Create the entire extension shape using hull() between segments
                    hull() {
                        // Female end
                        translate([EXT_TOTAL_LENGTH/2 - EXT_FEMALE_LENGTH/2+5, 0, 8])
                        rotate([180, 90, 0])  // Rotate to lay flat
                        cylinder(d=EXT_FEMALE_DIAMETER, h=EXT_FEMALE_LENGTH, center=true);
                        
                        // Start of main shaft (female side)
                        translate([EXT_TOTAL_LENGTH/2 - EXT_FEMALE_LENGTH - EXT_FEMALE_TAPER+5, 0, 8])
                        rotate([180, 90, 0])  // Rotate to lay flat
                        cylinder(d1=EXT_FEMALE_DIAMETER, d2=EXT_MAIN_DIAMETER, h=EXT_FEMALE_TAPER, center=true);
        }
                
                     // Main shaft
                    // Male side of main shaft
                    translate([-EXT_TOTAL_LENGTH/2 + EXT_MALE_LENGTH + EXT_MALE_TAPER+53.5 , 0, 8])
                    rotate([180, 90, 0])
                    cylinder(d=EXT_MAIN_DIAMETER, h=EXT_MAIN_LENGTH);
                
                
                    // Male end transition
                    // End of main shaft
                    translate([-EXT_TOTAL_LENGTH/2 + EXT_MALE_LENGTH + EXT_MALE_TAPER+ EXT_MALE_TAPER, 0, 8])
                    rotate([180, 90, 0])  // Rotate to lay flat
                    cylinder(d1=EXT_MAIN_DIAMETER, d2=EXT_MALE_WIDTH+1, h=EXT_MALE_TAPER, center=true);
                    
                    // Male square end
                    translate([-EXT_TOTAL_LENGTH/2 + EXT_MALE_LENGTH/2 + EXT_MALE_TAPER +1.6, 0, 8])
                    rotate([180, 90, 0])  // Rotate to lay flat and 45 degrees for diamond orientation
                    cube([EXT_MALE_WIDTH, EXT_MALE_WIDTH, EXT_MALE_LENGTH], center=true);
    }
}

            // Long depression
            translate([CASE_WIDTH/2 -195, CASE_DEPTH/4+2, BLOCK_DEPTH - LONG_DEPRESSION_DEPTH/2])
            cube([LONG_DEPRESSION_LENGTH, LONG_DEPRESSION_WIDTH, LONG_DEPRESSION_DEPTH], center=false);
    
            // Triangular depression
            translate([CASE_WIDTH/2 - TRIANGLE_BASE/2-155, -CASE_DEPTH/4+38, BLOCK_DEPTH - TRIANGLE_DEPTH]) {
                rotate([0, 0, -74])
                linear_extrude(height=TRIANGLE_DEPTH)
                polygon(points=[[0,0], [TRIANGLE_BASE,0], [TRIANGLE_BASE/2,TRIANGLE_HEIGHT]]);
            }
        }
    }
}

// // For testing individual component
// if ($preview) {
//     socket_storage();
// }

