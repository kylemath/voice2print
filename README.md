# Voice2Print

An AI-assisted parametric 3D modeling project that uses voice prompting and natural language to generate custom OpenSCAD designs and 3D printable models. This repository contains a diverse collection of functional 3D printed parts created through conversational design with AI.

## Overview

Voice2Print demonstrates the power of AI-assisted CAD design by transforming natural language descriptions and requirements into fully parametric OpenSCAD code. Each design is customizable through parameters and can be modified on-the-fly through further conversation with AI assistants.

### Key Concept

Instead of manually coding CAD models or using traditional GUI-based CAD software, this project uses:
- **Voice/text prompting** to describe desired 3D parts
- **AI code generation** to create parametric OpenSCAD files
- **Iterative refinement** through conversational feedback
- **Import and adaptation** of existing STL files when needed

## Project Structure

### Main Design Files

#### Electronics & Controls

- **`tactile_button_led.scad`** - Complete 3D printed tactile button system with integrated JST connectors for LED applications. Includes housing, button cap, and flexible TPU spring mechanism. Direct replacement for commercial tactile switches.
  
- **`tactile_button_variants.scad`** - Extended variants supporting different JST connector types (JST-PH, JST-XH, JST-VH series) for various power and current ratings. Includes specialized variants for dimmers, illuminated buttons, and multi-button arrays.

- **`tactile_switch_adapter.scad` / `.stl`** - Adapter for mounting commercial tactile switches in custom enclosures.

- **`led_sign.scad` / `.stl`** - Customizable LED sign holder with channel routing for LED strips.

#### Hardware Components

- **`turning_knob_m6.scad` / `.stl`** - Ergonomic turning knob with M6 threaded insert mount. Includes grip texture and tool-free installation.

- **`turning_knob_hex4.scad` / `.stl`** - Alternative knob design with 4mm hex socket for secure mounting.

- **`bearing_washer.scad` / `.stl`** / `bearing_washer_wider.stl` - Custom bearing washers for reducing friction in rotating assemblies.

#### Adapters & Connectors

- **`air_intake_adapter.scad`** - Air intake adapter with funnel inlet and 45° bent neck. Features 3mm male connector output with smooth internal airflow transition. Designed for HVAC and pneumatic applications.

- **`y_splitter_6to4.scad`** - Y-shaped pipe splitter converting 6" inlet to dual 4" outlets. Includes mounting flange and socket joints for standard pipe fitting.

- **`tactile_switch_adapter.scad`** - Universal adapter for integrating commercial tactile switches.

#### Tools & Accessories

- **`pointed_tip_m6.scad` / `.stl`** - Pointed stylus tip with M6 threading. Multiple variants with different lengths and clearances for various applications.

- **`clipboard.scad` / `.stl`** - Functional clipboard with spring clip mechanism.

- **`comb.scad`** - Parametric comb design with customizable tooth spacing and dimensions.

- **`glasses.scad` / `.stl`** - Custom eyeglass frames or holders.

#### Geometric & Display Objects

- **`magendavidillusion.scad`** - Optical illusion design based on geometric patterns.

- **`rectangle_373x235x15.scad`** - Parametric rectangular platform (373mm x 235mm x 15mm).

- **`rectangle_5x5cm.scad`** - Small rectangular base (50mm x 50mm).

- **`cylinder_150cm.scad`** - Large cylindrical structure for specialized applications.

#### Specialized Files

- **`config.scad`** - Configuration file for dirt bike handlebar tool case project. Contains socket database, mounting parameters, and dimensional specifications for tool organization system.

- **`render_optimized.sh`** - Shell script for batch rendering OpenSCAD files with optimization flags for Apple M4 silicon.

- **`openscad_m4_optimization.md`** - Comprehensive guide for optimizing OpenSCAD rendering on Apple Silicon. Includes memory management, CPU utilization, quality settings, and performance monitoring.

### Project Subdirectories

#### `bbs/` - Ball Bearing Sorter

Parametric ball sorting tower that separates ball bearings by diameter. Features:
- **`BallSorter_V2.scad`** - Main ball sorter design with hexagonal hole patterns
- **`BallSorterLid_V2.scad`** - Lid design for the sorter
- **`ballTower.scad`** - Multi-level sorting tower with stackable segments
- **11 hole sizes** from 2.38mm to 10.32mm (3/32" to 13/32")
- **Hexagonal sorting pattern** for optimal spacing
- **Progressive track widening** for efficient sorting
- **Collection trays** for each size category
- **Stackable interlocking segments**
- **Threaded connections** for secure assembly
- **`threads.scad`** - Thread library for creating ISO metric and custom threads

Multiple STL versions available in `bkstl/` showing design evolution from V10 through V14.

#### `BarTool/`

Tool organization system designed for dirt bike handlebars. Integrates with `config.scad` for socket and tool storage.

#### `canCrush/`

Can crushing mechanism designs.

#### `cookies/`

Cookie cutter and food-related mold designs.

#### `IvateGlasses/`

Specialized eyewear project (custom glasses or display systems).

#### `magnets/`

Magnet holder designs and magnetic mounting systems.

#### `scanner/`

3D scanning related accessories and fixtures.

## Workflow

### Typical Design Process

1. **Describe the need** - Explain what physical object is needed through natural language
   - "I need a button that can control LED strips without soldering"
   - "Create a Y-splitter that goes from 6 inch to two 4 inch outlets"

2. **AI generates OpenSCAD code** - The AI assistant writes parametric SCAD code based on requirements
   - Includes proper measurements and tolerances
   - Adds customization parameters
   - Implements best practices for 3D printing

3. **Preview and iterate** - View in OpenSCAD and request modifications
   - "Make the walls thicker"
   - "Add mounting holes"
   - "Increase the tolerance by 0.2mm"

