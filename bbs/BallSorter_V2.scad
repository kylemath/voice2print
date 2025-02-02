// Parameters for customization

slope_angle = 15;      // Keep same angle
track_width = 40;      // Reduced from 80
wall_height = 60;      // Reduced from 50
wall_thickness = 2;    // Reduced from 3

// Hole sizes - smallest to largest (converted from inches to mm)
hole_sizes = [
    2.38,   // 3/32" (90pcs)
    3.18,   // 1/8"  (70pcs)
    3.97,   // 5/32" (60pcs)
    4.76,   // 3/16" (50pcs)
    5.56,   // 7/32" (50pcs)
    6.35,   // 1/4"  (50pcs)
    7.14,   // 9/32" (30pcs)
    7.94,   // 5/16" (30pcs)
    8.73,   // 11/32" (30pcs)
    9.53,   // 3/8"  (20pcs)
    10.32   // 13/32" (20pcs)
];  

// Future expansion could include:
// 5.56,   // 7/32"
// 6.35,   // 1/4"
// 7.14,   // 9/32"
// 7.94,   // 5/16"
// 8.73,   // 11/32"
// 9.53,   // 3/8"
// 10.32   // 13/32" - largest
hole_spacing = 15;     // Reduced from 25
step_height = 60;      // Reduced from 50
collection_depth = 15;  // Reduced from 30

// New parameters
bevel_size = 1;      // Size of hole bevels
bin_taper = 8;         // Reduced from 15
support_height = 10;    // Reduced from 20
runway_length = 30;    // Reduced from 100

// Add new parameters for track width
track_width_start = 30;   // Reduced from 60
track_width_end = 60;    // Reduced from 120

// Update funnel width to match the widened runway
funnel_end_width = track_width_end + 20;  // Reduced from +40

// Update wall thickness for floor
floor_thickness = 5;      // Reduced from 10

// Add at the top with other parameters
tray_extension = 120;      // Base tray extension for largest ball size

// Function to calculate tray extension based on ball size index
function get_tray_extension(i) = 
    tray_extension * ((i * 0.75 / len(hole_sizes)) + 0.25);  // Progressive reduction in length, smallest balls get shortest trays

// Add new parameter
tray_drop = 15;  // How much lower the collection trays are from main track

// Add new parameter for tray floor thickness
tray_floor_thickness = 2;  // Reduced from 3

module funnel() {
    // Main funnel shape with rounded transition
    rotate([slope_angle, 0, 0])
    translate([0, funnel_depth, 0])
    mirror([0, 1, 0])
    union() {
        difference() {
            hull() {
                translate([0, 0, 0])
                    cube([funnel_width, wall_thickness, 1]);
                translate([funnel_width/2 - funnel_end_width/2, funnel_depth, 0])
                    cube([funnel_end_width, wall_thickness, 1]);
            }
            
            // Interior cutout
            translate([wall_thickness, -1, wall_thickness])
                hull() {
                    translate([0, 0, 0])
                        cube([funnel_width - 2*wall_thickness, wall_thickness+2, 1]);
                    translate([funnel_width/2 - funnel_end_width/2 + wall_thickness, funnel_depth, 0])
                        cube([funnel_end_width - 2*wall_thickness, wall_thickness+2, 1]);
                }
        }
        
        // Side walls - rotated
        translate([0, 0, 0])
        rotate([0, 0, -12.5])
            cube([wall_thickness, funnel_depth, wall_height]);
        
        translate([funnel_width, 0, 0])
        rotate([0, 0, 12.5])
            cube([wall_thickness, funnel_depth, wall_height]);
    }
}

module sorting_track() {
    function get_track_width(i) = 
        track_width_start + (i * ((track_width_end - track_width_start) / len(hole_sizes)));
    
