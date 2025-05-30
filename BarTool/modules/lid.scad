// Lid module for BarTool
include <../config.scad>
include <../modules/socket_storage.scad>  // Include for tool position variables

// Lid specific parameters
LID_OVERLAP = 5;  // How much the lid overlaps the base on each side
LID_THICKNESS = 10;  // Total thickness of the lid
TOOL_DEPRESSION_DEPTH = 8;  // Depth of tool depressions in lid
LID_WALL_EXTRA_WIDTH = 2.5;  // Extra width for the walls (2.5mm on each side)
LID_WALL_HEIGHT = 10;  // Wall height (adjusted to 10mm)
LID_WALL_THICKNESS = 3;  // Wall thickness
LID_TOLERANCE = 0.1;  // Tolerance between the lid walls and the base (0.3mm gap)
LID_CHAMFER = 2;  // Size of the chamfer on the lid's outside face
HEX_HOLE_EXTRA_CLEARANCE = 0.5;  // Additional clearance for hex bit holes (0.5mm wider)
HEX_HOLE_DEPTH = 9;  // Deeper hex holes (8mm)

// Logo parameters
LOGO_FILE = "/Users/kylemathewson/voice2print/BarTool/assets/ChatGPT-Image-Apr-25_-2025_-11_30_11-AM.svg";  // Path to PADPAK SVG file
LOGO_SCALE = 0.35;  // Scale factor for the logo (increased by 4x from 0.15)
LOGO_DEPTH = 2;  // Depth of the logo embossing (mm)
LOGO_POSITION_X = 0;  // X position of logo center
LOGO_POSITION_Y = 0;  // Y position of logo center
LOGO_ROTATION = 0;  // Rotation angle for logo

