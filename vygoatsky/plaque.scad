  // Vygoatsky plaque for 3D printing with a layer-based filament swap
  // Slice with a color change at Z = base_thickness to print the text in a second color.

  $fn = 64;

  // --- Dimensions (mm)
  plaque_width      = 110;
  plaque_height     = 120;
  base_thickness    = 2;   // height of the base layer(s); set color change above this
  text_height       = 1.2;   // height of embossed text above base
  border_height     = 1.8;   // height of border ring (double text height)
  border_inset      = 1.0;   // distance from edge
  border_width      = 0.6;   // thickness of border ring
  corner_radius     = 6;
  margin            = 11;
  second_gap        = 5;
  // --- Typography
  // Use fonts installed on your system. On macOS, "Times New Roman" is common.
  // If the chosen fonts are unavailable, change to available ones (e.g., "DejaVu Sans").
  title_text        = "VYGOATSKY";
  title_size        = 9;
  title_font        = "Times New Roman:style=Bold";
  title_height      = 1.2;

  // Poem lines as separate variables (three cycles)
  // Cycle 1: forge → worship → groupthink → turn
  line1 = "We forge our gods from borrowed gold,";
  line2 = "Ornate their claims, belief takes hold.";
  line3 = "We bleat alone then together forge gnosis -";
  line4 = "Dogmatic, doxastic; we share hypnosis.";

  // Cycle 2: devotion → dissolution → flaking → breaking
  line5 = "In proximal zones of bright devotion,";
  line6 = "Truth dissolves in shared emotions.";
  line7 = "Till gold flakes off - one sows its cracks,";
  line8 = "We gild then cast, the herd attacks.";

  // Cycle 3: lone voice → illusion collapses → scapegoat → void → new forge
  line9 = "Collective haze, the crowd's untruth:";
  line10 = "Once set in stone is now uncouth.";
  line11 = "Worship wanes and facade crumbles,";
  line12 = "Goat is scaped, backin caves we fumble.";


  body_size         = 4.3;  // slightly smaller to fit better
    body_font         = "Times New Roman:style=Regular";
  line_spacing      =6.8;  // tighter vertical spacing
  left_margin       = 0;  // center-align text

  // Starting position for first line (below title)
  first_line_y      = 33 ;

  // --- Geometry helpers
  module rounded_rect(w, h, r) {
    // Centered rounded rectangle using offset
    offset(r = r) square([w - 2*r, h - 2*r], center = true);
  }

  module plaque_base() {
    linear_extrude(height = base_thickness)
      rounded_rect(plaque_width, plaque_height, corner_radius);
  }

  module border_ring() {
    // Create raised border ring by difference of two rounded rectangles
    translate([0, 0, base_thickness])
      linear_extrude(height = border_height)
        difference() {
          // Outer rectangle
          rounded_rect(plaque_width - 2 * border_inset, 
                      plaque_height - 2 * border_inset, 
                      corner_radius - border_inset);
          // Inner rectangle (subtract to create ring)
          rounded_rect(plaque_width - 2 * border_inset - 2 * border_width, 
                      plaque_height - 2 * border_inset - 2 * border_width, 
                      corner_radius - border_inset - border_width);
        }
  }

  module emboss_text(txt, size, font, pos, align="center") {
    translate([pos[0], pos[1], base_thickness])
      linear_extrude(height = text_height)
        text(txt, size = size, font = font, halign = align, valign = "center");
  }

  module plaque() {
    union() {
      plaque_base();
      border_ring();  // Add raised border

      // Title near the top edge, centered
      emboss_text(title_text, title_size, title_font,
                  [0, plaque_height/2 - margin - title_height/2], "center");

      // Body text - each line separately, center-aligned
      // Cycle 1
      emboss_text(line1, body_size, body_font, [left_margin, first_line_y], "center");
      emboss_text(line2, body_size, body_font, [left_margin, first_line_y - line_spacing], "center");
      emboss_text(line3, body_size, body_font, [left_margin, first_line_y - line_spacing * 2], "center");
      emboss_text(line4, body_size, body_font, [left_margin, first_line_y - line_spacing * 3], "center");
      
      // Cycle 2
      emboss_text(line5, body_size, body_font, [left_margin, first_line_y - line_spacing * 4 - second_gap], "center");
      emboss_text(line6, body_size, body_font, [left_margin, first_line_y - line_spacing * 5 - second_gap], "center");
      emboss_text(line7, body_size, body_font, [left_margin, first_line_y - line_spacing * 6 - second_gap], "center");
      emboss_text(line8, body_size, body_font, [left_margin, first_line_y - line_spacing * 7 - second_gap], "center");
      
      // Cycle 3
      emboss_text(line9, body_size, body_font, [left_margin, first_line_y - line_spacing * 8 - second_gap * 2], "center");
      emboss_text(line10, body_size, body_font, [left_margin, first_line_y - line_spacing * 9 - second_gap * 2], "center");
      emboss_text(line11, body_size, body_font, [left_margin, first_line_y - line_spacing * 10 - second_gap * 2], "center");
      emboss_text(line12, body_size, body_font, [left_margin, first_line_y - line_spacing * 11 - second_gap * 2], "center");
      emboss_text(line13, body_size, body_font, [left_margin, first_line_y - line_spacing * 12 - second_gap * 2], "center");
      emboss_text(line14, body_size, body_font, [left_margin, first_line_y - line_spacing * 13 - second_gap * 2], "center");
      emboss_text(line15, body_size, body_font, [left_margin, first_line_y - line_spacing * 14 - second_gap * 2], "center");
    }
  }

  // Place plaque with its bottom-left corner at (0,0) for convenience
  translate([plaque_width/2, plaque_height/2, 0]) plaque();

  // --- Slicing Notes ---
  // 1) Set a color change at Z = base_thickness (e.g., 2.0 mm) in your slicer
  //    so the text prints in the second filament color.
  // 2) Ensure text_height provides at least 2 solid layers for reliable coverage
  //    with your layer height (e.g., 0.2 mm -> text_height >= 0.4 mm).
  // 3) If your system lacks the specified fonts, change title_font/body_font
  //    to fonts installed locally (e.g., "DejaVu Sans").