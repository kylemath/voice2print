// Logo Embossing Generator for the BarTool Lid
// This file creates two separate printable models:
// 1. The main lid with a cutout where the logo should be
// 2. The logo piece that can be printed in a different color/material

include <config.scad>
include <modules/socket_storage.scad>  // For tool position variables
include <modules/lid.scad>

// Set the quality for rendering
$fn = 50;

// Render modes
RENDER_MODE = "logo"; // Options: "both", "logo", "lid"

// Model rendering based on mode
if (RENDER_MODE == "both" || RENDER_MODE == "logo") {
    // Render the logo piece for separate printing
    // Move to a position for viewing
    translate([0, 100, 0]) {
        logo_only();
    }
}

if (RENDER_MODE == "both" || RENDER_MODE == "lid") {
    // Render the lid with logo cutout
    lid_minus_logo();
}

// Instructions for use:
// 1. The PADPAK PRO logo is already saved in the assets folder
// 2. Adjust the logo parameters in modules/lid.scad:
//    - LOGO_SCALE: Change the size of the logo (currently 0.5)
//    - LOGO_DEPTH: Change how deep the embossing is (currently 2mm)
//    - LOGO_POSITION_X/Y: Position the logo on the lid (currently centered at X:0, Y:0)
//    - LOGO_ROTATION: Rotate the logo if needed (currently 0 degrees)
// 3. Set RENDER_MODE to "logo" to export just the logo piece
// 4. Set RENDER_MODE to "lid" to export the lid with logo cutout
// 5. Print each piece in different colors/materials and assemble
//
// Note: The logo is embossed on the opposite side of the lid from the tool cutouts 