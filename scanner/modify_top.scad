// Import the original TOP.stl file
difference() {
    translate([-110, -110, 0])
        import("TOP.stl");
    
    // Simple 7mm through hole
    translate([0, 0, -50])
        cylinder(h=200, d=7, $fn=32, center=true);
    
    // Magnet inset holes - arranged in a circle
    for (angle = [0:20:359]) {
        rotate([0, 0, angle])
        translate([85, 0, 0])  // Positioned 40mm from center, adjust radius as needed
            cylinder(h=2, d=4, $fn=32);  // 4mm diameter, 2mm deep
        rotate([0, 0, angle])
        translate([40, 0, 0])  // Positioned 40mm from center, adjust radius as needed
            cylinder(h=2, d=4, $fn=32);  // 4mm diameter, 2mm deep
        rotate([0, 0, angle])
        translate([60, 0, 0])  // Positioned 40mm from center, adjust radius as needed
            cylinder(h=2, d=4, $fn=32);  
    }
} 

