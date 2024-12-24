/*
    Tessella: Regular Tessellation - Hexagons
    =========================================
    This module implements the tessellation of a plane using regular hexagons,
    where each tile is congruent, and all vertex angles around a point sum to 360°.

    Polygon properties:
    - Sides: 6
    - Interior Angle: 120°
    - Vertex Configuration: 6.6.6

    Mathematically valid because the interior angle divides 360° exactly.
    Reference: Euclidean tessellation theory for regular polygons.
*/

include <../tessUtils.scad>;

/**
 * @brief Generates center points for a hexagonal tessellation based on levels.
 *
 * Creates a hexagon-based grid of points arranged in a radial pattern with a specified number of levels.
 *
 * @param radius The radius of each hexagon.
 * @param levels The number of levels in the radial pattern.
 * @return An array of center points for hexagons.
 */
function hexagon_centers_lvls(radius, levels) = let(
    offset_x = radius * cos(30),          // Horizontal offset between hexagons
    offset_y = radius + radius * sin(30), // Vertical offset between hexagons
    offset_step = 2 * offset_x,           // Step size for horizontal movement
    dx = -(levels - 1) * offset_x * 2,    // Center x shift to align the pattern
    dy = 0,                               // Center y shift; not required due to generation algorithm
    beginning_n = 2 * levels - 1,         // Initial number of hexagons in the central row

    // Function to generate points for a row of hexagons
    hexagons_pts = function(hex_datum)
        let(tx = hex_datum[0][0] + dx,                                      // Translated x-coordinate
            ty = hex_datum[0][1] + dy,                                      // Translated y-coordinate
            n_pts = hex_datum[1],                                           // Number of hexagons in this row
            offset_xs = [for (i = 0; i < n_pts; i = i + 1) i * offset_step] // X offsets for hexagons
            )[for (x = offset_xs)[x + tx, ty]],                             // Generate center points for the row

    // Upper half of the hexagon grid
    upper_hex_data = levels > 1 ? [for (i = [1:beginning_n - levels]) let(x = offset_x * i, y = offset_y * i,
                                                                          n_upper = beginning_n - i) [[x, y], n_upper]]
                                : [],

    // Lower half of the hexagon grid (mirrored upper half)
    lower_hex_data = levels > 1
                         ? [for (hex_datum = upper_hex_data) [[hex_datum [0] [0], -hex_datum [0] [1]], hex_datum [1]]]
                         : [],

    // Combine all hexagon data
    total_hex_data = [ [ [ 0, 0 ], beginning_n ], each upper_hex_data, each lower_hex_data ],

    // Generate all center points
    centers = [for (hex_datum = total_hex_data) let(pts = hexagons_pts(hex_datum))[for (pt = pts) pt]])
    concat([for (c = centers) each c]);

/**
 * @brief Generates center points for a rectangular hexagonal grid (n x m).
 *
 * Creates a rectangular grid of hexagon center points suitable for tiling an area.
 *
 * @param radius The radius of each hexagon.
 * @param n The number of hexagons along the x-axis.
 * @param m The number of hexagons along the y-axis.
 * @return An array of center points for hexagons.
 */
function hexagon_centers_NxM(radius, n, m) =
    let(offset_x = radius * cos(30),          // Horizontal offset between hexagons
        offset_y = radius + radius * sin(30), // Vertical offset between hexagons
        offset_step = 2 * offset_x,           // Step size for horizontal movement
        // Function to generate grid points
        generate_rectangular_points = function(
            n, m, offset_step,
            offset_y)[for (i = [0:n - 1], j = [0:m - 1])[i * offset_step + (j % 2) * (offset_step / 2), j *offset_y]])
        generate_rectangular_points(n, m, offset_step, offset_y);

/**
 * @brief Renders hexagons at specified centers with optional color gradient.
 *
 * Draws 2D hexagons based on the provided center points, applying spacing and color gradients if specified.
 *
 * @param radius The radius of each hexagon.
 * @param spacing (Optional) Spacing between hexagons, default is 0.
 * @param hexagon_centers (Optional) Array of center points. If not provided, levels or n and m must be specified.
 * @param levels (Optional) Number of levels for radial pattern generation.
 * @param n (Optional) Number of hexagons along x-axis for rectangular grid.
 * @param m (Optional) Number of hexagons along y-axis for rectangular grid.
 * @param color_scheme (Optional) Name of the color scheme for gradient.
 * @param alpha (Optional) Alpha transparency value.
 */
