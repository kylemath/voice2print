// Import the base tube and rotate it 90 degrees around Y axis
rotate([90, 90, 0]) 
    translate([-220, 0, 0])
        import("TubeBottom.stl");

// Add side pieces to partially close the window
module side_piece() {
    height = 50;  
    width = 10;    
    depth = 4;    
    
    cube([width, depth, height]);
}

// Left side piece
translate([-10, -42, -18]) rotate([0,0,-5])side_piece();
// Left side piece
translate([-18, -39, -18]) rotate([0,0,-20]) side_piece();

// Right side piece
translate([-10, 38, -18]) side_piece();

// Left side piece
translate([-10, 38, -18]) rotate([0,0,3])side_piece();
// Left side piece
translate([-18, 34.5, -18]) rotate([0,0,20]) side_piece();
