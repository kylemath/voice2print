// Direct test of the PADPAK logo to verify OpenSCAD can load it properly

// Logo parameters
LOGO_FILE = "/Users/kylemathewson/voice2print/BarTool/assets/ChatGPT-Image-Apr-25_-2025_-11_30_11-AM.svg";
LOGO_SCALE = 0.6;  // Scale factor for the logo (increased by 4x from 0.15)
LOGO_DEPTH = 2;     // Extrusion height

// Preview just the logo
linear_extrude(height = LOGO_DEPTH)
scale([LOGO_SCALE, LOGO_SCALE, 1])
import(file = LOGO_FILE, center = true);

// Show a size reference grid
%translate([0, 0, -0.5])
union() {
    for(i = [-10:10]) {
        translate([i*20, 0, 0])
        cube([0.5, 400, 0.5], center=true);
        
        translate([0, i*20, 0])
        cube([400, 0.5, 0.5], center=true);
    }
}

// Test with a base plate
translate([0, -280, 0]) {
    difference() {
        // Base block - enlarged for the larger logo
        cube([600, 320, 5], center=true);
        
        // Logo impression
        translate([0, 0, 1.5]) {
            linear_extrude(height = LOGO_DEPTH + 0.1)
            scale([LOGO_SCALE, LOGO_SCALE, 1])
            import(file = LOGO_FILE, center = true);
        }
    }
} 