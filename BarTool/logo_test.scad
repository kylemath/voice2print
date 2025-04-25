// Direct test of the PADPAK logo to verify OpenSCAD can load it properly

// Logo parameters
LOGO_FILE = "/Users/kylemathewson/voice2print/BarTool/assets/padpak_outline.svg";
LOGO_SCALE = 0.6;
LOGO_DEPTH = 2;

// Import test - this should show the logo if SVG is valid
translate([0, 0, 0]) {
    linear_extrude(height = LOGO_DEPTH)
    scale([LOGO_SCALE, LOGO_SCALE, 1])
    import(file = LOGO_FILE, center = true);
}

// Import test of alternative logos if needed
translate([0, 70, 0]) {
    linear_extrude(height = LOGO_DEPTH)
    scale([0.6, 0.6, 1])
    import(file = "/Users/kylemathewson/voice2print/BarTool/assets/padpak_simple.svg", center = true);
}

// Block logo embedding test
translate([0, -70, 0]) {
    difference() {
        // Base block
        cube([120, 50, 5], center=true);
        
        // Logo impression
        translate([0, 0, LOGO_DEPTH-2.5]) {
            linear_extrude(height = LOGO_DEPTH + 0.1)
            scale([LOGO_SCALE, LOGO_SCALE, 1])
            import(file = LOGO_FILE, center = true);
        }
    }
} 