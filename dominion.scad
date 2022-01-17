echo("\n\n====== DOMINION ORGANIZER ======\n\n");

$fa = 15;  // 24 segments per circle (aligns with axes)
$fs = 0.1;

inch = 25.4;
phi = (1+sqrt(5))/2;

layer_height = 0.2;
extrusion_width = 0.45;
extrusion_overlap = layer_height * (1 - PI/4);
extrusion_spacing = extrusion_width - extrusion_overlap;

// convert between path counts and spacing, qspace to quantize
function xspace(n=1) = n*extrusion_spacing;
function nspace(x=xspace()) = x/extrusion_spacing;
function qspace(x=xspace()) = xspace(round(nspace(x)));
function cspace(x=xspace()) = xspace(ceil(nspace(x)));
function fspace(x=xspace()) = xspace(floor(nspace(x)));

// convert between path counts and width, qwall to quantize
function xwall(n=1) = xspace(n) + (0<n ? extrusion_overlap : 0);
function nwall(x=xwall()) =  // first path gets full extrusion width
    x < 0 ? nspace(x) :
    x < extrusion_overlap ? 0 :
    nspace(x - extrusion_overlap);
function qwall(x=xwall()) = xwall(round(nwall(x)));
function cwall(x=xwall()) = xwall(ceil(nwall(x)));
function fwall(x=xwall()) = xwall(floor(nwall(x)));

// quantize thin walls only (less than n paths wide, default for 2 perimeters)
function qthin(x=xwall(), n=4.5) = x < xwall(n) ? qwall(x) : x;
function cthin(x=xwall(), n=4.5) = x < xwall(n) ? cwall(x) : x;
function fthin(x=xwall(), n=4.5) = x < xwall(n) ? fwall(x) : x;

// convert between layer counts and height, qlayer to quantize
function zlayer(n=1) = n*layer_height;
function nlayer(z=zlayer()) = z/layer_height;
// quantize heights
function qlayer(z=zlayer()) = zlayer(round(nlayer(z)));
function clayer(z=zlayer()) = zlayer(ceil(nlayer(z)));
function flayer(z=zlayer()) = zlayer(floor(nlayer(z)));

epsilon = 0.01;
function eround(x, e=epsilon) = e * round(x/e);
function eceil(x, e=epsilon) = e * ceil(x/e);
function efloor(x, e=epsilon) = e * floor(x/e);
function tround(x) = eround(x, e=0.05);  // twentieths of a millimeter
function tceil(x) = eceil(x, e=0.05);  // twentieths of a millimeter
function tfloor(x) = efloor(x, e=0.05);  // twentieths of a millimeter

// tidy measurements
function vround(v) = [tround(v.x), tround(v.y), qlayer(v.z)];
function vceil(v) = [tceil(v.x), tceil(v.y), clayer(v.z)];
function vfloor(v) = [tfloor(v.x), tfloor(v.y), flayer(v.z)];

// fit checker for assertions
// * vspec: desired volume specification
// * vxmin: exact minimum size from calculations or measurements
// * vsmin: soft minimum = vround(vxmin)
// true if vspec is larger than either minimum, in all dimensions.
// logs its parameters if vtrace is true or the comparison fails.
vtrace = true;
function vfit(vspec, vxmin, title="vfit") = let (vsmin = vround(vxmin))
    (vtrace && vtrace(title, vxmin, vsmin, vspec)) ||
    (vxmin.x <= vspec.x || vsmin.x <= vspec.x) &&
    (vxmin.y <= vspec.y || vsmin.y <= vspec.y) &&
    (vxmin.z <= vspec.z || vsmin.z <= vspec.z) ||
    (!vtrace && vtrace(title, vxmin, vsmin, vspec));
function vtrace(title, vxmin, vsmin, vspec) =  // returns undef
    echo(title) echo(vspec=vspec) echo(vsmin=vsmin) echo(vxmin=vxmin)
    echo(inch=[for (i=vspec) eround(i/inch)]);

