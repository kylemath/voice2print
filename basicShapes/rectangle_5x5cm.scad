// 2.5 x 2.5 cm rectangle in OpenSCAD
// Note: OpenSCAD uses millimeters as default units
// 2.5 cm = 25 mm

// Parameters
hex_size = 4; // Adjust the size of hexagonal hole as needed
socket_diameter = 8; // 11mm diameter for socket hole
depth = 22;
bevel_radius = 2; // Radius for the beveled edges

// Main module
difference() {
    // Main cube with beveled edges using minkowski
    minkowski() {
        // Reduce cube size to account for the bevel expansion
        cube(size = [22.5-2*bevel_radius, 22.5-2*bevel_radius, 25-2*bevel_radius], center = true);
        // Sphere for creating the beveled edges
        sphere(r = bevel_radius, $fn = 20);
    }
    
    // Three hexagonal holes in a row
    for (i = [0:2]) {
        translate([4 , -6+ (i * 6), 10])
        cylinder(h = depth, d = hex_size, center = true, $fn = 6);
    }
    // Socket hole (extruded through the entire cube)
    translate([-4, -4, 10])
    cylinder(h = depth, d = socket_diameter/1.5, center = true, $fn = 50);
    // Socket hole (extruded through the entire cube)
    translate([-3, 4, 10])
    cylinder(h = depth, d = socket_diameter/2, center = true, $fn = 50);
}

// Create a 2.5x2.5 cm square (2D)
// square(size = 25, center = true);

// Alternatively, for a 3D rectangle with minimal height:
// cube(size = [25, 25, 25], center = true); 