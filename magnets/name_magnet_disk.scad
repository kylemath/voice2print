// Customizable Name Magnet Disk
// Parameters
names = [
// "ANTHONY", 'OMAR', 'LEO', "ERIC",
//  "SHER ALI", "DAVID", "JJ","JACKY",
//  "LENO",  "JOSE", "LUCA",
//  "LUCA", "LENO",
"PRABHKIRAT",
//  "EVERETT","LEVI", "TRYSTAN",
//  "ATLAS", "MATEO",
 ]; // List of names to create disks for

disk_diameter = 30; // Diameter of the main disk in mm
disk_height = 4;    // Height of the disk in mm
magnet_diameter = 12; // Diameter of the magnet hole
magnet_depth = 2.75;  // Depth of the magnet hole
tolerance = 0.1;    // Tolerance for the magnet hole (both diameter and depth)
text_depth = .6;    // Depth of the name engraving
base_font_size = 3.5;    // Base size of the text for normal names
text_thickness = 0.25; // How bold to make the text

// Function to calculate font size based on name length
function get_font_size(name) = 
   base_font_size;

// Spacing parameters for grid layout
spacing = disk_diameter + 2; // Space between disks
grid_columns = 3; // Number of columns in the grid

// Main module for a single magnet disk
module magnet_disk(name) {
    rotate([180, 0, 0]) // Flip the disk upside down
    translate([0, 0, -disk_height]) // Move back to the build plate
    difference() {
        // Main disk body
        cylinder(h=disk_height, d=disk_diameter, $fn=100);
        
        // Magnet hole on the bottom with tolerance
        translate([0, 0, -0.1])
            cylinder(h=magnet_depth + tolerance * 2, 
                    d=magnet_diameter + tolerance*2, 
                    $fn=100);
        
        // Name engraving on top
        translate([0, 0, disk_height - text_depth + 0.1])
            linear_extrude(height=text_depth + 0.1)
                offset(r=text_thickness)
                    text(name, 
                         size=get_font_size(name),
                         halign="center",
                         valign="center");
    }
}

// Module to create grid of disks
module disk_grid() {
    for (i = [0:len(names)-1]) {
        // Calculate row and column position
        row = floor(i / grid_columns);
        col = i % grid_columns;
        
        // Position disk in grid
        translate([col * spacing, row * spacing, 0])
            magnet_disk(names[i]);
    }
}

// Create the grid of disks
disk_grid(); 