// card dimensions
card = [2.5*inch, 3.5*inch];  // standard playing card dimensions
euro_card = [59, 92];
playing_card = 0.35;  // common unsleeved card thickness (UG assumes 0.325)
dominion_card = 0.32;  // measured ca. 320 microns per card
index_card = 0.25;  // measured 200-250 microns per layer

// Gamegenic sleeves
sand_sleeve = [81, 122];  // Dixit
orange_sleeve = [73, 122];  // Tarot
magenta_sleeve = [72, 112];  // Scythe
brown_sleeve = [67, 103];  // 7 Wonders
lime_sleeve = [82, 82];  // Big Square
blue_sleeve = [73, 73];  // Square
dark_blue_sleeve = [53, 53];  // Mini Square
gray_sleeve = [66, 91];  // Standard Card
purple_sleeve = [62, 94];  // Standard European
ruby_sleeve = [46, 71];  // Mini European
green_sleeve = [59, 91];  // Standard American
yellow_sleeve = [44, 67];  // Mini American
catan_sleeve = [56, 82];  // Catan (English)

// Sleeve Kings sleeves
euro_sleeve = [62, 94];  // Standard European
super_large_sleeve = [104, 129];

// sleeve thickness
no_sleeve = 0;
md_standard = 0.08;  // 40 micron sleeves (Mayday standard)
ug_classic = 0.08;  // 40 micron sleeves (Ultimate Guard classic)
ug_premium = 0.10;  // 50 micron sleeves (Ultimate Guard premium soft)
sk_standard = 0.125;  // 60 micron sleeves (Sleeve Kings standard)
md_premium = 0.18;  // 90 micron sleeves (Mayday premium)
gg_prime = 0.20;  // 100 micron sleeves (Gamegenic prime)
sk_premium = 0.20;  // 100 micron sleeves (Sleeve Kings premium)
ug_supreme = 0.23;  // 115 micron sleeves (Ultimate Guard supreme)
double_sleeve = 0.30;  // 100 + 50 micron double sleeve

function card_count(h, quality=no_sleeve, card=dominion_card) =
    floor(h / (card + quality));
function vdeck(n=1, sleeve, quality, card=dominion_card, wide=false) = [
    wide ? max(sleeve.x, sleeve.y) : min(sleeve.x, sleeve.y),
    wide ? min(sleeve.x, sleeve.y) : max(sleeve.x, sleeve.y),
    n*(quality+card)];

echo(vdeck(70, euro_sleeve, ug_premium));  // ultimate guard premium soft
echo(vdeck(286, euro_sleeve, ug_premium)+[0, 0, 27*2*index_card]);
echo(vdeck(286, euro_sleeve, sk_standard)+[0, 0, 27*2*index_card]);
// measured card sizes
// 3.5mm / 16 index card layers = 440 microns/pile (220 per index card layer)
// victory cards (sets of 12)
echo(v12=5.0/12, vdeck(12, euro_sleeve, ug_premium));
// 4.8-5.0mm w/UG sleeves = 400-417 microns/card
// 5.2-5.5mm w/index cover = 450 microns/pile (225 per index card layer)
// action cards (sets of 10)
echo(a10=4.2/10, vdeck(10, euro_sleeve, ug_premium));
// 4.0-4.2mm w/UG sleeves = 400-420 microns/card
// 4.4-4.6mm w/index cover = 400 microns/pile (200 per index card layer)
// silver cards (set of 70)
echo(s70=29/70, vdeck(70, euro_sleeve, ug_premium));
// 29mm / 70 Dominion cards = 414 microns/card
// gold cards (set of 48)
echo(g48=20.0/48, vdeck(48, euro_sleeve, ug_premium));
// 19.7-20.5mm w/UG sleeves = 410-427 microns/card
// gold cards (set of 30)
echo(g30=12.6/30, vdeck(30, euro_sleeve, ug_premium));
echo(g30=9.6/30, vdeck(30, euro_sleeve, no_sleeve));
// 12.3-12.7mm w/UG sleeves = 410-423 microns/card
// 9.2-9.6mm unsleeved = 307-320 microns/card

