// Configuration file for Dirt Bike Handlebar Tool Case
// All measurements in millimeters

// Case Dimensions
CASE_WIDTH = 200;      // ~8 inches wide
CASE_DEPTH = 75;       // ~3 inches deep
CASE_HEIGHT = 30;      // ~2 inches tall when closed
LID_HEIGHT = 25;       // Height of the lid portion

// Bar Mount Parameters
MOUNT_HEIGHT = 52;     // Height of the bar mount
MOUNT_WIDTH = 24;      // Width of the bar mount
MOUNT_SPACING = 104;   // Distance between inside edges of mounts
CAVITY_DEPTH = 25;     // Depth of the cavity below handlebar
SIDEWALL_EXTRATHICKNESS = 26; 

// Handlebar Parameters
HANDLEBAR_DIAMETER = 28.575;  // 1-1/8 inch fat bar
WALL_THICKNESS = 15;           // Wall thickness around mounts
TPU_TOLERANCE = -0.4;         // Negative tolerance for press fit
HANDLEBAR_OFFSET = 8;

// Middle Space before tools
MIDDLESPACE = 0;
MIDDLESPACE_OFFSET = 10;

// Hinge Parameters
HINGE_DIAMETER = 6;          // Diameter of hinge pin
HINGE_LENGTH = CASE_WIDTH - 20;  // Length of hinge

// General Parameters
$fn = 50;                     // Default smoothness for circles
PREVIEW_QUALITY = 20;         // Lower quality for preview
RENDER_QUALITY = 100;         // Higher quality for final render 