include <config.scad>
include <modules/handlebar.scad>
include <modules/socket_storage.scad>
include <modules/middle_spacer.scad>
include <modules/lid.scad>

// Main assembly module
module bartool_assembly() {
    // // Base and handlebar mount
    // translate([.75, -.75, 0])
    // handlebar_interface();
    
    // // Middle spacer
    // middle_spacer();  

    // // Socket storage on top
    // translate([0, 0, 25])
    // socket_storage();
    

    difference() {
      // Lid (positioned for printing flat at the same level as the bottom)
        translate([CASE_WIDTH, CASE_DEPTH + 20, -5]) {  // Position next to the base horizontally
            rotate([180, 0, 0])  // Rotate 180 degrees around X axis to lay flat
            // Mirror image the lid on the x axis
            mirror([0, 1, 0])
            lid_minus_logo();
        }
        union() {
            rotate([0, 90, 0]) {
                translate([-146, 95, 0])
                difference() {
                    cylinder(d=GIANT_CYLINDER_DIAMETER, h=GIANT_CYLINDER_HEIGHT, center=true, $fn=100);
                    cylinder(d=GIANT_CYLINDER_DIAMETER-30, h=GIANT_CYLINDER_HEIGHT+1, center=true, $fn=100);
                }
            }
        }
     
    }
}

// For final assembly preview
bartool_assembly(); 