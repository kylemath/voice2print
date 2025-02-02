// Configuration file for Dirt Bike Handlebar Tool Case
// All measurements in millimeters

// Case Dimensions
CASE_WIDTH = 200;      // ~8 inches wide
CASE_DEPTH = 80;       // ~3 inches deep
CASE_HEIGHT = 30;      // ~2 inches tall when closed
LID_HEIGHT = 25;       // Height of the lid portion

// Bar Mount Parameters
MOUNT_HEIGHT = 52;     // Height of the bar mount
MOUNT_WIDTH = 24;      // Width of the bar mount
MOUNT_SPACING = 104;   // Distance between inside edges of mounts
CAVITY_DEPTH = 25;     // Depth of the cavity below handlebar
MOUNT_GAP_DEPTH = 9.525;     // 3/8 inch
SIDEWALL_EXTRATHICKNESS = 26; 

// Handlebar Parameters
HANDLEBAR_DIAMETER = 28.575;  // 1-1/8 inch fat bar
WALL_THICKNESS = 15;           // Wall thickness around mounts
TPU_TOLERANCE = -0.4;         // Negative tolerance for press fit
HANDLEBAR_OFFSET = 8;

// Middle Space before tools
MIDDLESPACE = 0;
MIDDLESPACE_OFFSET = 10;

// General Parameters
$fn = 50;                     // Default smoothness for circles
PREVIEW_QUALITY = 20;         // Lower quality for preview
RENDER_QUALITY = 100;         // Higher quality for final render 


// Socket Parameters
SOCKET_LENGTH = 24.8;        // Length of sockets
BLOCK_DEPTH = 25;          // Total height of socket block
SOCKET_DEPRESSION = 20;      // How deep sockets sit in the block
SOCKET_SPACING = 2;         // Space between socket edges
SIDE_SPACE = 15;            // Space between socket array and side of case
CORNER_RADIUS = 3;         // Radius for rounded corners
// Socket sizes (diameter, not drive size)
SOCKET_DIAMETERS = [17.82, 16.66, 13.73, 11.68, 11.61, 11.69];  // 1/2", 12mm, 10mm, 8mm, 6mm, 1/4" sockets

// Hex Bit Parameters
HEX_BIT_LENGTH = 25;        // Standard length for hex bits
HEX_BIT_DIAMETER = 6.35;    // Standard 1/4" hex bit diameter
HEX_DEPRESSION = 20;        // How deep bits sit in the block
HEX_SPACING = 3;           // Space between hex holes
HEX_COUNT = 5;             // Number of hex bits per row
HEX_ROW_SPACING = 15;      // Spacing between rows of hex bits

// Extension Parameters
EXT_TOTAL_LENGTH = 76.33;   // Total length of extension
EXT_MAIN_DIAMETER = 8.2;    // Main shaft diameter
EXT_MAIN_LENGTH = 50;       // Length of main section
EXT_MALE_LENGTH = 7.5;      // Length of male end
EXT_MALE_WIDTH = 6.35;      // 1/4" square male end
EXT_MALE_TAPER = 2.5;       // Taper length to male end
EXT_FEMALE_LENGTH = 13.4;   // Length of female end
EXT_FEMALE_DIAMETER = 12;   // Outer diameter of female end
EXT_FEMALE_TAPER = 3;       // Taper length to female end
EXT_DEPRESSION = 20;        // How deep extension sits in block

// Long Depression Parameters
LONG_DEPRESSION_LENGTH = 130;  // Length of the long depression
LONG_DEPRESSION_WIDTH = 13.6;  // Width of the long depression
LONG_DEPRESSION_DEPTH = 18;    // Depth of the long depression

// Triangle Depression Parameters
TRIANGLE_BASE = 76.23;        // Base length of triangle
TRIANGLE_HEIGHT = 130;        // Height of triangle
TRIANGLE_DEPTH = 10;          // Depth of depression
