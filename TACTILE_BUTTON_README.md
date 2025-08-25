# 3D Printed Tactile Button System with JST Connectors

Complete replacement for tactile switches and circuit boards using 3D printed components with integrated JST connectors for LED applications.

## Overview

This system provides a complete 3D printed solution for tactile buttons that can directly connect to LED strip controllers, power supplies, and other electronics via standard JST connectors. No soldering to circuit boards required!

## Key Features

- **Complete 3D Printed Solution**: Housing, button mechanism, and connector interface
- **JST Connector Integration**: Direct connection to LED strips and controllers
- **Tactile Spring Mechanism**: 3D printed flexible spring for tactile feedback
- **Multiple Variants**: Different JST connector types and applications
- **Modular Design**: Easy assembly and customization
- **Professional Feel**: Comparable to commercial tactile switches

## File Structure

```
tactile_button_led.scad      - Main button design (JST-SM series for LED strips)
tactile_button_variants.scad - Additional JST connector types and specialized variants
TACTILE_BUTTON_README.md     - This documentation file
```

## JST Connector Types Supported

### JST-SM Series (Default - LED Strips)
- **Pitch**: 2.5mm
- **Current**: Up to 3A
- **Voltage**: Up to 250V DC
- **Applications**: LED strip lighting, general purpose
- **Wire Gauge**: 22-28 AWG

### JST-PH Series (Battery/Small Devices)
- **Pitch**: 2.0mm  
- **Current**: Up to 2A
- **Voltage**: Up to 50V DC
- **Applications**: Drone batteries, camera batteries, portable electronics
- **Wire Gauge**: 24-30 AWG

### JST-XH Series (RC/3D Printers)  
- **Pitch**: 2.5mm
- **Current**: Up to 3A
- **Voltage**: Up to 250V DC
- **Applications**: RC vehicles, 3D printer connections, motor controllers
- **Wire Gauge**: 22-28 AWG

### JST-VH Series (High Power)
- **Pitch**: 3.96mm
- **Current**: Up to 10A
- **Voltage**: Up to 250V DC  
- **Applications**: Industrial equipment, high-power LED arrays, motor drives
- **Wire Gauge**: 16-22 AWG

## Components Overview

### 1. Housing Base
- Integrated JST connector mounting
- Wire routing channels
- Contact insertion points
- Ventilation and assembly features

### 2. Button Cap
- Tactile dome design
- Grip texture pattern
- Travel distance: 2.5mm
- Multiple size options

### 3. Spring Mechanism
- 3D printed flexible arms
- **Must be printed in TPU or flexible filament**  
- Provides tactile click and return force
- Customizable spring force

### 4. Contact System
- Metal contact inserts required
- Copper or brass pins recommended
- Low contact resistance design
- Wire routing integration

## Printing Instructions

### Materials Required

1. **Housing & Button Cap**: PLA, PETG, or ABS
2. **Spring Mechanism**: TPU or flexible filament (REQUIRED)
3. **Metal Contacts**: Copper/brass pins or tubes
4. **JST Connectors**: Genuine JST or compatible connectors
5. **Wire**: Appropriate AWG for your application

### Print Settings

#### Housing (Main Part)
```
Orientation: Upside down (JST connector side up)
Layer Height: 0.2-0.3mm
Infill: 25-40% 
Supports: Only for JST connector overhangs
Material: PLA/PETG/ABS
```

#### Button Cap  
```
Orientation: Right-side up
Layer Height: 0.2mm (smooth finish)
Infill: 20-30%
Supports: None needed
Material: Same as housing
```

#### Spring Mechanism
```
Material: TPU or flexible filament (ESSENTIAL)
Layer Height: 0.3mm
Infill: 100%
Print Speed: 20-30mm/s (slow for clean flexible parts)
Supports: None
```

### OpenSCAD Rendering

Open the `.scad` files in OpenSCAD and use these commands:

**For individual parts:**
```openscad
// Uncomment one at a time in the file:
print_housing();      // Housing for printing
print_button_cap();   // Button cap
print_spring();       // Spring (TPU only)
```

**For all parts at once:**
```openscad
print_all_parts();    // All components laid out
```

**For variants:**
```openscad
print_jst_variants(); // Different JST connector types
```

## Assembly Instructions

### Step 1: Prepare Metal Contacts
1. Cut copper or brass pins to appropriate length
2. Insert into contact holes in housing base
3. Ensure tight fit and good electrical contact
4. Test continuity with multimeter

### Step 2: Install JST Connector
1. Insert JST connector into housing cavity
2. Ensure proper fit and orientation
3. Route wires through wire channels to contact points
4. Solder connections carefully
5. **Test continuity before proceeding**

### Step 3: Install Spring Mechanism
1. Insert TPU spring into spring cavity
2. Ensure spring arms can compress freely
3. Test compression and return action
4. Spring should provide tactile resistance