module lid() {
    translate([-CASE_WIDTH, -5, -10]) {
        rotate([180, 0, 0]) {
            difference() {
                union() {
                    // Main lid plate with chamfered outer face
                    translate([0, 0, -14]) {
                        minkowski() {
                            cube([CASE_WIDTH + LID_OVERLAP*2 + LID_WALL_EXTRA_WIDTH, 
                            CASE_DEPTH + LID_OVERLAP*2 + LID_WALL_EXTRA_WIDTH, 
                            18], center=true);
                            sphere(r=LID_CHAMFER, $fn=30);
                        }
                    }
                    
                    // Add walls extending from the lid
                    difference() {
                        // Outer wall - extending from -LID_THICKNESS to LID_WALL_HEIGHT
                        translate([0, 0, -4])
                        linear_extrude(height = LID_WALL_HEIGHT + LID_THICKNESS)
                        difference() {
                            // Outer perimeter
                            square([CASE_WIDTH + LID_OVERLAP*2 + LID_WALL_EXTRA_WIDTH*2, 
                                    CASE_DEPTH + LID_OVERLAP*2 + LID_WALL_EXTRA_WIDTH*2], center=true);
                            
                            // Inner cutout (with added tolerance for fit)
                            square([CASE_WIDTH + LID_OVERLAP*2 + LID_WALL_EXTRA_WIDTH*2 - LID_WALL_THICKNESS*2 + LID_TOLERANCE*2, 
                                    CASE_DEPTH + LID_OVERLAP*2 + LID_WALL_EXTRA_WIDTH*2 - LID_WALL_THICKNESS*2 + LID_TOLERANCE*2], center=true);
                        }
                    }
                }
                
                // Socket depressions
                translate([0, -CASE_DEPTH/2 + SIDE_SPACE - 2, 0]) {
                    for(i = [0:len(SOCKET_DIAMETERS)-1]) {
                        translate([
                            (i == 0) ? SOCKET_DIAMETERS[0]/2 :
                            sum([for(j = [0:i-1]) SOCKET_DIAMETERS[j]]) + 
                            (i * SOCKET_SPACING) + 
                            SOCKET_DIAMETERS[i]/2,
                            0,
                            -TOOL_DEPRESSION_DEPTH
                        ])
                        // +1mm diameter tolerance for socket fit
                        // +0.1mm height tolerance to ensure clean cuts
                        cylinder(d=SOCKET_DIAMETERS[i] + 1, h=TOOL_DEPRESSION_DEPTH + 0.1);
                    }
                }
                
                // Top row socket depressions
                translate([16, -CASE_DEPTH/2 + SIDE_SPACE + 16, 0]) {
                    for(i = [0:len(TOP_SOCKET_DIAMETERS)-1]) {
                        translate([
                            (i == 0) ? TOP_SOCKET_DIAMETERS[0]/2 :
                            sum([for(j = [0:i-1]) TOP_SOCKET_DIAMETERS[j]]) + 
                            (i * TOP_SOCKET_SPACING) + 
                            TOP_SOCKET_DIAMETERS[i]/2,
                            0,
                            -TOOL_DEPRESSION_DEPTH
                        ])
                        cylinder(d=TOP_SOCKET_DIAMETERS[i] + 1, h=TOOL_DEPRESSION_DEPTH + 0.1);
                    }
                }
                
                // Imperial socket depressions
                translate([-95, -CASE_DEPTH/2 + SIDE_SPACE + 20, 0]) {
                    for(i = [0:len(IMPERIAL_SOCKET_DIAMETERS)-1]) {
                        translate([
                            (i == 0) ? IMPERIAL_SOCKET_DIAMETERS[0]/2 :
                            sum([for(j = [0:i-1]) IMPERIAL_SOCKET_DIAMETERS[j]]) + 
                            (i * IMPERIAL_SOCKET_SPACING) + 
                            IMPERIAL_SOCKET_DIAMETERS[i]/2,
                            0,
                            -TOOL_DEPRESSION_DEPTH
                        ])
                        cylinder(d=IMPERIAL_SOCKET_DIAMETERS[i] + 1, h=TOOL_DEPRESSION_DEPTH + 0.1);
                    }
                }
                
                // Hex bit depressions - wider and deeper
                translate([CASE_WIDTH/2.8-(HEX_COUNT * (HEX_BIT_DIAMETER + HEX_SPACING))/2 + HEX_BIT_DIAMETER/2 + 5,
                        CASE_DEPTH/2.8+2,
                        0]) {
                    for(row = [0:2]) {
                        for(i = [0:HEX_COUNT-1]) {
                            translate([
                                i * (HEX_BIT_DIAMETER + HEX_SPACING) + 
                                (row == 1 ? -HEX_SPACING : 0),
                                -row * HEX_ROW_SPACING,
                                -HEX_HOLE_DEPTH
                            ])
                            cylinder(d=HEX_BIT_DIAMETER + 1 + HEX_HOLE_EXTRA_CLEARANCE, h=HEX_HOLE_DEPTH + 0.1);
                        }
                    }
                }

                // Tool depressions
                translate([0, 0, 0]) {
                    // Pliers depression (original)
                    translate([18, -3, -TOOL_DEPRESSION_DEPTH]) {
                        rotate([0, 0, 195]) {
                            translate([PLIERS_POSITION_X, PLIERS_POSITION_Y, 0])
                            linear_extrude(height = TOOL_DEPRESSION_DEPTH + 0.1)
                            scale([PLIERS_SCALE + 0.04, PLIERS_SCALE + 0.04, 1]) // Add 1mm tolerance by scaling up ~4%
                            intersection() {
                                import(file = "/Users/kylemathewson/voice2print/BarTool/assets/plier_outline.svg", center = true);
                                square([150, 50], center=true);
                            }
                        }
                    }

                    // Wrench depression (original)
                    translate([-4, 0, -TOOL_DEPRESSION_DEPTH]) {
                        translate([WRENCH_POSITION_X, WRENCH_POSITION_Y, 0])
                        linear_extrude(height = TOOL_DEPRESSION_DEPTH + 0.1)
                        scale([WRENCH_SCALE + 0.04, WRENCH_SCALE + 0.04, 1]) // Add 1mm tolerance by scaling up ~4%
                        import(file = "/Users/kylemathewson/voice2print/BarTool/assets/wrench_outline.svg", center = true);
                    }
                

                    // Extension depression (original)
                    rotate([0, 0, 200]) {
                        translate([CASE_WIDTH/2 - EXT_TOTAL_LENGTH +33, -5, -TOOL_DEPRESSION_DEPTH/2+1]) {
                            union() {
                                // Create the entire extension shape using hull() between segments
                                hull() {
                                    // Female end
                                    translate([EXT_TOTAL_LENGTH/2 - EXT_FEMALE_LENGTH/2+5, 0, 0])
                                    rotate([180, 90, 0])  // Rotate to lay flat
                                    cylinder(d=EXT_FEMALE_DIAMETER + 1, h=EXT_FEMALE_LENGTH, center=true);
                                    
                                    // Start of main shaft (female side)
                                    translate([EXT_TOTAL_LENGTH/2 - EXT_FEMALE_LENGTH - EXT_FEMALE_TAPER+5, 0, 0])
                                    rotate([180, 90, 0])  // Rotate to lay flat
                                    cylinder(d1=EXT_FEMALE_DIAMETER + 1, d2=EXT_MAIN_DIAMETER + 1, h=EXT_FEMALE_TAPER, center=true);
                                }
                            
                                // Main shaft
                                // Male side of main shaft
                                translate([-EXT_TOTAL_LENGTH/2 + EXT_MALE_LENGTH + EXT_MALE_TAPER+53.5 , 0, 0])
                                rotate([180, 90, 0])
                                cylinder(d=EXT_MAIN_DIAMETER + 1, h=EXT_MAIN_LENGTH);
                            
                                // Male end transition
                                // End of main shaft
                                translate([-EXT_TOTAL_LENGTH/2 + EXT_MALE_LENGTH + EXT_MALE_TAPER+ EXT_MALE_TAPER, 0, 0])
                                rotate([180, 90, 0])  // Rotate to lay flat
                                cylinder(d1=EXT_MAIN_DIAMETER + 1, d2=EXT_MALE_WIDTH+2, h=EXT_MALE_TAPER, center=true);
                                
                                // Male square end
                                translate([-EXT_TOTAL_LENGTH/2 + EXT_MALE_LENGTH/2 + EXT_MALE_TAPER +1.6, 0, 0])
                                rotate([180, 90, 0])  // Rotate to lay flat and 45 degrees for diamond orientation
                                cube([EXT_MALE_WIDTH + 1, EXT_MALE_WIDTH + 1, EXT_MALE_LENGTH], center=true);
                            }
                        }
                    }
                }
            }
        }
    }
}