// basic metrics
wall0 = xwall(4);
floor0 = qlayer(wall0);
gap0 = 0.1;  // TODO: clean up gap/cut/joint code

function unit_axis(n) = [for (i=[0:1:2]) i==n ? 1 : 0];

// utility modules
module raise(z=floor0) {
    translate([0, 0, z]) children();
}
module rounded_square(r, size) {
    offset(r=r) offset(r=-r) square(size, center=true);
}
module stadium(side, r=undef, d=undef, a=0) {
    radius = is_undef(d) ? r : d/2;
    u = [cos(a), sin(a)];
    hull() {
        if (side) rotate(a) square([side, 2*radius], center=true);
        for (i=[-1,+1]) translate(i*u*side/2) circle(radius);
    }
}
module stadium_fill(size) {
    if (is_list(size)) {
        if (size.x < size.y) stadium(size.y - size.x, d=size.x, a=90);
        else if (size.y < size.x) stadium(size.x - size.y, d=size.y);
        else circle(d=size.x);
    } else stadium_fill([size, size]);
}
module semistadium(side, r=undef, d=undef, a=0, center=false) {
    radius = is_undef(d) ? r : d/2;
    angle = a+90;  // default orientation is up
    u = [cos(angle), sin(angle)];
    translate(center ? -u*(side+radius)/2 : [0, 0]) hull() {
        rotate(angle) translate([side/2, 0])
            square([max(side, epsilon), 2*radius], center=true);
        translate(u*side) intersection() {
            circle(radius);
            rotate(angle) translate([radius, 0]) square(2*radius, center=true);
        }
    }
}
module semistadium_fill(size, center=false) {
    if (is_list(size)) {
        if (size.y < size.x)
            semistadium(size.x - size.y/2, d=size.y, a=-90, center=center);
        else
            semistadium(size.y - size.x/2, d=size.x, center=center);
    } else semistadium_fill([size, size], center=center);
}

module tongue(size, h=floor0, h0=undef, h1=undef, h2=undef,
              a=60, groove=false, gap=gap0) {
    // groove = false: positive image. gap is inset from the bounding box.
    // groove = true: negative image. gap is extended above top and below base.
    hroof = !is_undef(h2) ? h2 : h;  // height of column above tongue
    hfloor = !is_undef(h1) ? h1 : h;  // height of tongue
    hbevel = !is_undef(h0) ? h0 : hfloor/2;  // height of bevel
    htop = groove ? hfloor+gap : min(hroof, hfloor+gap);

    slope = tan(a);
    vfloor = groove ? size : size - [gap, gap];
    vbevel = vfloor + [2, 2] * (hfloor-hbevel) / slope;
    vtop = vfloor + [2, 2] * (hfloor-htop) / slope;

    // vtop is higher than vfloor if we're cutting a groove or extending up
    // into a prism. this avoids some messy interactions between the hull and
    // other objects at the same height like floors.
    hull() {
        linear_extrude(htop) stadium_fill(vtop);
        linear_extrude(hbevel) stadium_fill(vbevel);
    }
    if (hroof != htop) linear_extrude(hroof) stadium_fill(vfloor);
    if (groove) linear_extrude(2*gap, center=true) stadium_fill(vbevel);
}

// box metrics
Vfloor = [475, 288];  // box floor
Vinterior = [Vfloor.x, Vfloor.y, 94];  // box interior
// TODO: measure art wrap
Hwrap0 = 53;  // cover art wrap ends here
Hwrap1 = 56;  // avoid stacks between 53-56mm total height
module box(size, wall=1, frame=false, a=0) {
    vint = is_list(size) ? size : [size, size, size];
    vext = [vint.x + 2*wall, vint.y + 2*wall, vint.z + wall];
    vcut = [vint.x, vint.y, vint.z - wall];
    origin = [0, 0, vext.z/2 - wall];
    translate(origin) rotate(a) {
        difference() {
            cube(vext, center=true);  // exterior
            raise(wall/2) cube(vint, center=true);  // interior
            raise(2*wall) cube(vcut, center=true);  // top cut
            if (frame) {
                for (n=[0:2]) for (i=[-1,+1])
                    translate(2*i*unit_axis(n)*wall) cube(vcut, center=true);
            }
        }
        raise(Hwrap0 + wall-vext.z/2)
            linear_extrude(Hwrap1-Hwrap0) difference() {
            square([vint.x+wall, vint.y+wall], center=true);
            square([vint.x, vint.y], center=true);
        }
    }
}

