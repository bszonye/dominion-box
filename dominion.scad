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

function sum(v) = v ? [for(p=v) 1]*v : 0;

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

// measured card sizes
// 3.5mm / 16 index card layers = 440 microns/pile (220 per index card layer)
// victory cards (sets of 12)
// echo(v12=5.0/12, vdeck(12, euro_sleeve, ug_premium));
// 4.8-5.0mm w/UG sleeves = 400-417 microns/card
// 5.2-5.5mm w/index cover = 450 microns/pile (225 per index card layer)
// action cards (sets of 10)
// echo(a10=4.2/10, vdeck(10, euro_sleeve, ug_premium));
// 4.0-4.2mm w/UG sleeves = 400-420 microns/card
// 4.4-4.6mm w/index cover = 400 microns/pile (200 per index card layer)
// silver cards (set of 70)
// echo(s70=29/70, vdeck(70, euro_sleeve, ug_premium));
// 29mm / 70 Dominion cards = 414 microns/card
// gold cards (set of 48)
// echo(g48=20.0/48, vdeck(48, euro_sleeve, ug_premium));
// 19.7-20.5mm w/UG sleeves = 410-427 microns/card
// gold cards (set of 30)
// echo(g30=12.6/30, vdeck(30, euro_sleeve, ug_premium));
// echo(g30=9.6/30, vdeck(30, euro_sleeve, no_sleeve));
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
    vext = [vint.x + 2*wall, vint.y + 2*wall, vint.z + wall + gap0];
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
Nplayers = 6;  // many components come in sixes
Vcard = euro_sleeve;
Hcard = dominion_card + sk_standard;
Hboard = 2.25;  // tile & token thickness -- TODO
Vmanual1 = [210, 297];  // approximate (Dominion, Intrigue, Seaside)
Vmanual2 = [235, 286];  // approximate (Prosperity)
Vmanual = [max(Vmanual1.x, Vmanual2.x), max(Vmanual1.y, Vmanual2.y), 3];
// mats
// TODO: verify dimensions found online
Vmtrash = [200, 110, 1.5];
Vmexile = [128, 84, 1.5];  // TODO: verify
Vmvillagers = [84, 128, 1.5];  // TODO: verify
Vmcoffers = [126, 84, 1.5];  // TODO: verify
Vmseaside = [82.5, 126.5, 3.05];  // 3 mats, ~1mm each
Vmtavern = [125, 82, 1.5];  // TODO: verify
Vmprosperity = [80, 80, 1.15];
Nmprosperity = 9;  // 8 VP mats + 1 Trade Route mat
Lmats = [Vmexile, Vmvillagers, Vmcoffers, Vmseaside, Vmtavern, Vmprosperity];
// Adventures tokens
// TODO: verify dimensions found online
Hadventures = 2;  // token thickness
Dadvround = 23;  // round token diameter
Nadvround = 8 * Nplayers;
Vadvsquare = [44, 34, 2];  // square token dimensions
Nadvsquare = 2 * Nplayers;

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
Dstrut = 12;  // width of struts and corner braces

// vertical layout
Hroom = ceil(Vinterior.z - Vmanual.z);
Hdeck = 65;
Htray = 27;
Hhalf = flayer(Htray/2);
echo(Hroom=Hroom, Hdeck+Htray, Hdeck=Hdeck, Htray=Htray, Hhalf=Hhalf);

module prism(h, shape=undef, r=undef, r1=undef, r2=undef,
             scale=1, center=false) {
    module curve() {
        ri = !is_undef(r1) ? r1 : !is_undef(r) ? r : 0;  // inside turns
        ro = !is_undef(r2) ? r2 : !is_undef(r) ? r : 0;  // outside turns
        if (ri || ro) offset(r=ro) offset(r=-ro-ri) offset(r=ri) children();
        else children();
    }
    linear_extrude(height=h, scale=scale, center=center) curve()
    if (is_undef(shape)) children();
    else if (is_list(shape) && is_list(shape[0])) polygon(shape);
    else square(shape, center=true);
}

