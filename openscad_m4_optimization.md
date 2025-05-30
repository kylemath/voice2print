# OpenSCAD Optimization for Apple M4

## Hardware-Specific Optimizations

### 1. **Memory Management**
The M4 has unified memory architecture. Use these settings:

```bash
# Set memory limits to prevent swapping
export OPENSCAD_MEMORY_LIMIT=8192  # 8GB limit (adjust based on your RAM)
```

### 2. **CPU Core Utilization**
```bash
# Check your core count
sysctl -n hw.ncpu
# Use all performance cores efficiently
export OMP_NUM_THREADS=$(sysctl -n hw.ncpu)
```

### 3. **Quality vs Speed Settings**

#### Fast Preview (Development):
- `$fn = 16` - Very fast, rough curves
- `$fa = 12` - Larger angle steps
- `$fs = 2` - Larger fragment size

#### Medium Quality (Testing):
- `$fn = 32` - Good balance
- `$fa = 6` - Medium angles
- `$fs = 1` - Medium fragments

#### High Quality (Final STL):
- `$fn = 100` - Smooth curves
- `$fa = 1` - Fine angles
- `$fs = 0.5` - Fine fragments

## Command Line Optimization

### Basic Rendering:
```bash
openscad -o output.stl --render input.scad
```

### High-Performance Rendering:
```bash
nice -n 10 openscad \
    --export-format=stl \
    -o output.stl \
    -D '$fn=100' \
    --render \
    input.scad
```

### Batch Processing:
```bash
# For multiple files
for file in *.scad; do
    nice -n 10 openscad -o "${file%.scad}.stl" --render "$file" &
done
wait  # Wait for all background jobs to complete
```

## Model-Specific Optimizations

### 1. **Reduce Complexity During Development**
- Comment out complex features while iterating
- Use lower resolution for threads during preview
- Split complex models into modules

### 2. **Threading Optimization**
Your model uses threading which is computationally expensive:
- Consider reducing thread resolution during development
- Use conditional rendering: `$preview ? simple_cylinder() : threaded_cylinder()`

### 3. **Hole Pattern Optimization**
Your hexagonal hole pattern is complex:
- Use fewer holes during preview
- Consider approximating with simpler patterns for testing

## GUI Settings for M4

In OpenSCAD GUI:
1. **Edit > Preferences > Advanced**:
   - Turn off "Automatic reload and preview" during editing
   - Set "Preview timeout" to a reasonable value (10-30 seconds)

2. **View Menu**:
   - Turn off "Show Edges" for faster preview
   - Turn off "Show Axes" if not needed
   - Use wireframe mode for very complex models

3. **Features > Fast Render**:
   - Use F5 for preview (CGAL disabled)
   - Only use F6 for final render (CGAL enabled)

## Memory and Performance Monitoring

```bash
# Monitor memory usage during rendering
top -pid $(pgrep openscad)

# Monitor CPU usage
iostat -c 1

# Check thermal throttling (important for sustained rendering)
sudo powermetrics -n 1 -i 1000 | grep -A5 "CPU Thermal"
```

## Troubleshooting

### If Rendering is Slow:
1. Check Activity Monitor for CPU/Memory usage
2. Ensure adequate cooling (M4 can throttle under sustained load)
3. Close other applications to free memory
4. Consider rendering in parts

### If OpenSCAD Crashes:
1. Reduce complexity (lower $fn, fewer features)
2. Check available memory
3. Try command-line rendering instead of GUI
4. Split model into smaller parts

## Best Practices for Your ballTower.scad

1. **Use conditional complexity**:
   ```scad
   $fn = $preview ? 32 : 100;
   holes_enabled = !$preview;  // Skip holes in preview
   ```

2. **Modular rendering**:
   ```scad
   render_part = "all";  // "all", "cup1", "cup2", etc.
   ```

3. **Progressive complexity**:
   - Start with simple cylinders
   - Add threading last
   - Test each level separately 