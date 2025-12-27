// Letter-sized Clipboard for 3D Printing
// Designed for functionality and durability with separate clothespin
// Paper size: 8.5" x 11" (215.9mm x 279.4mm)

// Global parameters
$fn = 50; // Smoothness for curved surfaces

// Clipboard dimensions (in mm)
paper_width = 215.9;    // 8.5 inches
paper_height = 279.4;   // 11 inches
base_thickness = 4;     // Thickness of the base plate
edge_height = 2;        // Height of raised edges
edge_thickness = 3;     // Thickness of raised edges
margin = 10;            // Margin around paper area

// Calculate total clipboard dimensions
total_width = paper_width + 2 * margin;
total_height = paper_height + 2 * margin;

// Main clipboard assembly
module clipboard() {
    union() {
        // Base plate
        base_plate();
        
        // Raised edges for paper positioning
        paper_edges();
        
        // Clothespin mounting ridge
        clothespin_ridge();
    }
}

// Base plate with rounded corners
module base_plate() {
    corner_radius = 8;
    
    hull() {
        for (x = [-total_width/2 + corner_radius, total_width/2 - corner_radius]) {
            for (y = [-total_height/2 + corner_radius, total_height/2 - corner_radius]) {
                translate([x, y, 0])
                    cylinder(r = corner_radius, h = base_thickness);
            }
        }
    }
}

// Raised edges to keep paper in place
module paper_edges() {
    // Bottom edge (full width)
    translate([0, -paper_height/2 - edge_thickness/2, base_thickness/2])
        cube([paper_width + 2*edge_thickness, edge_thickness, edge_height + base_thickness], center = true);
    
    // Left edge
    translate([-paper_width/2 - edge_thickness/2, 0, base_thickness/2])
        cube([edge_thickness, paper_height, edge_height + base_thickness], center = true);
    
    // Right edge  
    translate([paper_width/2 + edge_thickness/2, 0, base_thickness/2])
        cube([edge_thickness, paper_height, edge_height + base_thickness], center = true);
    
    // Top edge (full width - clothespin will go over this)
    translate([0, paper_height/2 + edge_thickness/2, base_thickness/2])
        cube([paper_width + 2*edge_thickness, edge_thickness, edge_height + base_thickness], center = true);
}

// Small ridge at top for clothespin to grip onto
module clothespin_ridge() {
    translate([0, paper_height/2 + edge_thickness + 2, base_thickness + edge_height/2])
        cube([60, 4, 3], center = true);
}

// Render the complete clipboard
clipboard(); 