// component metrics
Hboard = 2.25;  // tile & token thickness
Vmanual1 = [210, 297];  // approximate (Dominion, Intrigue, Seaside)
Vmanual2 = [235, 286];  // approximate (Prosperity)
Vmanual = [max(Vmanual1.x, Vmanual2.x), max(Vmanual1.y, Vmanual2.y), 3];

// container metrics
Hlid = floor0;  // height of cap lid
Hplug = floor0;  // depth of lid below cap
Hcap = Hlid+Hplug;  // total height of lid + plug

Rsnug = 0*gap0;  // snug joint radius for friction fit
Rlid = 1*gap0;  // lid joint radius (dx from lid/plug to container wall)
Rext = 2.5;  // external corner radius
Rint = Rext-wall0;  // internal corner radius (dx from contents to wall)
Rtop = flayer(Rext);  // vertical corner radius
echo(Rext=Rext, Rint=Rint, Rtop=Rtop);

Hseam = gap0;  // space between lid cap and box (display only)
Avee = 60;  // angle for index v-notches and lattices
Dthumb = 25;  // index hole diameter

// vertical layout
Hroom = ceil(Vinterior.z - Vmanual.z) - 1;
function tier_height(k) = k ? flayer(Hroom/k) : Vinterior.z;
function tier_number(z) = floor(Hroom/z);
function tier_ceil(z) = tier_height(tier_number(z));
function tier_room(z) = tier_ceil(z) - z;

// general layout
// designed around box quadrants with some diagonal space across the center
// reserved for focus bar storage.  the focus bars themselves sit to one side,
// but the walls span the midline for stabilitiy.
Rfloor = norm(Vfloor) / 2;  // major radius of box = 203.64mm
Vtray = [135, 85];  // small tray block
// main tier heights: two thick layers + one thinner top layer
Htier = 25;
Htop = 15;

module prism(h, shape=undef, r=undef, r1=undef, r2=undef, scale=1) {
    module curve() {
        ri = !is_undef(r1) ? r1 : !is_undef(r) ? r : 0;  // inside turns
        ro = !is_undef(r2) ? r2 : !is_undef(r) ? r : 0;  // outside turns
        if (ri || ro) offset(r=ro) offset(r=-ro-ri) offset(r=ri) children();
        else children();
    }
    linear_extrude(height=h, scale=scale) curve()
    if (is_undef(shape)) children();
    else if (is_list(shape) && is_list(shape[0])) polygon(shape);
    else square(shape, center=true);
}

