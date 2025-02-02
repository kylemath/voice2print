include <../config.scad>
total_width = MOUNT_SPACING + MOUNT_WIDTH * 2;  // Total width including both mounts

module middle_spacer () {
    translate([0, 0, 14+MIDDLESPACE_OFFSET])
        difference() {
            difference() {
                minkowski() {
                    cube([CASE_WIDTH+1.5, 
                            CASE_DEPTH+1.5,
                            8], center=true);
                    sphere(r=3);
                }
                translate([0, 0, -3])
                    cube([CASE_WIDTH-WALL_THICKNESS*3, 
                    CASE_DEPTH-WALL_THICKNESS*1.8,
                    20], center=true);
            }
            
        }
}