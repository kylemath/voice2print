// Bearing washer spacer
// For standard 608 skateboard bearing
// Dimensions in millimeters

// Constants
bearing_outer_diameter = 30;  // Standard 608 bearing outer diameter
bearing_inner_diameter = 22.1;   // Standard 608 bearing inner hole
washer_height = .3;         // Specified length/height
washer_outer_rim = 3;        // Additional diameter beyond bearing

difference() {
    // Outer cylinder (washer body)
    cylinder(h = washer_height, 
            d = bearing_outer_diameter, 
            $fn = 100);
    
    // Inner hole (for bearing shaft)
    translate([0, 0, -1])  // Ensure clean cut through
    cylinder(h = washer_height + 2,  // Add 2mm to ensure clean boolean operation
            d = bearing_inner_diameter,
            $fn = 100);
} 