module lattice_cut(v, i, j=0, h0=0, d=4.8, a=Avee, r=Rint,
                   half=0, tiers=1, factors=2) {
    // v: lattice volume
    // i: horizontal position
    // j: vertical position
    // h0: z intercept of pattern start (e.g. floor0 with wall_vee_cut)
    // d: strut width
    // a: strut angle
    // r: corner radius
    // half: -1 = left half, 0 = whole, +1 = right half
    // tiers: number of tiers in vertical split
    // factors: verticial divisibility (use 6/12/etc for complex patterns)
    hlayers = factors*round(nlayer(v.z-d)/factors);
    htri = zlayer(hlayers / tiers); // trestle height
    dtri = 2*eround(htri/tan(a));  // trestle width (triangle base)
    dycut = v.y + 2*gap0; // depth for cutting through Y axis
    tri = [
        [[0, -htri/2], [0, htri/2], [-dtri/2, -htri/2]],  // left
        [[dtri/2, -htri/2], [0, htri/2], [-dtri/2, -htri/2]],  // whole
        [[0, -htri/2], [0, htri/2], [dtri/2, -htri/2]],  // half
    ];
    xstrut = eround(d/2/sin(a));
    flip = 1 - (2 * (i % 2));
    z0 = qlayer(v.z - htri*tiers) / 2;
    x0 = eround((z0 - h0) / tan(a)) + xstrut;
    y0 = dycut - gap0;
    translate([x0, y0, z0] + [(i+j+1)/2*dtri, 0, (j+1/2)*htri])
        scale([1, 1, flip]) rotate([90, 0, 0]) linear_extrude(dycut)
        offset(r=r) offset(r=-d/2-r) polygon(tri[sign(half)+1]);
}
module wall_vee_cut(size, a=Avee, gap=wall0/2) {
    span = size.x;
    y0 = -2*Rext;
    y1 = size.z;
    rise = y1;
    run = a == 90 ? 0 : rise/tan(a);
    x0 = span/2;
    x1 = x0 + run;
    a1 = (180-a)/2;
    x2 = x1 + Rext/tan(a1);
    x3 = x2 + Rext + epsilon;  // needs +epsilon for 90-degree angles
    poly = [[x3, y0], [x3, y1], [x1, y1], [x0, 0], [x0, y0]];
    rotate([90, 0, 0]) linear_extrude(size.y+2*gap, center=true)
    difference() {
        translate([0, y1/2+gap/2]) square([2*x2, y1+gap], center=true);
        for (s=[-1,+1]) scale([s, 1]) hull() {
            offset(r=Rext) offset(r=-Rext) polygon(poly);
            translate([x0, y0]) square([x3-x0, -y0]);
        }
    }
}

function deck_box_volume(d) = vround([  // d = box length
    euro_sleeve.y + 2*Rext, d,
    euro_sleeve.x + floor(floor0+0.5)]);
function card_tray_volume(v) = vround([
    v.x + 2*Rext,
    v.y + 2*Rext,
    v.z + Rtop + floor0]);

Dlong = Vfloor.y / 2;
Vlong = deck_box_volume(Dlong);
Dshort = Vfloor.x - 4*Vlong.x;
Vshort = deck_box_volume(Dshort);
clong = card_count(Vlong.y-2*Rext, sk_standard);
cshort = card_count(Vshort.y-2*Rext, sk_standard);
echo(clong=clong, cshort=cshort, total=8*clong+2*cshort);
module deck_box(d, color=undef) {
    vbox = deck_box_volume(d);
    shell = [vbox.x, vbox.y];
    well = shell - 2*[wall0, wall0];
    // notch dimensions:
    hvee = qlayer(vbox.z/2);  // half the height of the box
    dvee = 2*hvee/tan(Avee);  // point of the vee exactly at the base
    dtop = 2*vbox.z/tan(Avee);  // width of the vee at the top
    dcorner = (vbox.x - dtop) / 2;  // width of the corner wall top
    aside = max(Avee, atan(vbox.z / (vbox.y/2 - dcorner)));
    dside = vbox.y - 2*dcorner - 2*(vbox.z-hvee)/tan(aside);
    vend = [dvee, vbox.y, vbox.z-hvee];
    vside = [dside, vbox.x, vbox.z-hvee];
    color(color) difference() {
        // outer shell
        prism(vbox.z, shell, r=Rext);
        // card well
        raise() prism(vbox.z, well, r=Rint);
        // base round
        raise(-gap0) prism(vbox.z, shell - [Dthumb, Dthumb], r=Dthumb/2);
        // wall cuts
        raise(hvee) {
            wall_vee_cut(vend);  // end cuts
            if (2*dcorner+Rtop <= vbox.y)  // side cuts, if they fit
                rotate(90) wall_vee_cut(vside, a=aside);
        }
    }
}

card_colors = [
    "#c0c0c0",  // action (gray)
    "#ffff00",  // treasure (yellow)
    "#c0c0ff",  // reaction (blue)
    "#00ff00",  // victory (green)
    "#8000ff",  // curse (purple)
    "#8060ff",  // attack (light purple)
    "#ff8000",  // duration (orange)
    "#806000",  // ruins (brown)
    "#202020",  // night (black)
    "#ff8060",  // reserve (tan)
];
module supply_pile(n, index=false, color=card_colors[0]) {
    prism();
}

