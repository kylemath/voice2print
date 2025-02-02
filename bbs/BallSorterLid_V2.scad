// Parameters matching BallSorter_V2.scad
track_width = 41;
track_width_start = 31;
track_width_end = 61;
wall_thickness = 2;
hole_spacing = 15;
wall_height = 60;
tray_extension = 120;
runway_length = 35;
funnel_end_width = track_width_end + 20;
hole_sizes = [
    2.38, 3.18, 3.97, 4.76, 5.56, 6.35, 7.14, 7.94, 8.73, 9.53, 10.32
];

// Lid specific parameters
lip_depth = 3;        // How deep the lip extends into compartments
lid_thickness = 2;    // Thickness of the main lid
tolerance = 0.2;      // Gap for press fit

// Add parameter for exit blocker height
exit_blocker_height = 15;  // Height of the wall that blocks exit holes

// Function to calculate tray extension based on ball size index (matching sorter)
function get_tray_extension(i) = 
    tray_extension * ((i * 0.75 / len(hole_sizes)) + 0.25);

// Function to calculate track width at any point (matching sorter)
function get_track_width(i) = 
    track_width_start + (i * ((track_width_end - track_width_start) / len(hole_sizes)));

// Function to calculate extra width for largest section
function get_extra_width(i) = 
    (i == 0) ? 5 : 1 + (i * 0.2);  // Progressive width increase as we go up the slope

// Function to calculate segment width in Y direction
function get_segment_width(i) =
    3.1 + (i * 0.3);  // Progressive increase in Y direction width

module lid() {
    rotate([10, 0, 0])
    difference() {
        union() {
            // Main lid body
            for(i = [0:len(hole_sizes)]) {
                width = get_track_width(i);
                next_width = (i < len(hole_sizes)) ? get_track_width(i + 1) : funnel_end_width;
                local_tray_extension = (i < len(hole_sizes)) ? get_tray_extension(i) : tray_extension * 0.25;
                extra_width = get_extra_width(i);
                segment_width = get_segment_width(i);
                next_segment_width = get_segment_width(i + 1);
                
                // Main lid section
                hull() {
                    // Current segment
                    translate([(track_width_start - width)/2 - wall_thickness - extra_width/2, i * hole_spacing - segment_width/2, 0]) {
                        cube([width + 2*wall_thickness + extra_width, segment_width, lid_thickness]);
                        // Add lip that goes into the track (keeping original width for lip)
                        translate([wall_thickness + tolerance + extra_width/2, segment_width/2 - 0.1/2, -lip_depth])
                            cube([width - 2*tolerance, 0.1, lip_depth]);
                    }
                    
                    // Next segment with special handling for runway
                    if(i == len(hole_sizes)) {
                        // Flared runway end
                        translate([(track_width_start - next_width)/2 - wall_thickness - 5,
                                 i * hole_spacing + runway_length, 0]) {
                            cube([next_width + 2*wall_thickness + 10, next_segment_width, lid_thickness]);
                            translate([wall_thickness + tolerance + 2.5, next_segment_width/2 - 0.1/2, -lip_depth])
                                cube([next_width - 2*tolerance + 5, 0.1, lip_depth]);
                        }
                    } else {
                        // Normal segments
                        translate([(track_width_start - next_width)/2 - wall_thickness - get_extra_width(i+1)/2, 
                                 (i + 1) * hole_spacing - next_segment_width/2, 0]) {
                            cube([next_width + 2*wall_thickness + get_extra_width(i+1), next_segment_width, lid_thickness]);
                            translate([wall_thickness + tolerance + get_extra_width(i+1)/2, next_segment_width/2 - 0.1/2, -lip_depth])
                                cube([next_width - 2*tolerance, 0.1, lip_depth]);
                        }
                    }
                }
                
                if(i < len(hole_sizes)) {
                    // Tray cover section with extra width for all sections
                    hull() {
                        // Current segment tray
                        translate([(track_width_start + width)/2 - extra_width/2, i * hole_spacing - segment_width/2, 0])
                            cube([local_tray_extension + wall_thickness + extra_width, segment_width, lid_thickness]);
                        
                        // Next segment tray
                        translate([(track_width_start + next_width)/2 - get_extra_width(i+1)/2, (i + 1) * hole_spacing - next_segment_width/2, 0])
                            cube([local_tray_extension + wall_thickness + get_extra_width(i+1), next_segment_width, lid_thickness]);
                    }
                    
                    // Tray side lips (keeping original width for lip)
                    hull() {
                        // Current segment tray lip
                        translate([(track_width_start + width)/2 + tolerance, i * hole_spacing - 0.1/2, -lip_depth])
                            cube([local_tray_extension - 2*tolerance, 0.1, lip_depth]);
                        
                        // Next segment tray lip
                        translate([(track_width_start + next_width)/2 + tolerance, (i + 1) * hole_spacing - 0.1/2, -lip_depth])
                            cube([local_tray_extension - 2*tolerance, 0.1, lip_depth]);
                    }
                }

                // Add exit hole blockers
                width = get_track_width(i);
                next_width = get_track_width(i + 1);
                extra_width = get_extra_width(i);
                segment_width = get_segment_width(i);
                
                // Vertical wall to block exit holes - full tray width
                if(i < len(hole_sizes)) {  // Only add blockers for non-runway segments
                    
                    translate([(track_width_start + width)/2, 
                             i * hole_spacing + hole_spacing/2 - segment_width,  // Centered on hole position
                             -exit_blocker_height+2])  // Extend down from lid
                        rotate([0, 0,-5])
                            translate([+1, 0, 0])
                        cube([2, segment_width*2, exit_blocker_height]);  // Full tray width
                }
            }
        }
        

    }
}
use <BallSorter_V2.scad>

// Import the ball sorter module
module ballSorterLocal() {
    translate([1.5, 0, 66])
        rotate([0, 0, 0])
            ballSorter();

}

// Render the lid
difference() {
    lid();

    // Subtract the ball sorter model with centered, symmetrical clearance
    ballSorterLocal();  // Use the original SCAD module
}


