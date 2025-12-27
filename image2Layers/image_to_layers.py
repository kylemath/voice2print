#!/usr/bin/env python3
"""
Image to Layered SVG Converter
Separates an image by color and creates SVG outlines for each color layer.
Perfect for multi-color 3D printing with layer-based color changes.
"""

import numpy as np
from PIL import Image
import sys
import os
from pathlib import Path

def rgb_to_hsv(rgb):
    """Convert RGB to HSV color space"""
    r, g, b = rgb[0]/255.0, rgb[1]/255.0, rgb[2]/255.0
    maxc = max(r, g, b)
    minc = min(r, g, b)
    v = maxc
    if minc == maxc:
        return 0.0, 0.0, v
    s = (maxc-minc) / maxc
    rc = (maxc-r) / (maxc-minc)
    gc = (maxc-g) / (maxc-minc)
    bc = (maxc-b) / (maxc-minc)
    if r == maxc:
        h = bc-gc
    elif g == maxc:
        h = 2.0+rc-bc
    else:
        h = 4.0+gc-rc
    h = (h/6.0) % 1.0
    return h, s, v

def get_color_layers(image_path, tolerance=20):
    """
    Extract color layers from an image.
    Returns a dictionary of colors and their binary masks.
    """
    img = Image.open(image_path).convert('RGBA')
    pixels = np.array(img)
    
    # Get unique colors (considering alpha channel)
    colors = {}
    height, width = pixels.shape[:2]
    
    # Find all unique colors
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[y, x]
            if a < 128:  # Skip transparent pixels
                continue
            
            # Check if this color is close to an existing color
            color_found = False
            for existing_color in colors.keys():
                if (abs(r - existing_color[0]) <= tolerance and
                    abs(g - existing_color[1]) <= tolerance and
                    abs(b - existing_color[2]) <= tolerance):
                    colors[existing_color][y, x] = 255
                    color_found = True
                    break
            
            if not color_found:
                # Create new color mask
                mask = np.zeros((height, width), dtype=np.uint8)
                mask[y, x] = 255
                colors[(r, g, b)] = mask
    
    return colors, img.size

def mask_to_svg_path(mask, simplify=2):
    """
    Convert a binary mask to SVG path using contour tracing.
    Simplified version - creates rectangles for each pixel.
    For production, you'd want to use potrace or similar.
    """
    height, width = mask.shape
    paths = []
    
    # Simple approach: find connected regions
    visited = np.zeros_like(mask, dtype=bool)
    
    for y in range(0, height, simplify):
        for x in range(0, width, simplify):
            if mask[y, x] > 0 and not visited[y, x]:
                # Find the extent of this filled region
                x_start = x
                x_end = x
                
                # Extend horizontally
                while x_end < width and mask[y, x_end] > 0:
                    visited[y, x_end] = True
                    x_end += 1
                
                # Create a rectangle
                paths.append(f'M {x_start},{y} L {x_end},{y} L {x_end},{y+simplify} L {x_start},{y+simplify} Z')
    
    return ' '.join(paths)

def create_svg_from_mask(mask, size, color, filename):
    """Create an SVG file from a binary mask"""
    width, height = size
    path_data = mask_to_svg_path(mask)
    
    svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{width}" height="{height}" xmlns="http://www.w3.org/2000/svg">
  <path d="{path_data}" fill="rgb({color[0]},{color[1]},{color[2]})" />
</svg>'''
    
    with open(filename, 'w') as f:
        f.write(svg_content)

def sort_colors_by_priority(colors):
    """
    Sort colors by priority:
    - White and black lowest (but can be layered between)
    - Sort by rarity (fewer pixels = higher layer)
    - Sort by hue for similar quantities
    """
    color_info = []
    
    for color, mask in colors.items():
        pixel_count = np.sum(mask > 0)
        h, s, v = rgb_to_hsv(color)
        
        # Identify white and black
        is_white = v > 0.9 and s < 0.1
        is_black = v < 0.1
        
        color_info.append({
            'color': color,
            'mask': mask,
            'count': pixel_count,
            'hue': h,
            'saturation': s,
            'value': v,
            'is_white': is_white,
            'is_black': is_black
        })
    
    # Sort: white/black first, then by rarity (ascending count = higher layer)
    def sort_key(c):
        if c['is_white'] or c['is_black']:
            return (0, -c['count'])  # White/black at base
        else:
            return (1, c['count'])  # Colored layers by rarity
    
    color_info.sort(key=sort_key)
    return color_info

def main(image_path, output_dir='layers', tolerance=20):
    """
    Main function to process image and create layered SVGs
    """
    print(f"Processing: {image_path}")
    
    # Create output directory
    Path(output_dir).mkdir(exist_ok=True)
    
    # Extract color layers
    print("Extracting colors...")
    colors, size = get_color_layers(image_path, tolerance)
    print(f"Found {len(colors)} unique colors")
    
    # Sort by priority
    sorted_colors = sort_colors_by_priority(colors)
    
    # Create SVGs for each layer
    layer_info = []
    for i, color_data in enumerate(sorted_colors):
        color = color_data['color']
        mask = color_data['mask']
        
        # Generate filename
        color_name = f"layer_{i:02d}_rgb_{color[0]:03d}_{color[1]:03d}_{color[2]:03d}"
        svg_filename = os.path.join(output_dir, f"{color_name}.svg")
        
        print(f"Creating {svg_filename}...")
        create_svg_from_mask(mask, size, color, svg_filename)
        
        layer_info.append({
            'layer': i,
            'filename': f"{color_name}.svg",
            'color': color,
            'height': i * 0.2,  # 0.2mm per layer by default
            'pixel_count': color_data['count']
        })
    
    # Create layer info file
    info_file = os.path.join(output_dir, 'layer_info.txt')
    with open(info_file, 'w') as f:
        f.write("Layer Information\n")
        f.write("="*60 + "\n\n")
        for info in layer_info:
            f.write(f"Layer {info['layer']:2d}: {info['filename']}\n")
            f.write(f"  Color: RGB({info['color'][0]}, {info['color'][1]}, {info['color'][2]})\n")
            f.write(f"  Height: {info['height']:.2f}mm\n")
            f.write(f"  Pixels: {info['pixel_count']}\n\n")
    
    print(f"\nDone! Created {len(layer_info)} layer files in '{output_dir}/'")
    print(f"Layer information saved to: {info_file}")
    
    return layer_info

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python image_to_layers.py <image_file> [output_dir] [tolerance]")
        print("\nExample: python image_to_layers.py juventus_logo.png layers 20")
        sys.exit(1)
    
    image_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else 'layers'
    tolerance = int(sys.argv[3]) if len(sys.argv) > 3 else 20
    
    main(image_path, output_dir, tolerance)


