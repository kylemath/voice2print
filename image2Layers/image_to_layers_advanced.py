#!/usr/bin/env python3
"""
Advanced Image to Layered SVG Converter
Uses PIL and generates proper SVG paths with smoother outlines.
Requires: pip install pillow numpy opencv-python-headless svgwrite
"""

import numpy as np
from PIL import Image
import sys
import os
from pathlib import Path
try:
    import cv2
    HAS_CV2 = True
except ImportError:
    HAS_CV2 = False
    print("Warning: opencv-python not found. Install for better contour detection.")
    print("Run: pip install opencv-python-headless")

try:
    import svgwrite
    HAS_SVGWRITE = True
except ImportError:
    HAS_SVGWRITE = False
    print("Warning: svgwrite not found. Install for better SVG generation.")
    print("Run: pip install svgwrite")

def get_unique_colors(image_path, tolerance=15):
    """Extract unique colors from image with tolerance"""
    img = Image.open(image_path).convert('RGBA')
    pixels = np.array(img)
    
    # Remove transparency
    colors_dict = {}
    height, width = pixels.shape[:2]
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[y, x]
            if a < 128:  # Skip transparent
                continue
            
            # Find similar color
            found = False
            for existing_color in colors_dict.keys():
                if (abs(r - existing_color[0]) <= tolerance and
                    abs(g - existing_color[1]) <= tolerance and
                    abs(b - existing_color[2]) <= tolerance):
                    colors_dict[existing_color].append((x, y))
                    found = True
                    break
            
            if not found:
                colors_dict[(r, g, b)] = [(x, y)]
    
    return colors_dict, (width, height)

def create_mask_for_color(pixels, color, tolerance=15):
    """Create binary mask for a specific color"""
    height, width = pixels.shape[:2]
    mask = np.zeros((height, width), dtype=np.uint8)
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[y, x]
            if a < 128:
                continue
            if (abs(r - color[0]) <= tolerance and
                abs(g - color[1]) <= tolerance and
                abs(b - color[2]) <= tolerance):
                mask[y, x] = 255
    
    return mask

def mask_to_svg_opencv(mask, size, color, filename, simplify=True):
    """Convert mask to SVG using OpenCV contours"""
    if not HAS_CV2:
        print(f"Skipping {filename} - OpenCV not available")
        return False
    
    # Find contours
    contours, hierarchy = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    
    if not HAS_SVGWRITE:
        # Fallback to manual SVG creation
        return mask_to_svg_simple(mask, size, color, filename)
    
    # Create SVG
    dwg = svgwrite.Drawing(filename, size=size)
    
    for contour in contours:
        if len(contour) < 3:
            continue
        
        # Simplify contour if requested
        if simplify:
            epsilon = 0.005 * cv2.arcLength(contour, True)
            contour = cv2.approxPolyDP(contour, epsilon, True)
        
        # Convert to path
        points = contour.reshape(-1, 2)
        if len(points) < 3:
            continue
        
        path_data = f"M {points[0][0]},{points[0][1]}"
        for point in points[1:]:
            path_data += f" L {point[0]},{point[1]}"
        path_data += " Z"
        
        dwg.add(dwg.path(d=path_data, fill=svgwrite.rgb(color[0], color[1], color[2])))
    
    dwg.save()
    return True

def mask_to_svg_simple(mask, size, color, filename):
    """Simple SVG generation without external libraries"""
    width, height = size
    paths = []
    
    # Simple run-length encoding approach
    for y in range(height):
        x = 0
        while x < width:
            if mask[y, x] > 0:
                x_start = x
                while x < width and mask[y, x] > 0:
                    x += 1
                x_end = x
                paths.append(f'M {x_start},{y} L {x_end},{y} L {x_end},{y+1} L {x_start},{y+1} Z')
            else:
                x += 1
    
    svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{width}" height="{height}" xmlns="http://www.w3.org/2000/svg">
  <path d="{' '.join(paths)}" fill="rgb({color[0]},{color[1]},{color[2]})" />
