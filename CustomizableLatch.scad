// Universal latch v1.0 by DrLex, 2021/07
// Released under Creative Commons - Attribution license

// Parts to generate. Preview is not meant for printing!
parts = "all"; //["preview", "all", "all but cap", "cap", "plates", "hook"]

// Size (width) of the whole thing in mm, everything will be scaled accordingly while preserving tolerances.
size = 35; //[20:.1:100]

// Thickness of the base plates
base_thick = 1; //[.5:0.1:10]

/* [Tweaks] */
// Hook length adjustment to get a tighter (-) or looser (+) fit.
hook_adj = 0; //[-1:.01:1]

// Cap tightness adjustment to get a tighter (-) or looser (+) fit.
cap_adj = 0; //[-.5:.01:.5]

// Tolerance on the radius of the hinge and hook holes. The default should be good on a well-tuned FFF printer.
hole_gap = 0.15; //[0:.01:0.3]


/* [Hidden] */
scale_f = size/35;
tol = .1 / scale_f;
base_thics = base_thick / scale_f;
hook_ads = hook_adj / scale_f;
cap_ads = cap_adj / scale_f;

scale(scale_f) {
    if(parts == "preview") {
        translate([0, 0, base_thics]) hook();

        translate([-25.5, 0, base_thics+4.8+2*tol]) rotate([180, 0, 0]) cap();

        translate([-17.5, 0, 0]) plate1();
        translate([17.5, 0, 0]) plate2();
    }
    else if(parts == "all") {
        translate([-9-1/scale_f, -11-2/scale_f, 0]) hook();

        translate([34+1/scale_f, -8-2/scale_f, 0]) cap();

        translate([-17.5-4/scale_f, 17.5+2/scale_f, 0]) plate1();
        translate([17.5+4/scale_f, 17.5+2/scale_f, 0]) plate2();
    }
    else if(parts == "all but cap") {
        translate([0, -11-2/scale_f, 0]) hook();

        translate([-17.5-4/scale_f, 17.5+2/scale_f, 0]) plate1();
        translate([17.5+4/scale_f, 17.5+2/scale_f, 0]) plate2();
    }
    else if(parts == "plates") {
        translate([-17.5-4/scale_f, 0, 0]) plate1();
        translate([17.5+4/scale_f, 0, 0]) plate2();
    }
    else if(parts == "hook") {
        hook();
    }
    else {
        cap();
    }
}


module hook() {
    r2 = 5 + (hole_gap / scale_f);
    difference() {
        union() {
            translate([hook_ads, 0, 0]) linear_extrude(height=3.6, convexity=4) hook_poly();
            translate([-25.5, 0, 0]) cylinder(h=3.6, r=7.75, $fn=32);
        };

        translate([25.5+hook_ads, 0, -1]) cylinder(h=10, r=r2, $fn=32);
        translate([-25.5, 0, -1]) cylinder(h=10, r=r2, $fn=32);
    };
}

module cap() {
    cylinder(h=1.2, r=7.8, $fn=24);
    // Try to keep tolerance of the clamp consistent across scales.
    z_tol = .2 / scale_f;
    translate([0, 0, cap_ads]) difference() {
        rotate_extrude(convexity=4, $fn=24) polygon(points=[
            [0, .6], [3.14, .6], [3.14, 2.55+z_tol], [3.44, 2.88+z_tol], [3.44, 4.35], [3.08, 5.15], [0, 5.15]
        ]);
        union() {
            translate([-.7, .5, 0]) cube([1.4, 5, 10]);
            rotate([0, 0, 120]) translate([-.7, .5, 0]) cube([1.4, 5, 10]);
            rotate([0, 0, 240]) translate([-.7, .5, 0]) cube([1.4, 5, 10]);
            rotate([0, 0, 90]) cylinder(h=10, r=2.6, $fn=3);
        }
    }
}