module lattice_cut(v, i, j=0, h0=0, d=Dstrut, a=Avee, r=Rint, tiers=1,
                   factors=2, center=false) {
    // v: lattice volume
    // i: horizontal position
    // j: vertical position
    // h0: z intercept of pattern start (e.g. floor0 with wall_vee_cut)
    // d: strut width
    // a: strut angle
    // r: corner radius
    // tiers: number of tiers in vertical split
    // factors: verticial divisibility (use 6/12/etc for complex patterns)
    // center: start pattern at center instead of end
    hlayers = factors*round(nlayer(v.z-d)/factors);
    htri = zlayer(hlayers / tiers); // trestle height
    dtri = 2*eround(htri/tan(a));  // trestle width (triangle base)
    dycut = v.y + 2*gap0; // depth for cutting through Y axis
    tri = [[dtri/2, -htri/2], [0, htri/2], [-dtri/2, -htri/2]];
    xstrut = eround(d/2/sin(a));
    flip = 1 - (2 * abs(i % 2));
    z0 = qlayer(v.z - htri*tiers) / 2;
    x0 = center ? -dtri/2 : eround((z0 - h0) / tan(a)) + xstrut;
    y0 = (dycut - gap0)/2;
    limit = [v.x-d, v.z];
    translate([0, y0, 0])
        rotate([90, 0, 0]) linear_extrude(dycut)
        offset(r=r) offset(r=-d/2-r) intersection() {
            translate([x0, z0] + [(i+j+1)/2*dtri, (j+1/2)*htri])
                scale([1, flip]) polygon(tri);
            translate(center ? [-limit.x/2, 0] : [d/2, 0]) square(limit);
        }
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
    Vcard.y + 2*Rext, d,
    round(Vcard.x + floor0 + 1)]);
function deck_frame_volume(d) = vround([  // d = frame length
    Vcard.x + 2*Rext, d, Vcard.y]);
function card_tray_volume(v) = vround([
    v.x + 2*Rext,
    v.y + 2*Rext,
    v.z + Rtop + floor0]);

