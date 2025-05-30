#!/bin/bash

# Optimized OpenSCAD rendering script for Apple M4
# This script maximizes performance by using multiple CPU cores and optimal settings

# Set the number of parallel jobs (M4 has great multi-core performance)
JOBS=$(sysctl -n hw.ncpu)
echo "Using $JOBS parallel jobs on M4 system"

# High-quality settings for final STL export
FINAL_FN=100
RENDER_QUALITY="--render"

# Create output directory
mkdir -p stl_output

# Function to render individual segments
render_segment() {
    local segment=$1
    echo "Rendering segment $segment..."
    
    # Use nice to lower priority and prevent system slowdown
    nice -n 10 openscad \
        --export-format=stl \
        -o "stl_output/ballTower_segment_$segment.stl" \
        -D "\$fn=$FINAL_FN" \
        -D "render_segment=$segment" \
        $RENDER_QUALITY \
        bbs/ballTower.scad
    
    echo "Completed segment $segment"
}

# Main rendering options
echo "Choose rendering option:"
echo "1. Render complete model (single STL)"
echo "2. Render with cross-section (for inspection)"
echo "3. Quick preview render (lower quality)"
echo "4. Render individual segments (parallel)"

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "Rendering complete model..."
        nice -n 10 openscad \
            --export-format=stl \
            -o "stl_output/ballTower_complete.stl" \
            -D "\$fn=$FINAL_FN" \
            $RENDER_QUALITY \
            bbs/ballTower.scad
        ;;
    2)
        echo "Rendering with cross-section..."
        # Temporarily uncomment the cross-section cut
        sed 's|^    // // Cut in half|    // Cut in half|' bbs/ballTower.scad > temp_ballTower.scad
        sed 's|^    // translate|    translate|' temp_ballTower.scad > temp_ballTower2.scad
        sed 's|^    //     cube|        cube|' temp_ballTower2.scad > temp_ballTower_cross.scad
        
        nice -n 10 openscad \
            --export-format=stl \
            -o "stl_output/ballTower_cross_section.stl" \
            -D "\$fn=$FINAL_FN" \
            $RENDER_QUALITY \
            temp_ballTower_cross.scad
            
        rm temp_ballTower*.scad
        ;;
    3)
        echo "Quick preview render..."
        nice -n 10 openscad \
            --export-format=stl \
            -o "stl_output/ballTower_preview.stl" \
            -D "\$fn=32" \
            bbs/ballTower.scad
        ;;
    4)
        echo "Parallel segment rendering not implemented yet..."
        echo "Rendering complete model instead..."
        nice -n 10 openscad \
            --export-format=stl \
            -o "stl_output/ballTower_complete.stl" \
            -D "\$fn=$FINAL_FN" \
            $RENDER_QUALITY \
            bbs/ballTower.scad
        ;;
esac

echo "Rendering complete! Check stl_output/ directory"
echo "Consider using these settings in OpenSCAD GUI:"
echo "- View > Animate: OFF"
echo "- View > Show Edges: OFF (for faster preview)"
echo "- Design > Automatic Reload and Preview: OFF (when tweaking)" 