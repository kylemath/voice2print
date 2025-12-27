# Juventus Logo 3D Print Guide

This guide will help you convert the Juventus logo into a multi-color 3D printable model optimized for your K2 Max printer.
##
##
##

## This might work, but illumistack works better anyway just use that
##
##

## Overview

The workflow separates the logo by color into different layers, with rare colors on top and common colors (white/black) at the base. This minimizes filament waste and printing time.

## Prerequisites

1. **Python 3.7+** with virtual environment
2. **OpenSCAD** for 3D model generation
3. **Juventus logo image** (PNG or JPG format)

## Step 1: Setup

Create and activate a virtual environment:

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate  # On Windows

# Install dependencies
pip install -r requirements.txt
```

## Step 2: Prepare Your Image

1. Get the Juventus logo image (PNG or JPG)
2. For best results:
   - High resolution (at least 500x500 pixels)
   - Clean edges
   - Solid colors (not gradients)
3. Save it in this directory as `juventus_logo.png` (or any name you prefer)

## Step 3: Generate SVG Layers

Run the conversion script:

```bash
python image_to_layers_advanced.py juventus_logo.png
```

Optional parameters:
- `python image_to_layers_advanced.py juventus_logo.png output_folder 20`
  - `output_folder`: Custom output directory
  - `20`: Color tolerance (0-255, higher = more color merging)

This will create:
- `layers/` directory with SVG files for each color
- `layers/layers_config.scad` with OpenSCAD configuration

## Step 4: Create 3D Model

1. Open `layered_logo.scad` in OpenSCAD
2. Copy the layer configuration from `layers/layers_config.scad` into the script
3. Adjust parameters:
   ```
   base_height = 0.4;      // Thickness of each layer (mm)
   layer_height = 0.2;     // Spacing between colors (mm)
   scale_factor = 0.3;     // Size adjustment
   ```
4. Press F5 to preview
5. Press F6 to render
6. Export as STL (File → Export → Export as STL)

## Step 5: Slicing for Multi-Color

### Option A: Layer-Based Color Changes (Recommended for K2 Max)

1. Import STL into your slicer (PrusaSlicer, Cura, etc.)
2. Note the Z-heights where colors change (from the layer info)
3. Add filament change commands at these heights:
   - PrusaSlicer: Right-click layer → Add color change
   - Cura: Extensions → Post Processing → Pause at height

### Option B: Manual Filament Swaps

1. Calculate the layer numbers for each color change
2. Add pause commands (M600 or M0) at those layers
3. Manually swap filament when the printer pauses

## Color Layer Strategy

The script automatically sorts colors:

1. **Layer 0 (Bottom)**: Black - base adhesion
2. **Layer 1**: White - common color
3. **Layer 2**: Primary team color (often black and white stripes)
4. **Layer 3+**: Rare accent colors on top

This order:
- Minimizes filament waste (common colors have more changes)
- Rare colors on top prevent color mixing
- Better adhesion with black/white base

## Troubleshooting

### SVG files look blocky
- Increase image resolution
- Install opencv: `pip install opencv-python-headless`
- Decrease tolerance parameter

### Too many colors detected
- Increase tolerance parameter (try 25-30)
- Pre-process image to reduce colors in image editor

### Colors in wrong order
- Manually edit the `layers` array in `layered_logo.scad`
- Swap layer numbers to change stacking order

### Model too small/large
- Adjust `scale_factor` in OpenSCAD
- Or scale in your slicer

## Tips for K2 Max

- Use 0.2mm layer height for good detail
- First layer at 0.28mm for adhesion
- Print slower for color changes (30-40mm/s)
- Purge well between colors to avoid mixing
- Consider a purge tower or wipe mechanism

## Example: Juventus Black & White Stripes

Typical Juventus logo has:
- **Black stripes**: Base layer (most common)
- **White stripes**: Layer 1
- **Gold accents**: Layer 2 (rare, on top)

Total height: ~1.0mm (0.4mm base + 0.2mm × 3 layers)

Perfect for a thin, colorful badge or magnet backing!

## Questions?

Check the comments in:
- `image_to_layers_advanced.py` - for image processing
- `layered_logo.scad` - for 3D model generation