</svg>'''
    
    with open(filename, 'w') as f:
        f.write(svg_content)
    return True

def classify_color(r, g, b):
    """Classify color for layering"""
    # Convert to HSV-like values
    max_val = max(r, g, b)
    min_val = min(r, g, b)
    
    # Brightness
    brightness = max_val / 255.0
    
    # Saturation
    if max_val == 0:
        saturation = 0
    else:
        saturation = (max_val - min_val) / max_val
    
    # Check for white/black/gray
    is_white = brightness > 0.85 and saturation < 0.15
    is_black = brightness < 0.15
    is_gray = saturation < 0.15 and not is_white and not is_black
    
    return {
        'is_white': is_white,
        'is_black': is_black,
        'is_gray': is_gray,
        'brightness': brightness,
        'saturation': saturation
    }

def main(image_path, output_dir='layers', tolerance=15):
    """Main processing function"""
    print(f"Processing: {image_path}")
    print("="*60)
    
    # Create output directory
    Path(output_dir).mkdir(exist_ok=True)
    
    # Load image
    img = Image.open(image_path).convert('RGBA')
    pixels = np.array(img)
    size = (img.width, img.height)
    
    print(f"Image size: {size[0]}x{size[1]}")
    
    # Get unique colors
    print("\nExtracting colors...")
    colors_dict, _ = get_unique_colors(image_path, tolerance)
    print(f"Found {len(colors_dict)} unique colors")
    
    # Analyze and sort colors
    color_info = []
    for color, points in colors_dict.items():
        classification = classify_color(*color)
        pixel_count = len(points)
        
        color_info.append({
            'color': color,
            'count': pixel_count,
            **classification
        })
        
        print(f"  RGB({color[0]:3d}, {color[1]:3d}, {color[2]:3d}): {pixel_count:6d} pixels", end="")
        if classification['is_white']:
            print(" [WHITE]")
        elif classification['is_black']:
            print(" [BLACK]")
        elif classification['is_gray']:
            print(" [GRAY]")
        else:
            print()
    
    # Sort colors: white/black first, then by rarity (fewer pixels = higher layer)
    def sort_key(c):
        if c['is_black']:
            return (0, c['count'])  # Black at very bottom
        elif c['is_white']:
            return (1, c['count'])  # White next
        elif c['is_gray']:
            return (2, c['count'])  # Gray next
        else:
            return (3, -c['count'])  # Colored layers: rarest on top (negative for reverse)
    
    color_info.sort(key=sort_key)
    
    print("\nGenerating SVG layers...")
    print("="*60)
    
    layer_data = []
    for i, info in enumerate(color_info):
        color = info['color']
        
        # Create mask
        mask = create_mask_for_color(pixels, color, tolerance)
        
        # Generate filename
        color_type = ""
        if info['is_white']:
            color_type = "_WHITE"
        elif info['is_black']:
            color_type = "_BLACK"
        elif info['is_gray']:
            color_type = "_GRAY"
        
        filename = f"layer_{i:02d}_rgb_{color[0]:03d}_{color[1]:03d}_{color[2]:03d}{color_type}.svg"
        filepath = os.path.join(output_dir, filename)
        
        print(f"Layer {i:2d}: {filename} ({info['count']} pixels)")
        
        # Create SVG
        if HAS_CV2:
            mask_to_svg_opencv(mask, size, color, filepath)
        else:
            mask_to_svg_simple(mask, size, color, filepath)
        
        layer_data.append({
            'layer': i,
            'filename': filename,
            'color': color,
            'count': info['count'],
            'classification': color_type
        })
    
    # Generate OpenSCAD configuration
    scad_config = generate_scad_config(layer_data, size)
    config_file = os.path.join(output_dir, 'layers_config.scad')
    with open(config_file, 'w') as f:
        f.write(scad_config)
    
    print(f"\n{'='*60}")
    print(f"✓ Created {len(layer_data)} SVG layers in '{output_dir}/'")
    print(f"✓ Generated OpenSCAD config: {config_file}")
    print(f"\nNext steps:")
    print(f"1. Review SVG files in '{output_dir}/'")
    print(f"2. Open layered_logo.scad in OpenSCAD")
    print(f"3. Adjust layer heights and scale as needed")
    print(f"4. Render and export to STL")
    
    return layer_data

def generate_scad_config(layer_data, size):
    """Generate OpenSCAD configuration"""
    config = """// Auto-generated layer configuration
// Edit heights and parameters as needed

"""
    
    config += f"image_width = {size[0]};\n"
    config += f"image_height = {size[1]};\n\n"
    
    config += "layers = [\n"
    for data in layer_data:
        color = data['color']
        config += f'    ["{data["filename"]}", {data["layer"]}, 1.0, [{color[0]}, {color[1]}, {color[2]}]],  // {data["count"]} pixels{data["classification"]}\n'
    config += "];\n"
    
    return config

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python image_to_layers_advanced.py <image_file> [output_dir] [tolerance]")
        print("\nExample:")
        print("  python image_to_layers_advanced.py juventus_logo.png layers 15")
        print("\nParameters:")
        print("  image_file: Path to your Juventus logo (PNG, JPG, etc.)")
        print("  output_dir: Output directory for SVG layers (default: 'layers')")
        print("  tolerance: Color matching tolerance 0-255 (default: 15)")
        print("\nFor best results, install optional dependencies:")
        print("  pip install opencv-python-headless svgwrite")
        sys.exit(1)
    
    image_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else 'layers'
    tolerance = int(sys.argv[3]) if len(sys.argv) > 3 else 15
    
    if not os.path.exists(image_path):
        print(f"Error: Image file not found: {image_path}")
        sys.exit(1)
    
    main(image_path, output_dir, tolerance)