module hexagons(radius, spacing = 0, hexagon_centers = [], levels = undef, n = undef, m = undef, color_scheme = undef,
                alpha = undef)
{
    if (len(hexagon_centers) == 0 && !is_undef(levels))
    {
        // Generate hexagon centers based on levels
        hexagon_centers = hexagon_centers_lvls(radius, levels);
    }
    else if (len(hexagon_centers) == 0 && !is_undef(n) && !is_undef(m))
    {
        // Generate hexagon centers based on n x m grid
        hexagon_centers = hexagon_centers_NxM(radius, n, m);
    }
    else if (len(hexagon_centers) == 0)
    {
        echo("No hexagon centers provided and 'levels' & 'n' x 'm' is undefined.");
    }

    // Determine the range of the center points for normalization
    min_x = min([for (center = hexagon_centers) center[0]]);
    max_x = max([for (center = hexagon_centers) center[0]]);
    min_y = min([for (center = hexagon_centers) center[1]]);
    max_y = max([for (center = hexagon_centers) center[1]]);

    for (center = hexagon_centers)
    {
        // Normalize coordinates for color gradient
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        color_val = get_gradient_color(normalized_x, normalized_y, color_scheme);

        // If color_scheme is not specified, use default color
        if (is_undef(color_scheme))
        {
            color_val = [ 0.9, 0.9, 0.9 ]; // Default grey color
        }

        // Draw the hexagon at the specified center
        color(color_val, alpha = alpha) translate([ center[0], center[1], 0 ]) rotate(30)
            circle(radius - spacing / 2, $fn = 6); // Hexagon shape
    }
}

/**
 * @brief Renders extruded hexagons at specified centers with optional color gradient.
 *
 * Draws 3D hexagonal prisms based on the provided center points, applying spacing and color gradients if specified.
 *
 * @param radius The radius of each hexagon.
 * @param height The extrusion height of the hexagons.
 * @param spacing (Optional) Spacing between hexagons, default is 0.
 * @param hexagon_centers (Optional) Array of center points. If not provided, levels or n and m must be specified.
 * @param levels (Optional) Number of levels for radial pattern generation.
 * @param n (Optional) Number of hexagons along x-axis for rectangular grid.
 * @param m (Optional) Number of hexagons along y-axis for rectangular grid.
 * @param color_scheme (Optional) Name of the color scheme for gradient.
 * @param alpha (Optional) Alpha transparency value.
 */
module hexagonsSolid(radius, height, spacing = 0, hexagon_centers = [], levels = undef, n = undef, m = undef,
                     color_scheme = undef, alpha = undef)
{
    if (len(hexagon_centers) == 0 && !is_undef(levels))
    {
        // Generate hexagon centers based on levels
        hexagon_centers = hexagon_centers_lvls(radius, levels);
    }
    else if (len(hexagon_centers) == 0 && !is_undef(n) && !is_undef(m))
    {
        // Generate hexagon centers based on n x m grid
        hexagon_centers = hexagon_centers_NxM(radius, n, m);
    }
    else if (len(hexagon_centers) == 0)
    {
        echo("No hexagon centers provided and 'levels' is undefined.");
    }

    // Determine the range of the center points for normalization
    min_x = min([for (center = hexagon_centers) center[0]]);
    max_x = max([for (center = hexagon_centers) center[0]]);
    min_y = min([for (center = hexagon_centers) center[1]]);
    max_y = max([for (center = hexagon_centers) center[1]]);

    for (center = hexagon_centers)
    {
        // Normalize coordinates for color gradient
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        color_val = get_gradient_color(normalized_x, normalized_y, color_scheme);

        // If color_scheme is not specified, use default color
        if (is_undef(color_scheme))
        {
            color_val = [ 0.9, 0.9, 0.9 ]; // Default grey color
        }

        // Draw the extruded hexagon at the specified center
        color(color_val, alpha = alpha) translate([ center[0], center[1], 0 ]) linear_extrude(height = height)
            rotate(30) circle(radius - spacing / 2, $fn = 6); // Hexagon shape
    }
}