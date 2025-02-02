include <../config.scad>

// Wrench Parameters
WRENCH_HEAD_DEPTH = 26;     // Depth of socket head section
WRENCH_HANDLE_DEPTH = 18;   // Depth of handle section
WRENCH_HEAD_LENGTH = 33.33; // Length of the head section
WRENCH_TAPER_LENGTH = 16;   // Length of transition section
WRENCH_SCALE = 1;          // Scale factor for SVG
WRENCH_POSITION_X = -25;    // X position adjustment
WRENCH_POSITION_Y = 22;     // Y position adjustment

// Pliers Parameters
PLIERS_HEAD_DEPTH = 10;     // Depth of pliers head section
PLIERS_HANDLE_DEPTH = 15;   // Depth of handle section
PLIERS_HEAD_LENGTH = 33.33; // Length of the head section
PLIERS_TAPER_LENGTH = 16;   // Length of transition section
PLIERS_SCALE = 1;          // Scale factor for SVG
PLIERS_POSITION_X = 30;    // X position adjustment (opposite side of wrench)
PLIERS_POSITION_Y = -10;    // Y position adjustment

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
            translate([0, -CASE_DEPTH/2  + SIDE_SPACE, 0]) {
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
            translate([CASE_WIDTH/2.8-(HEX_COUNT * (HEX_BIT_DIAMETER + HEX_SPACING))/2 + HEX_BIT_DIAMETER/2, 
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
            
            // Pliers depression
            translate([10, -8, 0]) {
                rotate([0, 0, 192]) {
                    // Single pliers depression
                    translate([PLIERS_POSITION_X, PLIERS_POSITION_Y, BLOCK_DEPTH - PLIERS_HEAD_DEPTH])
                    linear_extrude(height = PLIERS_HEAD_DEPTH + 1)
                    scale([PLIERS_SCALE, PLIERS_SCALE, 1])
                    intersection() {
                        import(file = "/Users/kylemathewson/voice2print/BarTool/assets/plier_outline.svg", center = true);
                        // Add bounding box to ensure solid geometry
                        translate([0, 0, 0])
                        square([150, 50], center=true);
                    }
                }
            }

            // 1/4" extension depression
            translate([CASE_WIDTH/2 - EXT_TOTAL_LENGTH/1.5, -10, BLOCK_DEPTH - EXT_DEPRESSION/2]) {
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

            translate([-4, 0, 0])    {
                // Wrench depression -HEAD  (shallower)
                translate([WRENCH_POSITION_X, WRENCH_POSITION_Y, BLOCK_DEPTH - WRENCH_HANDLE_DEPTH+8])
                linear_extrude(height = 10)
                scale([WRENCH_SCALE, WRENCH_SCALE, 1])
                intersection() {
                    import(file = "/Users/kylemathewson/voice2print/BarTool/assets/wrench_outline.svg", layer = "", center = true, dpi = 96);
                    translate([-WRENCH_HEAD_LENGTH - WRENCH_TAPER_LENGTH + 11.9 + 16-.1, -20, 0])
                    square([120, 50]);
                }
        
                for (i = [0:1:16]) {
                    // Wrench depression -HEAD  (shallower)
                    translate([WRENCH_POSITION_X, WRENCH_POSITION_Y, BLOCK_DEPTH - WRENCH_HANDLE_DEPTH+8-((8/18)*(i+1))])
                    linear_extrude(height = 14+i)
                    scale([WRENCH_SCALE, WRENCH_SCALE, 1])
                    intersection() {
                        import(file = "/Users/kylemathewson/voice2print/BarTool/assets/wrench_outline.svg", layer = "", center = true, dpi = 96);
                        translate([-WRENCH_HEAD_LENGTH - WRENCH_TAPER_LENGTH + 11.9+16-i, -20, 0])
                        square([1.1, 50]);
                    }
                }
        
                
                // Wrench depression -HEAD  (shallower)
                translate([WRENCH_POSITION_X, WRENCH_POSITION_Y, BLOCK_DEPTH - WRENCH_HEAD_DEPTH+2])
                linear_extrude(height = WRENCH_HEAD_DEPTH+2)
                scale([WRENCH_SCALE, WRENCH_SCALE, 1])
                intersection() {
                    import(file = "/Users/kylemathewson/voice2print/BarTool/assets/wrench_outline.svg", layer = "", center = true, dpi = 96);
                    translate([-WRENCH_HEAD_LENGTH - WRENCH_TAPER_LENGTH -88, -20, 0])
                    square([100, 100]);
                }
            }
            
          
       
               
        }
    }
}     

// // For testing individual component
// if ($preview) {
//     socket_storage();
// }

