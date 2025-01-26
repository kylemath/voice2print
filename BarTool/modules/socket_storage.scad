include <../config.scad>

// Socket Parameters
SOCKET_LENGTH = 24.8;        // Length of sockets
SOCKET_DEPTH = 15;          // Total height of socket block
SOCKET_DEPRESSION = 3;      // How deep sockets sit in the block
SOCKET_SPACING = 2;         // Space between socket edges
SIDE_SPACE = 15;            // Space between socket array and side of case
CORNER_RADIUS = 3;         // Radius for rounded corners
// Socket sizes (diameter, not drive size)
SOCKET_DIAMETERS = [11.85, 14.6, 16.75, 19.66];  // 8mm, 10mm, 12mm, 14mm sockets

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
                translate([0, 0, SOCKET_DEPTH/2])
                cube([CASE_WIDTH + WALL_THICKNESS/2 - CORNER_RADIUS*2, 
                      CASE_DEPTH + WALL_THICKNESS/2 - CORNER_RADIUS*2, 
                      SOCKET_DEPTH - CORNER_RADIUS*2], center=true);
                sphere(r=CORNER_RADIUS);
            }
            
            // Socket depressions (sharp edges)
            translate([0, -CASE_DEPTH/2 + SIDE_SPACE, 0])
            for(i = [0:len(SOCKET_DIAMETERS)-1]) {
                pos_x = (i == 0) ? SOCKET_DIAMETERS[0]/2 :
                       sum([for(j = [0:i-1]) SOCKET_DIAMETERS[j]]) + 
                       (i * SOCKET_SPACING) + 
                       SOCKET_DIAMETERS[i]/2;
                
                translate([pos_x, 0, SOCKET_DEPTH - SOCKET_DEPRESSION/2])
                rotate([90, 0, 0])
                cylinder(d=SOCKET_DIAMETERS[i], 
                        h=SOCKET_LENGTH, 
                        center=true);
            }
        }
    }
}

// // For testing individual component
// if ($preview) {
//     socket_storage();
// }