module plate1() {
    cap_gap = tol * 2;
    difference() {
        union() {
            translate([-tol/2, 0, 0]) rounded_square(35, base_thics, 2);
            translate([-8, 0, base_thics-.4]) cylinder(h=4+cap_gap, r=5, $fn=32);
            // Alignment block and cone
            translate([17.5-tol/2, 11.65, base_thics-.2]) rotate([90, 0, 0]) linear_extrude(5, convexity=4) polygon(points=[
                [0, 0], [0, 4.7], [-2, 4.7], [-5, 1.7], [-5, 0]
            ]);
            translate([17.5-tol/2-.13, 9.15, base_thics+2]) rotate([0, 90, 0]) cylinder(h=2, r1=2, r2=0, $fn=16);
        }
        // Cap hole
        translate([-8, 0, base_thics-.6+cap_gap]) rotate_extrude(convexity=4, $fn=32) polygon(points=[
            [0, -1], [3.29, -1], [3.29, .1], [3.84, .7], [3.84, 2.1], [3.29, 2.7], [3.29, 8], [0, 8]
        ]);

        // Chop any redundant things off the bottom so we don't need to fine-tune all dimensions to work in every situation
        translate([0, 0, -20]) cube(40, center=true);
    }
}

module plate2() {
    cutout_w = 5 + 4*tol;

    difference() {
        union() {
            translate([tol/2, 0, 0]) rounded_square(35, base_thics, 2);
            translate([8, 0, base_thics-.4]) rotate_extrude(convexity=4, $fn=32) polygon(points=[
                [0, 0], [5, 0], [5, 4], [5.6, 4.6], [5.6, 5], [0, 5]
            ]);
            // Alignment block
            translate([-17.5+tol/2, 15.05, base_thics-.2]) rotate([90, 0, 0]) linear_extrude(11.8, convexity=4) polygon(points=[
                [0, 0], [5, 0], [5, 1.7], [2, 4.7], [-2.45, 4.7], [-2.45, 3.3], [0, .19]
            ]);
        }
        // Alignment cut-out & cone hole
        translate([-17.5-cutout_w/2+tol/2, 9.15, base_thics+2]) cube(cutout_w, center=true);
        translate([-17.5, 9.15, base_thics+2]) rotate([0, 90, 0]) cylinder(h=2, r1=2, r2=0, $fn=16);

        // Chop any redundant things off the bottom so we don't need to fine-tune all dimensions to work in every situation
        translate([0, 0, -20]) cube(40, center=true);
    }
}

module rounded_square(size, height, radius) {
    x = size/2 - radius;
    n = round(radius*10);
    hull() {
        translate([-x, -x, 0]) cylinder(h=height, r=radius, $fn=n);
        translate([x, -x, 0]) cylinder(h=height, r=radius, $fn=n);
        translate([x, x, 0]) cylinder(h=height, r=radius, $fn=n);
        translate([-x, x, 0]) cylinder(h=height, r=radius, $fn=n);
    }
}

module hook_poly() {
    polygon(convexity=4, points=[
        [-20.0, -3.0],
        [13.156, -3.0],
        [14.535, -3.156],
        [15.975, -3.609],
        [17.337, -4.314],
        [18.453, -5.219],
        [19.313, -6.187],
        [20.173, -6.942],
        [21.125, -7.578],
        [22.152, -8.084],
        [23.235, -8.452],
        [24.358, -8.675],
        [25.5, -8.75],
        [26.642, -8.675],
        [27.765, -8.452],
        [28.848, -8.084],
        [29.875, -7.578],
        [30.827, -6.942],
        [31.687, -6.187],
        [32.442, -5.327],
        [33.078, -4.375],
        [33.584, -3.348],
        [33.952, -2.265],
        [34.175, -1.142],
        [34.25, 0.0],
        [34.175, 1.142],
        [33.984, 2.269],
        [33.773, 3.583],
        [33.621, 4.853],
        [33.527, 6.113],
        [33.505, 7.251],
        [33.614, 7.391],
        [34.06, 7.576],
        [34.443, 7.87],
        [34.737, 8.253],
        [34.922, 8.699],
        [34.985, 9.178],
        [34.922, 9.657],
        [34.737, 10.103],
        [34.443, 10.486],
        [34.06, 10.78],
        [33.614, 10.965],
        [33.135, 11.028],
        [32.656, 10.965],
        [32.21, 10.78],
        [31.827, 10.486],
        [31.533, 10.103],
        [31.331, 9.645],
        [31.045, 8.836],
        [30.634, 7.112],
        [30.318, 5.718],
        [30.083, 4.509],
        [29.91, 3.399],
        [29.91, 1.929],
        [29.0, -3.0],
        [22.0, -3.0],
        [20.556, -1.214],
        [20.051, -0.356],
        [19.547, 0.247],
        [18.68, 1.016],
        [17.531, 1.816],
        [16.223, 2.452],
        [14.884, 2.859],
        [13.644, 3.0],
        [-20.0, 3.0]
    ]);
}

