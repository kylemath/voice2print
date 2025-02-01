include <config.scad>
include <modules/handlebar.scad>
include <modules/socket_storage.scad>

// Main assembly module
module bartool_assembly() {
    // Base and handlebar mount
    handlebar_interface();
    
    // // Middle spacer
    // translate([-CASE_WIDTH/2, -CASE_DEPTH/2, 15+MIDDLESPACE_OFFSET])
    // minkowski() {
    //     cube([CASE_WIDTH+1.5, 
    //           CASE_DEPTH+1.5,
    //           7], center=false);
    //     cylinder(r=3, h=3, center=true);
    // }

    // Socket storage on top
    translate([0, 0, 30])
    socket_storage();
}

// For final assembly preview
bartool_assembly(); 