    difference() {
        union() {
            // Base track with steps - now with varying width and thicker floor
            for(i = [0:len(hole_sizes)]) {  // Changed to include runway
                width = get_track_width(i);
                next_width = (i < len(hole_sizes)) ? get_track_width(i + 1) : funnel_end_width;
                
                // Trapezoidal track section
                translate([0, i * hole_spacing, -80])
                hull() {
                    translate([(track_width_start - width)/2, 0, 0])
                        cube([width, 0.1, floor_thickness]);  // Thicker floor
                    translate([(track_width_start - next_width)/2, 
                              (i == len(hole_sizes)) ? runway_length : hole_spacing, 0])
                        cube([next_width, 0.1, floor_thickness]);  // Thicker floor
                }
                
                // Vertical wall with holes
                translate([0, (i + 1) * hole_spacing, -80]) {
                    if(i < len(hole_sizes)) {  // Only create walls if not runway section
                        difference() {
                            // Wall - using next_width
                            translate([(track_width_start - next_width)/2, -wall_thickness, 0])
                                cube([next_width, wall_thickness, step_height + wall_thickness]);
                            
                            // Paired holes in wall - now with 4 holes
                            local_spacing = hole_sizes[i] * 1.5;
                            outer_spacing = local_spacing * 2.5;  // Wider spacing for outer holes

                            // Inner pair of holes
                            translate([track_width_start/2 - local_spacing/2.5, -wall_thickness-1, 5.5+(hole_sizes[i]/2)]) {
                                rotate([-90, 0, 0])
                                    cylinder(h=wall_thickness+2, d=hole_sizes[i], $fn=32);
                            }
                            translate([track_width_start/2 + local_spacing/2.5, -wall_thickness-1, 5.5+(hole_sizes[i]/2)]) {
                                rotate([-90, 0, 0])
                                    cylinder(h=wall_thickness+2, d=hole_sizes[i], $fn=32);
                            }

                            // Outer pair of holes
                            translate([track_width_start/2 - outer_spacing/2, -wall_thickness-1, 5.5+(hole_sizes[i]/2)]) {
                                rotate([-90, 0, 0])
                                    cylinder(h=wall_thickness+2, d=hole_sizes[i], $fn=32);
                            }
                            translate([track_width_start/2 + outer_spacing/2, -wall_thickness-1, 5.5+(hole_sizes[i]/2)]) {
                                rotate([-90, 0, 0])
                                    cylinder(h=wall_thickness+2, d=hole_sizes[i], $fn=32);
                            }
                        }
                    }
                }
            }
            
            // Side walls (including runway) - now angled
            for(i = [0:len(hole_sizes)]) {  // Changed to include runway
                width = get_track_width(i);
                next_width = (i < len(hole_sizes)) ? get_track_width(i + 1) : funnel_end_width;
                
                // Left wall
                hull() {
                    translate([(track_width_start - width)/2, i * hole_spacing, -80])
                        cube([wall_thickness, 0.1, wall_height]);
                    translate([(track_width_start - next_width)/2, 
                              (i == len(hole_sizes)) ? (i * hole_spacing + runway_length) : (i + 1) * hole_spacing, -80])
                        cube([wall_thickness, 0.1, wall_height]);
                }
                
                // Right wall with exit holes
                difference() {
                    hull() {
                        translate([(track_width_start + width)/2 - wall_thickness, i * hole_spacing, -80])
                            cube([wall_thickness, 0.1, wall_height]);
                        translate([(track_width_start + next_width)/2 - wall_thickness, 
                                  (i == len(hole_sizes)) ? (i * hole_spacing + runway_length) : (i + 1) * hole_spacing, -80])
                            cube([wall_thickness, 0.1, wall_height]);
                    }
                    
                    // Exit holes - only add if not runway section
                    if(i < len(hole_sizes)) {
                        translate([
                            (track_width_start + width)/2 - wall_thickness/2, 
                            i * hole_spacing + hole_spacing/2  -1, 
                            -81 + step_height/2 - (20-(1.5*i)) 
                        ])
                        rotate([0, 90, 0])
                        cylinder(h=wall_thickness+10, d=hole_sizes[i], $fn=32, center=true);
                    }
                }
            }
            
            // Final wall at narrow end
            translate([(track_width_start - track_width_start)/2, 0, -80]) {
                translate([0, -wall_thickness, 0])
                    cube([track_width_start, wall_thickness, step_height + wall_thickness]);
            }

            // New wall at funnel end
            translate([(track_width_start - funnel_end_width)/2, len(hole_sizes) * hole_spacing + runway_length, -80]) {
                translate([0, 0, 0])
                    cube([funnel_end_width, wall_thickness, step_height + wall_thickness]);
            }          

            // Collection trays extending from side exits
            for(i = [0:len(hole_sizes)-1]) {
                width = get_track_width(i);
                next_width = get_track_width(i + 1);
                
                // Calculate dynamic tray extension for this segment
                local_tray_extension = get_tray_extension(i);
                
                // Create collection tray for each segment - with thinner floor
                hull() {
                    translate([(track_width_start + width)/2, i * hole_spacing, -80])
                        cube([local_tray_extension, 0.1, tray_floor_thickness]);
                    translate([(track_width_start + next_width)/2, (i + 1) * hole_spacing, -80])
                        cube([local_tray_extension, 0.1, tray_floor_thickness]);
                }
                
                // Front wall of tray (unchanged height)
                hull() {
                    translate([(track_width_start + width)/2 + local_tray_extension - wall_thickness, i * hole_spacing, -80])
                        cube([wall_thickness, 0.1, wall_height/1.2]);
                    translate([(track_width_start + next_width)/2 + local_tray_extension - wall_thickness, (i + 1) * hole_spacing, -80])
                        cube([wall_thickness, 0.1, wall_height/1.2]);
                }
                
                // Segment separating walls (unchanged height)
                translate([(track_width_start + width)/2, i * hole_spacing - wall_thickness, -80])
                    cube([local_tray_extension, wall_thickness, wall_height/1.2]);
                translate([(track_width_start + next_width)/2, (i + 1) * hole_spacing - wall_thickness, -80])
                    cube([local_tray_extension, wall_thickness, wall_height/1.2]);
            }

          
        }
        
        // Add grooves between holes and fractals for runway
        for(i = [0:len(hole_sizes)-1]) {
            width = get_track_width(i);
            next_width = get_track_width(i + 1);
            
            // Calculate positions for both sets of grooves
            scale_factor = 0.65 + (0.45 * (width / track_width_end));

            // Special handling for the last segment's inner grooves
            local_spacing = (i == len(hole_sizes)-1) ?
                (hole_sizes[i] * 1.5) * scale_factor / 2.5 :  // More narrow for last segment (changed from no division)
                (hole_sizes[i] * 1.5) * scale_factor / 1.5;   // Normal for other segments

            // Special handling for the last segment's outer grooves
            outer_spacing = (i == len(hole_sizes)-1) ?
                local_spacing * 2.5 :  // Match the hole spacing multiplier (2.5)
                (hole_sizes[i] * 1.5) * scale_factor * 2.0;   // Normal for other segments

            // Calculate next spacings with special handling for transitions
            next_scale_factor = 0.65 + (0.45 * (next_width / track_width_end));
            next_spacing = (i < len(hole_sizes)-1) ? 
                (hole_sizes[i+1] * 1.5) * next_scale_factor / 1.5 :
                local_spacing;

            next_outer_spacing = (i < len(hole_sizes)-1) ? 
                (hole_sizes[i+1] * 1.5) * next_scale_factor * 2.0 :
                local_spacing * 2.5;  // Match the hole spacing multiplier (2.5)
            
            // Calculate center points
            start_center = (track_width_start - width)/2 + width/2;
            end_center = (track_width_start - next_width)/2 + next_width/2;
            
            start_y = i * hole_spacing;
            end_y = (i + 1) * hole_spacing;
            
            translate([0, 0, -80 + floor_thickness - 1]) {
                if(i == len(hole_sizes)-1) {
                    // Regular grooves for the last section
                    // Inner grooves - less narrowing and 5mm more lateral at bottom
                    hull() {
                        translate([track_width_start/2 - local_spacing/2.5 - 2, start_y, 0])  // Start position
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 - (local_spacing/2.5 + 4), end_y, 0])  // End 5mm more outward
                            cylinder(h=1.5, d=4, $fn=32);
                    }
                    hull() {
                        translate([track_width_start/2 + local_spacing/2.5 + 2, start_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 + (local_spacing/2.5 + 4), end_y, 0])  // End 5mm more outward
                            cylinder(h=1.5, d=4, $fn=32);
                    }

                    // Outer grooves - reduce spread by 10mm
                    hull() {
                        translate([track_width_start/2 - outer_spacing, start_y, 0])      // Start position
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 - (outer_spacing * 1.2), end_y, 0])  // Reduced from 1.5 to 1.2
                            cylinder(h=1.5, d=4, $fn=32);
                    }
                    hull() {
                        translate([track_width_start/2 + outer_spacing, start_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 + (outer_spacing * 1.2), end_y, 0])  // Reduced from 1.5 to 1.2
                            cylinder(h=1.5, d=4, $fn=32);
                    }