### Step 4: Final Assembly
1. Place button cap on top of spring
2. Test button travel (should be ~2.5mm)
3. Verify tactile click sensation
4. Ensure button returns to rest position

### Step 5: Testing
1. Connect JST connector to LED system
2. Test button functionality with loads
3. Verify proper electrical operation
4. Check for any mechanical issues

## Electrical Specifications

| Parameter | Value | Notes |
|-----------|--------|-------|
| Voltage Rating | Up to 12V DC | LED applications |
| Current Rating | Up to 3A* | *Depends on JST series |
| Contact Resistance | <50mΩ | With proper metal contacts |
| Operating Life | 100,000+ cycles | TPU spring dependent |
| Operating Temperature | -10°C to +60°C | PLA housing limits |

## Applications

### LED Strip Control
- On/off switching for LED strips
- Dimmer control integration  
- Color changing triggers
- Scene selection buttons

### RC/Hobby Electronics
- Motor control switches
- Battery disconnect buttons
- Function selection
- Emergency stops

### Home Automation
- Smart lighting controls
- Scene activation buttons
- Device power switching
- Status indication

### Industrial Controls
- Machine operation buttons
- Safety interlocks
- Process control switches
- Indicator light controls

## Customization Options

### Size Scaling
Scale entire assembly by modifying the scale factor:
```openscad
scale([0.75, 0.75, 0.75])  // 75% size (compact)
scale([1.3, 1.3, 1.3])     // 130% size (large)
```

### JST Connector Types
Modify these parameters for different JST series:
```openscad
jst_pin_spacing = 2.0;     // 2.0mm for PH, 2.5mm for XH/SM, 3.96mm for VH
jst_connector_width = 8;   // Adjust for connector size
jst_pin_diameter = 0.8;    // Adjust for pin size
```

### Button Feel
Adjust tactile characteristics:
```openscad
button_travel = 2.5;       // How far button moves
spring_arms = 4;           // Number of spring arms (affects force)
spring_wall_thickness = 1.2; // Spring arm thickness (affects flexibility)
```

### Housing Dimensions  
Modify housing size:
```openscad
housing_width = 25;        // Width of housing
housing_length = 40;       // Length including connector
housing_height = 12;       // Total height
```

## Specialized Variants

### LED Dimmer Button
- Textured button surface for tactile feedback
- Larger button cap for easier operation
- Optimized for PWM dimmer applications

### Illuminated Button
- Built-in LED indicator in button cap
- LED holder ring included
- Requires additional LED and current limiting resistor

### Waterproof Version
- Sealed housing with O-ring groove
- Suitable for outdoor applications
- Requires compatible O-ring seal

### Multi-Button Arrays
- 2x2 button matrix layout
- 1x4 button strip configuration
- Shared mounting system
- Individual JST connections

## Troubleshooting

### Button Doesn't Return
- Check TPU spring installation
- Verify spring isn't compressed permanently
- Ensure button cap isn't binding

### Poor Electrical Contact
- Check metal contact installation
- Verify wire connections and soldering
- Test continuity with multimeter
- Clean contact surfaces

### JST Connector Loose
- Verify connector dimensions and tolerances
- Check for printing dimensional accuracy
- Add small amount of adhesive if needed

### Button Travel Too Soft/Hard
- Adjust spring arm count (spring_arms parameter)
- Modify spring wall thickness
- Consider different TPU shore hardness

## Safety Notes

⚠️ **Important Safety Information**

- **Voltage Limit**: Only use with low voltage DC applications (≤12V)
- **Current Rating**: Ensure proper wire gauge for current requirements
- **Testing**: Always test electrical connections before powering systems
- **Metal Contacts**: Use appropriate materials for current rating needed
- **TPU Material**: Spring mechanism MUST be printed in flexible filament

## Advanced Features

### Conductive Filament Option
For prototypes, conductive filament can be used instead of metal contacts:
- Lower current capacity (~1A max)
- Higher contact resistance
- Suitable for low-power LED applications only

### Multi-Color Printing
Print button caps in different colors for function identification:
- Red: Emergency/stop functions
- Green: Start/go functions  
- Blue: Information/status
- Yellow: Caution/warning

### Surface Mount Integration
Housing can be modified for direct PCB mounting:
- Add mounting tabs with screw holes
- Include alignment features
- Design for specific PCB layouts

## Contributing

This is an open-source design. Contributions welcome:
- Additional JST connector variants
- New specialized button types
- Improved spring mechanisms
- Better printing orientations
- Assembly jigs and tools

## License

Open source design - use freely for personal and commercial applications.

## Version History

- **v1.0**: Initial release with JST-SM series support
- **v1.1**: Added JST-PH, JST-XH, JST-VH variants
- **v1.2**: Added specialized variants (dimmer, illuminated, waterproof)
- **v1.3**: Added multi-button arrays and improved documentation

## Contact

Created by Kyle Mathewson for the Voice2Print project.

---

**Happy 3D Printing!** 🖨️✨ 