// // For preview
// if ($preview) {
//     lid();
// } 

// Module for just the logo (for separate printing)
module logo_only() {
    difference() {
        // Create a solid rectangular block for the logo area - increased by 4x
        translate([LOGO_POSITION_X - 300, LOGO_POSITION_Y - 160, 0]) 
            cube([600, 320, LOGO_DEPTH + 0.5]);
        
        // Subtract everything except the logo shape
        difference() {
            // Large block to remove everything except where the logo is - increased to cover 4x larger logo
            translate([LOGO_POSITION_X - 400, LOGO_POSITION_Y - 400, -0.5])
                cube([800, 800, LOGO_DEPTH + 2]);
            
            // Logo shape to preserve
            translate([LOGO_POSITION_X, LOGO_POSITION_Y, 0]) {
                rotate([0, 0, LOGO_ROTATION]) {
                    linear_extrude(height = LOGO_DEPTH + 0.5)
                    scale([LOGO_SCALE, LOGO_SCALE, 1])
                    import(file = LOGO_FILE, center = true);
                }
            }
        }
    }
}

// Add the logo embossing to the top/opposite side of the lid
module lid_with_logo() {
    difference() {
        lid();
        
        // Add logo embossing on the top side of the lid
        translate([-CASE_WIDTH, -5, 0]) {  // Match the lid translation
            rotate([180, 0, 0]) {  // Match the lid rotation
                translate([LOGO_POSITION_X, LOGO_POSITION_Y, -215]) {
                    rotate([0, 0, LOGO_ROTATION]) {
                        linear_extrude(height = LOGO_DEPTH -1.7+200)
                        scale([LOGO_SCALE, LOGO_SCALE, 1])
                        import(file = LOGO_FILE, center = true);
                    }
                }
            }
        }
    }
}

// Module for lid with logo cutout
module lid_minus_logo() {
    lid_with_logo();
}

// // For preview
// if ($preview) {
//     lid_with_logo();
// } 