4. **Render to STL** - Export final design for 3D printing
   - Use optimization scripts for faster rendering
   - Generate multiple variants if needed

5. **Print and test** - Physical prototyping
   - Test fit and function
   - Request design modifications if needed
   - Iterate until perfect

### Design Philosophy

- **Parametric first** - All dimensions as variables for easy customization
- **Print-in-place when possible** - Minimize assembly steps
- **Tolerance awareness** - Account for printer tolerances (typically 0.2-0.4mm)
- **Material considerations** - Specify required materials (TPU for flexible parts, PLA/PETG for rigid)
- **Documentation included** - Comments and echo statements explain parameters

## Tools & Technologies

### Software
- **OpenSCAD** - Primary CAD software (https://openscad.org/)
- **AI Assistants** - GPT-4, Claude, or similar for code generation
- **3D Slicing Software** - PrusaSlicer, Cura, or similar

### Hardware
- **3D Printer** - FDM printer with multi-material capability recommended
- **Materials Used**:
  - PLA/PETG/ABS for rigid parts
  - TPU/Flex for springs and flexible components
  - Conductive filament for electrical contacts (experimental)

### Optimization
- Optimized for **Apple Silicon (M4)** - See `openscad_m4_optimization.md`
- Batch rendering scripts provided
- Preview vs. render quality settings
- Memory management for complex models

## Key Features Across Projects

### Common Design Patterns

1. **Threaded Connections** - ISO metric threads using the threads.scad library
2. **Snap-fit Assemblies** - Tool-free assembly with printed tolerances
3. **Parametric Sizing** - Scale objects via parameters rather than global scaling
4. **Modular Components** - Mix and match compatible parts
5. **Print Orientation Optimization** - Designed for minimal supports

### Documentation Standards

- Each major project has dedicated README (e.g., `TACTILE_BUTTON_README.md`)
- Inline comments explain parameters and calculations
- Echo statements output dimensions during rendering
- Printing instructions included as comments

## Getting Started

### Prerequisites
```bash
# Install OpenSCAD
brew install openscad  # macOS with Homebrew

# Or download from https://openscad.org/downloads.html
```

### Basic Usage

1. **Open any .scad file in OpenSCAD**
   ```bash
   open -a OpenSCAD tactile_button_led.scad
   ```

2. **Adjust parameters** at the top of the file
   ```openscad
   button_cap_diameter = 15;  // Change to your preference
   housing_width = 25;         // Modify dimensions
   ```

3. **Preview (F5)** - Fast preview for development
4. **Render (F6)** - Final high-quality render
5. **Export STL** - File → Export → Export as STL

### Batch Rendering

Use the optimization script for multiple files:
```bash
./render_optimized.sh
```

Or manually with optimization:
```bash
nice -n 10 openscad -o output.stl -D '$fn=100' --render input.scad
```

## Notable Projects

### Ball Bearing Sorter (`bbs/`)
The flagship project - a sophisticated sorting mechanism that uses hexagonal hole patterns and progressive widening to efficiently sort ball bearings by size. Features threaded stackable segments and integrated collection trays. Read more in the BBS directory.

### Tactile Button System
Complete replacement for commercial tactile switches, featuring 3D printed spring mechanisms and JST connector integration. Supports multiple connector types for various power applications. See `TACTILE_BUTTON_README.md` for full documentation.

### HVAC Adapters
Professional-grade pipe adapters and splitters for air handling and plumbing. Includes smooth internal transitions for optimal flow characteristics.

## File Formats

- **`.scad`** - OpenSCAD source files (editable, parametric)
- **`.stl`** - Exported 3D models ready for slicing and printing
- **`.md`** - Markdown documentation files
- **`.sh`** - Shell scripts for automation

## Design Specifications

### Typical Tolerances
- **Press-fit**: -0.4mm to -0.2mm
- **Sliding fit**: +0.2mm to +0.4mm
- **Threaded connections**: Per ISO metric standards
- **JST connectors**: +0.2mm tolerance

### Print Settings (General)
- **Layer Height**: 0.2mm (standard), 0.3mm (draft), 0.15mm (fine)
- **Infill**: 20-40% for most parts
- **Supports**: Minimized through design orientation
- **Material**: Specified per component

## Safety Notes

⚠️ **Important Considerations**

- **Electrical components**: Only use with low voltage DC (≤12V) unless specifically rated
- **Load bearing parts**: Verify material strength for your application
- **Food safe**: Only certified food-safe materials for food contact items
- **Pressure vessels**: Not suitable for high-pressure applications without engineering review
- **Functional parts**: Test thoroughly before critical applications

## Contributing

This is an open-source design repository. Contributions welcome:
- New parametric designs
- Improvements to existing models
- Better optimization techniques
- Documentation enhancements
- Testing and feedback

## Credits

Created by **Kyle Mathewson** using AI-assisted design techniques.

Demonstrates the power of:
- Natural language programming
- Iterative AI collaboration
- Parametric design principles
- Rapid prototyping workflows

## License

Open source design - use freely for personal and commercial applications. Attribution appreciated but not required.

## Resources

- [OpenSCAD Documentation](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual)
- [Thingiverse](https://www.thingiverse.com/) - 3D printing community
- [Printables](https://www.printables.com/) - Model sharing platform
- [OpenSCAD Cheat Sheet](https://openscad.org/cheatsheet/)

## Version History

This is a living repository with continuous improvements. Major milestones:
- **Ball Sorter**: V10 → V14 (progressive refinement)
- **Tactile Buttons**: v1.0 → v1.3 (added JST variants)
- **Optimization**: Apple Silicon M4 specific tuning

---

**Happy Voice-to-Printing!** 🎙️ → 🖨️ → 🔩
