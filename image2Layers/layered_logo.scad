/*
 * Multi-Layer Logo Model
 * Imports SVG layers and extrudes them at different heights
 * for multi-color 3D printing
 */

// Parameters
base_height = 1.0;        // Height of base/first layer (mm)
layer_height = 0.2;       // Height increment per layer (mm)
scale_factor = 0.3;       // Scale of the imported SVG
total_width = 100;        // Desired width in mm (for scaling reference)

// Example layer configuration
// Modify this array based on your actual layers
// Format: [filename, layer_number, rgb_color (for reference)]

layers = [
    // Format: ["filename.svg", layer_order, height_multiplier, [r,g,b]]
    // Lower layers first
    ["layer_00_rgb_255_255_255.svg", 0, 1.0, [255, 255, 255]],  // White - base
    ["layer_01_rgb_000_000_000.svg", 1, 1.0, [0, 0, 0]],        // Black
    ["layer_02_rgb_255_255_000.svg", 2, 1.0, [255, 255, 0]],    // Yellow
    ["layer_03_rgb_000_255_000.svg", 3, 1.0, [0, 255, 0]],      // Green
];

module import_layer(filename, height) {
    linear_extrude(height = height)
        scale([scale_factor, scale_factor, 1])
            import(filename, center=true);
}

module layered_logo() {
    for (i = [0:len(layers)-1]) {
        layer = layers[i];
        filename = layer[0];
        layer_num = layer[1];
        height_mult = layer[2];
        
        // Calculate z-position for this layer
        z_pos = layer_num * layer_height;
        
        // Calculate height for this layer
        layer_h = base_height * height_mult;
        
        echo(str("Layer ", layer_num, ": ", filename, " at z=", z_pos, "mm, height=", layer_h, "mm"));
        
        color([layer[3][0]/255, layer[3][1]/255, layer[3][2]/255])
        translate([0, 0, z_pos])
            import_layer(str("layers/", filename), layer_h);
    }
}

// Render the complete model
layered_logo();

/*
 * USAGE INSTRUCTIONS:
 * 
 * 1. Run image_to_layers.py on your Juventus logo:
 *    python image_to_layers.py juventus_logo.png
 * 
 * 2. Check the 'layers/' directory for generated SVG files
 * 
 * 3. Update the 'layers' array above with your actual filenames
 * 
 * 4. Adjust parameters:
 *    - base_height: thickness of each color layer
 *    - layer_height: vertical spacing between colors
 *    - scale_factor: size of the logo
 * 
 * 5. Render in OpenSCAD and export as STL
 * 
 * 6. For multi-color printing on K2 Max:
 *    - Slice the model
 *    - Add filament change commands at each z-height layer transition
 *    - Or use the pause-and-swap method at specific heights
 * 
 * TIPS:
 * - Preview each layer by commenting out others
 * - Use thin layers (0.2-0.4mm) for better adhesion
 * - Rare colors on top prevent color mixing
 * - White/black base provides good foundation
 */


