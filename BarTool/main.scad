include <config.scad>
include <modules/handlebar.scad>
include <modules/socket_storage.scad>
include <modules/middle_spacer.scad>

// Main assembly module
module bartool_assembly() {
    // // Base and handlebar mount
    translate([.75, -.75, 0])
    handlebar_interface();
    
    // Middle spacer
    middle_spacer();  

    // // Socket storage on top
    translate([0, 0, 40])
    socket_storage();
}

// For final assembly preview
bartool_assembly(); 