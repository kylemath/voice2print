// Cylinder 10cm tall, 150cm diameter
// All dimensions in millimeters

// Parameters
height = 100;    // 10 cm in mm
radius = 75;    // 150 cm diameter = 1500mm diameter = 750mm radius
faces = 50;
// Create cylinder
cylinder(h = height, r = radius, center = true, $fn = faces);

// Note: center=true places the cylinder centered on the z-axis
// This makes it easier to work with in most cases 