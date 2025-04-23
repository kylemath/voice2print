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

// Top row socket parameters
TOP_SOCKET_SPACING = 2;     // Space between top row socket edges
TOP_SOCKET_DEPRESSION = 20; // How deep top row sockets sit in the block
IMPERIAL_SOCKET_SPACING = 2;     // Space between top row socket edges
IMPERIAL_SOCKET_DEPRESSION = 20; // How deep top row sockets sit in the block

// Complete socket database [size, diameter, type]
SOCKET_DATABASE = [
    [4, 11.91, "metric"],
    [5, 11.94, "metric"],
    [6, 11.03, "metric"],
    [7, 11.88, "metric"],
    [8, 11.71, "metric"],
    [9, 13.00, "metric"],
    [10, 13.70, "metric"],
    [11, 15.80, "metric"],
    [12, 16.66, "metric"],
    [13, 17.82, "metric"],
    [14, 19.7, "metric"],
    [0.25, 11.69, "imperial"],  // 1/4"
    [0.3125, 11.6, "imperial"], // 5/16"
    [0.375, 13.66, "imperial"],  // 3/8"
    [0.5, 17.72, "imperial"]     // 1/2"
];

// Function to filter sockets by type
function filter_sockets(type) = [for (socket = SOCKET_DATABASE) if (socket[2] == type) socket];

// Function to get specific sizes while preserving order
function find_socket(size) = [for (socket = SOCKET_DATABASE) if (socket[0] == size) socket][0];
function get_sizes(sizes) = [for (size = sizes) find_socket(size)];

// For this specific print, we want these sizes IN THIS ORDER
SELECTED_SIZES =[14, 13, 12, 11, 10];// Order will be preserved
CURRENT_SOCKETS = get_sizes(SELECTED_SIZES);

// Extract just the sizes and diameters for the selected sockets
SOCKET_SIZES = [for (socket = CURRENT_SOCKETS) socket[0]];
SOCKET_DIAMETERS = [for (socket = CURRENT_SOCKETS) socket[1]];

TOP_SELECTED_SIZES = [ 9, 8, 7, 6, 5, 4];
TOP_CURRENT_SOCKETS = get_sizes(TOP_SELECTED_SIZES);
TOP_SOCKET_SIZES = [for (socket = TOP_CURRENT_SOCKETS) socket[0]];
TOP_SOCKET_DIAMETERS = [for (socket = TOP_CURRENT_SOCKETS) socket[1]];

IMPERIAL_SOCKET_SELECTED_SIZES = [0.25];
IMPERIAL_SOCKET_CURRENT_SOCKETS = get_sizes(IMPERIAL_SOCKET_SELECTED_SIZES);
IMPERIAL_SOCKET_SIZES = [for (socket = IMPERIAL_SOCKET_CURRENT_SOCKETS) socket[0]];
IMPERIAL_SOCKET_DIAMETERS = [for (socket = IMPERIAL_SOCKET_CURRENT_SOCKETS) socket[1]]; 
                create_socket_depressions(IMPERIAL_SOCKET_DIAMETERS, IMPERIAL_SOCKET_SPACING, IMPERIAL_SOCKET_DEPRESSION);

// Function to look up diameter by socket size
function get_socket_diameter(size) = SOCKET_DIAMETERS[search([size], SOCKET_SIZES)[0]];

// Hex Bit Parameters
HEX_BIT_LENGTH = 25;        // Standard length for hex bits
HEX_BIT_DIAMETER = 6.35;    // Standard 1/4" hex bit diameter
HEX_DEPRESSION = 20;        // How deep bits sit in the block
HEX_SPACING = 3;           // Space between hex holes
HEX_COUNT = 5;             // Number of hex bits per row
HEX_ROW_SPACING = 12;      // Spacing between rows of hex bits

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