Dlong = Vfloor.y / 2;
Vlong = deck_box_volume(Dlong);
Dshort = Vfloor.x - 4*Vlong.x;
Vshort = deck_box_volume(Dshort);
Vmats = [135, Dshort, Hdeck+Htray];
module deck_box(d, seed=undef, color=undef) {
    vbox = deck_box_volume(d);
    shell = [vbox.x, vbox.y];
    well = shell - 2*[wall0, wall0];
    // notch dimensions:
    dtop = vbox.x - 2*Dstrut;  // corner supports
    hvee = qlayer(vbox.z - dtop/2 * sin(Avee));
    vend = [dtop/2, vbox.y, vbox.z-hvee];
    ystrut = Dstrut + Htray/tan(Avee);
    hside = Dstrut;
    // hside = qlayer(vbox.z - (vbox.y/2 - ystrut) * sin(Avee));  // hexagon
    dside = vbox.y - 2*ystrut - 2*(vbox.z-hside)/tan(Avee);
    vside = [dside, vbox.x, vbox.z-hside];
    color(color) difference() {
        // outer shell
        prism(vbox.z, shell, r=Rext);
        // card well
        raise() prism(vbox.z, well, r=Rint);
        // base round
        raise(-gap0) prism(vbox.z, shell - 2*[Dstrut, Dstrut], r=Dthumb/2);
        // side cuts
        raise(hvee) wall_vee_cut(vend);  // end vee
        if (vbox.x < vbox.y) {
            // side vee
            raise(hside) rotate(90) wall_vee_cut(vside);
        } else {
            // lattice
            vlattice = [vbox.y, vbox.x, vbox.z];
            rotate(90) for (i=[-2:1:+2]) lattice_cut(vlattice, i, center=true);
        }
    }
    %if (!is_undef(seed))
        translate([0, Rext-d/2, floor0+epsilon])
            random_piles(d-2*Rext, seed=seed);
}
module mat_frame(size, color=undef) {
    shell = [size.x, size.y];
    well = shell - 2*[wall0, wall0];
    // notch dimensions:
    hvee = qlayer(Dstrut);
    axvee = max(atan(2 * (size.z-Dstrut) / (size.x-3*Dstrut)), Avee);
    ayvee = max(atan(2 * (size.z-Dstrut) / (size.y-3*Dstrut)), Avee);
    dxvee = size.x - 2*Dstrut - 2*(size.z-hvee) / tan(axvee);
    dyvee = size.y - 2*Dstrut - 2*(size.z-hvee) / tan(ayvee);
    vxside = [dxvee, size.y, size.z-hvee];
    vyside = [dyvee, size.x, size.z-hvee];
    color(color) difference() {
        // outer shell
        prism(size.z, shell, r=Rext);
        // card well
        raise(floor0) prism(size.z+2*gap0, well, r=Rint);
        // base round
        vhole = [(shell.x-3*Dstrut)/2, shell.y-2*Dstrut];
        raise(-gap0) for(i=[-1,+1])
            translate([i*(shell.x-vhole.x-2*Dstrut)/2, 0])
            prism(size.z, vhole, r=Dthumb/2);
        // vee cuts
        raise(hvee) {
            wall_vee_cut(vxside, a=axvee);  // end cuts
            rotate(90) wall_vee_cut(vyside, a=ayvee);  // side cuts
        }
        // lattice cuts
        x0 = dxvee/2 - hvee/tan(axvee);
        for (i=[-1,+1]) scale([i, 1]) translate([x0, 0])
            lattice_cut([size.x/2-x0, size.y, size.z], 0, a=axvee);
    }
}
module player_mats(d, n=Nplayers, lean=true) {
    vmat = [for (mat=Lmats) [max(mat.x, mat.y), min(mat.x, mat.y), mat.z]];
    dstack = sum([for (mat=vmat) mat.z]);
    ylean = d - n*dstack + Rint;
    hpile = max([for (mat=vmat) mat.y]);
    lean(hpile, ylean, lean ? 0 : 90)
    for (i=[0:1:n-1]) color(player_colors[5-i], 0.5) {
        translate([0, n*dstack-d/2]) rotate([90, 0, 0])
        raise(i*dstack) for (j=[0:1:len(vmat)-1]) {
            mat = vmat[j];
            dy = sum([for (k=[0:1:j-1]) vmat[k].z]);
            translate([0, mat.y/2, dy]) prism(mat.z, [mat.x, mat.y]);
        }
    }
}

card_colors = [
    "#f0f0ff",  // action (gray)
    "#ffff00",  // treasure (yellow)
    "#a0a0ff",  // reaction (blue)
    "#00ff00",  // victory (green)
    "#8000ff",  // curse (purple)
    "#c0a0ff",  // attack (light purple)
    "#ff8000",  // duration (orange)
    "#806000",  // ruins (brown)
    "#202020",  // night (black)
    "#ffc080",  // reserve (tan)
    "#c00000",  // shelter(red)
];
player_colors = [
    "#ff0000",
    "#ff8000",
    "#ffff00",
    "#00ff00",
    "#a0a0ff",
    "#ffffff",
];
function supply_pile_size(n, index=false) =
    n*Hcard + (index ? 2*index_card : 0);
module supply_pile(n=10, index=false, up=false, wide=true,
                   color=card_colors[0]) {
    hcards = supply_pile_size(n);
    hindex = supply_pile_size(n, index=index);
    spin = index || up ? wide ? [0, -90, -90] : [-90, 0, 0] : 0;
    color(color, 0.5) union() {
        raise(spin ? wide ? Vcard.x/2 : Vcard.y/2 : 0) rotate(spin)
            raise(index ? index_card : 0) prism(hcards, Vcard);
        if (index) index_wrapper(n=n, solid=true, wide=wide,color=color);
    }
    translate(spin ? [0, hindex, 0] : [0, 0, hcards]) children();
}
module index_wrapper(n=10, solid=false, wide=true, color=card_colors[0]) {
    h = supply_pile_size(n);
    margin = 4.5;
    vwrap = wide ?
        [Vcard.y-2*margin, h+2*index_card, Vcard.x-margin] :
        [Vcard.x-2*margin, h+2*index_card, Vcard.y-margin];
    color(color, 0.5) difference() {
        translate([0, h/2+index_card]) hull() {
            raise(margin)
                prism(vwrap.z, [vwrap.x, vwrap.y]);
            raise(vwrap.z+margin) rotate([90, 0, 90])
                prism(vwrap.x, center=true)
                stadium_fill([vwrap.y, 2*index_card]);
        }
        if (!solid)
            raise((vwrap.z+margin)/2)
                rotate(wide ? [0, -90, -90] : [-90, 0, 0])
                raise(index_card) prism(h, Vcard);
    }
}
Vcolordist = [0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 5, 6];
function random_colors(n=1, seed=0, weights=Vcolordist) =
    [for (x=rands(0, 0.9999, n, seed))
        card_colors[weights[floor(x*len(weights))]]];