module card_well(deck, tray=undef, a=Avee, gap=gap0) {
    // TODO: improve conversions between deck, well, and shell sizes
    vtray = tray ? tray : card_tray_volume(deck);
    shell = [vtray.x, vtray.y];
    well = shell - 2*[wall0, wall0];
    raise() linear_extrude(vtray.z-floor0+gap)
        rounded_square(Rint, well);
    raise(-gap) linear_extrude(floor0+2*gap) {
        // thumb round
        xthumb = 2/3 * Dthumb;  // depth of thumb round
        translate([0, -gap-vtray.y/2])
            semistadium(xthumb-Dthumb/2+gap, d=Dthumb);
        // bottom index hole
        if (3*Dthumb < min(vtray.x, vtray.y)) {
            // large tray: large, square index hole
            rounded_square(Dthumb/2, vtray - 2*[Dthumb, Dthumb]);
        } else if (3/2*Dthumb+2*xthumb < vtray.y) {
            // medium tray: 1/2 thumb between holes, 2/3 thumb to edge
            dy = vtray.y - 2*xthumb - Dthumb/2;
            translate([0, Dthumb/4]) stadium(dy-Dthumb, d=Dthumb, a=90);
        } else if (3.5*Dthumb < vtray.x) {
            // wide tray: two small holes with balanced margins
            u0 = [0, xthumb-Dthumb/2-vtray.y/2];  // center of thumb round
            u1 = [Dthumb/2, u0.y+Dthumb*sin(60)];
            u2 = [vtray.x/2-Dthumb/2, vtray.y/2-Dthumb/2];  // corner of tray
            t = 1-(1/phi);  // distance from u0 to u1
            ut = t*(u2-u1) + u1;
            for (i=[-1,+1]) translate([i*ut.x, ut.y]) circle(d=Dthumb);
        } else {
            // small tray: long index notch, 1/2 thumb longer than usual
            translate([0, -vtray.y]/2)
                semistadium(xthumb, d=Dthumb);
        }
    }
    raise() translate([0, wall0-vtray.y]/2)
        wall_vee_cut([Dthumb, wall0, vtray.z-floor0], a=a, gap=gap);
}

module card_tray(deck, tray=undef, color=undef) {
    vtray = tray ? tray : card_tray_volume(deck);
    shell = [vtray.x, vtray.y];
    well = shell - [2*wall0, 2*wall0];
    color(color) difference() {
        linear_extrude(vtray.z) rounded_square(Rext, shell);
        card_well(deck, vtray);
    }
    // card stack
    %raise(floor0 + deck.z/2) cube(deck, center=true);
}

module organizer() {
    // box shape and manuals
    // everything needs to fit inside this!
    %color("#101080", 0.25) box(Vinterior, frame=true);
    for (k=[-1,+1]) scale([1, k]) translate([0, Vfloor.y/2+gap0/2]) {
        translate([0, gap0/2-Vshort.x/2]) rotate(90) deck_box(Dshort);
        for (j=[-1,+1]) scale([j, 1]) translate([Vshort.y/2-Vlong.x/2, 0])
            for (i=[1,2]) translate([i*(Vlong.x+gap0), -Vlong.y/2])
                deck_box(Dlong);
    }
    // TODO: manuals
    // TODO: trash board
    // TODO: basic cards
    // TODO: kingdom cards
    // TODO: randomizers
    // TODO: blank cards
    // TODO: event cards
    // TODO: coin tokens
    // TODO: vp tokens
    // TODO: embargo tokens
    // TODO: Seaside mats
    // TODO: Prosperity mats
    // TODO: Dark Ages special cards
    // TODO: Nocturne special cards
}

// tests for card trays
module test_trays() {
}

*deck_box(Dlong);
*deck_box(Dshort);

*test_trays();
organizer();
