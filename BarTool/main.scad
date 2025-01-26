include <config.scad>
include <modules/handlebar.scad>
include <modules/socket_storage.scad>

// Main assembly module
module bartool_assembly() {
    // Base and handlebar mount
    handlebar_interface();
    
    // Middle spacer
    translate([0, 0, 15+MIDDLESPACE_OFFSET])
    minkowski() {
        cube([CASE_WIDTH+7.5-6, 
              CASE_DEPTH+7.5-6,
              8-3], center=true);
        cylinder(r=3, h=3, center=true);
    }

    // Socket storage on top
    translate([0, 0, 25])
    socket_storage();
}

// For final assembly preview
bartool_assembly(); 