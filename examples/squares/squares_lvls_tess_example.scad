use <../../tess.scad>

// Choose a mode:
// mode = 1 => "levels" arrangement
// mode = 2 => possibly some filtering demonstration
mode = 1;

// Parameters
side = 10; // Side length of each square
spacing = 0;
lvls = 5; // Number of 'levels'

filter_points_levels = [
    [ -20, 40 ], [ -10, 40 ], [ 0, 40 ], [ 10, 40 ], [ 20, 40 ], [ 0, 20 ], [ -10, 20 ], [ 10, 20 ], [ 25, 30 ],
    [ 15, 30 ], [ 5, 30 ], [ -5, 30 ], [ -15, 30 ], [ -25, 30 ]
];
// ECHO: "Unfiltered Centers:", [[-20, -40], [-10, -40], [0, -40], [10, -40], [20, -40], [-25, -30], [-15, -30], [-5,
// -30], [5, -30], [15, -30], [25, -30], [-30, -20], [-20, -20], [-10, -20], [0, -20], [10, -20], [20, -20], [30, -20],
// [-35, -10], [-25, -10], [-15, -10], [-5, -10], [5, -10], [15, -10], [25, -10], [35, -10], [-40, 0], [-30, 0], [-20,
// 0], [-10, 0], [0, 0], [10, 0], [20, 0], [30, 0], [40, 0], [-35, 10], [-25, 10], [-15, 10], [-5, 10], [5, 10], [15,
// 10], [25, 10], [35, 10], [-30, 20], [-20, 20], [-10, 20], [0, 20], [10, 20], [20, 20], [30, 20], [-25, 30], [-15,
// 30], [-5, 30], [5, 30], [15, 30], [25, 30], [-20, 40], [-10, 40], [0, 40], [10, 40], [20, 40]]

if (mode == 1)
{
    centers = squares_centers_lvls(side, lvls);
    echo("Unfiltered Centers:", centers);

    squares(side = side, spacing = spacing, centers = centers, color_scheme = "scheme1");
    print_points(centers, text_size = 1, color = "Blue", pointD = 0.5, point_color = "Red", fn = 12);
}
else if (mode == 2)
{
    // If you want to demonstrate some filtering logic:
    centers = squares_centers_lvls(side, lvls);
    echo("Unfiltered Centers:", centers);
    filtered = filter_center_points(centers, filter_points_levels);
    echo("Filtered Centers:", filtered);
    squares(side = side, spacing = spacing, centers = filtered, color_scheme = "scheme2");
    print_points(filtered, text_size = 1, color = "Blue", pointD = 0.5, point_color = "Red", fn = 12);
}