                    // Add runway grooves leading to holes
                    // Inner left hole groove
                    hull() {
                        translate([track_width_start/2 - local_spacing/1, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 - local_spacing, end_y + runway_length * 0.8, 0])
                            cylinder(h=1.5, d=hole_sizes[len(hole_sizes)-1] * 1.2, $fn=32);  // Match hole size
                    }
                    // Inner right hole groove
                    hull() {
                        translate([track_width_start/2 + local_spacing/1, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 + local_spacing/1, end_y + runway_length * 0.8, 0])
                            cylinder(h=1.5, d=hole_sizes[len(hole_sizes)-1] * 1.2, $fn=32);  // Match hole size
                    }
                    
                    // Outer left hole groove
                    hull() {
                        translate([track_width_start/2 - outer_spacing -3, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 - outer_spacing * 1.5, end_y + runway_length * 0.8, 0])
                            cylinder(h=1.5, d=hole_sizes[len(hole_sizes)-1] * 1.2, $fn=32);  // Match hole size
                    }
                    // Outer right hole groove
                    hull() {
                        translate([track_width_start/2 + outer_spacing + 3, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([track_width_start/2 + outer_spacing*1.5, end_y + runway_length * 0.8, 0])
                            cylinder(h=1.5, d=hole_sizes[len(hole_sizes)-1] * 1.2, $fn=32);  // Match hole size
                    }
                } else {
                    // Regular grooves for sorting sections
                    // Inner grooves
                    hull() {
                        translate([start_center - local_spacing/2, start_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([end_center - next_spacing/2, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                    }
                    hull() {
                        translate([start_center + local_spacing/2, start_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([end_center + next_spacing/2, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                    }
                    
                    // Outer grooves
                    hull() {
                        translate([start_center - outer_spacing/2, start_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([end_center - next_outer_spacing/2, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                    }
                    hull() {
                        translate([start_center + outer_spacing/2, start_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                        translate([end_center + next_outer_spacing/2, end_y, 0])
                            cylinder(h=1.5, d=4, $fn=32);
                    }
                }
            }
        }
    }
}

// Add fractal grooves to runway
module fractal_groove(x1, y1, x2, y2, depth, width, level) {
    if (level > 0) {
        // Main groove
        hull() {
            translate([x1, y1, 0])
                cylinder(h=depth, d=width, $fn=32);
            translate([x2, y2, 0])
                cylinder(h=depth * 0.8, d=width * 1.5, $fn=32);  // Wider end
        }
        
        if(level > 1) {
            // Branch points
            mid_x = (x1 + x2) / 2;
            mid_y = (y1 + y2) / 2;
            spread = 20 * (4-level);  // Increased spread
            
            // Left branch
            fractal_groove(
                mid_x, mid_y,
                mid_x - spread, y2,
                depth * 0.7,    // Less depth reduction
                width * 1.5,    // More width increase
                level - 1
            );
            
            // Right branch
            fractal_groove(
                mid_x, mid_y,
                mid_x + spread, y2,
                depth * 0.7,
                width * 1.5,
                level - 1
            );
        }
    }
}


module ballSorter() {
// Assemble the complete model
difference() {
   // Original shape
    sorting_track();


    // Add large rectangular plate above the shape
    translate([-30, -20, -70])  // Position it above and extend beyond the shape
        rotate([10, 0, 0])
        cube([220, 300, 60]);    // Make it wider and longer than the shape
    
 
} 
}