module index_piles(d, n=undef, cards=10, wide=true, colors=[card_colors[0]]) {
    dy = supply_pile_size(cards, index=true);
    piles = is_undef(n) ? floor(d/dy) : n;
    for (i=[0:1:piles-1]) translate([0, i*dy]) {
        supply_pile(n=cards, index=true, wide=wide,
                    color=colors[i % len(colors)]);
    }
    translate([0, dy*piles]) children();
}
module random_piles(d, seed=0) {
    d10 = supply_pile_size(10, index=true);
    d12 = supply_pile_size(12, index=true);
    nx = rands(0, 0.9999, 2, seed);
    ncmax = floor(d / d10);
    skip = floor(ncmax*nx[0]/4);
    nc = ncmax - skip;
    dc = nc*d10;
    dv = d - dc;
    nvmax = floor(min(dv / d12, skip/2));
    nv = floor(nvmax*nx[0]);
    c = random_colors(nc, seed=seed+1);
    index_piles(dv, nv, cards=12, colors=[card_colors[3]])
    index_piles(dc, nc, cards=10, colors=c);
}
module lean(h, d, amin=0) {
    alean = max(acos(d/h), amin);
    mlean = [
        [1, 0, 0, 0],
        [0, 1, cos(alean), 0],
        [0, 0, sin(alean), 0],
    ];
    multmatrix(m=mlean) children();
}
module starter_decks(d, n=Nplayers, wide=true, lean=true) {
    dy = supply_pile_size(20, index=true);
    ylean = d - n*dy + Rint;
    hpile = (wide ? Vcard.x : Vcard.y) + index_card;
    lean(hpile, ylean, lean ? 0 : 90) for (i=[0:1:n-1]) {
        translate([0, i*dy]) {
            index_wrapper(n=20, wide=wide, color=player_colors[i]);
            translate([0, index_card]) {
                supply_pile(7, up=true, wide=wide, color=card_colors[1])
                supply_pile(3, up=true, wide=wide, color=card_colors[3])
                supply_pile(3, up=true, wide=wide, color=card_colors[10])
                supply_pile(7, up=true, wide=wide, color=card_colors[1]);
            }
        }
    }
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
    starters = [
        card_colors[1], card_colors[3], card_colors[1], card_colors[10],
    ];
    %color("#101080", 0.25) box(Vinterior, frame=true);
    for (k=[-1,+1]) scale([1, k]) translate([0, Vfloor.y/2-gap0/2]) {
        for (j=[-1,+1]) scale([j, 1]) translate([Vshort.y/2-Vlong.x/2, 0])
            for (i=[1,2]) translate([i*(Vlong.x+gap0), Vlong.y/2-Vfloor.y])
                deck_box(Dlong, seed=k*100+j*10+i);
    }
    translate(-[0, Vmats.x/2 - Vfloor.y/2 - gap0/2]) rotate(-90) {
        mat_frame(Vmats);
        %raise(floor0+epsilon) player_mats(Vmats.y-2*Rext);
    }
    raise(Htray) translate([0, Vshort.x/2 - Vfloor.y/2 - gap0/2]) rotate(-90) {
        deck_box(Dshort);
        %raise(floor0+epsilon) translate([0, Rext-Dshort/2])
            starter_decks(Dshort-2*Rext);
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
    // TODO: Dark Ages special cards
    // TODO: Nocturne special cards
}

*deck_box(Dlong);
*deck_box(Dshort);
*mat_frame(Vmats);

organizer();
