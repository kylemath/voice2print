// Simple test script for the PADPAK PRO logo
include <config.scad>
include <modules/socket_storage.scad>  // For tool position variables
include <modules/lid.scad>

// Set the quality for rendering
$fn = 50;

// Choose what to display
DISPLAY_MODE = "logo_only"; // Options: "logo_only", "lid_with_logo", "both"

if (DISPLAY_MODE == "logo_only" || DISPLAY_MODE == "both") {
    // Just the logo piece
    translate([0, 30, 0]) {
        logo_only();
    }
}

if (DISPLAY_MODE == "lid_with_logo" || DISPLAY_MODE == "both") {
    // The lid with logo cutout
    lid_with_logo();
}

// The original logo for size/position reference
%translate([0, -30, 0]) {
    linear_extrude(height = 1)
    scale([LOGO_SCALE, LOGO_SCALE, 1])
    import(file = LOGO_FILE, center = true);
} 