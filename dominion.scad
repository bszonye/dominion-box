echo("\n\n====== DOMINION ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

// general metrics
Vcard = Vsleeve_euro;
Hcard = Hcard_dominion + Hsleeve_kings;
Htray = 13;

// Dominion-specific metrics
Dstrut = 12.0;  // width of lattice struts
Dlong = Vgame.y / 2;
Vlong = deck_box_volume(width=Dlong);
Dshort = Vgame.x - 4*Vlong.y;
Vlongtray = [Dshort, Dlong, Htray];
echo(Dlong=Dlong, Dshort=Dshort);
Hdeck = Hfloor + Vcard.x + Hlip;  // deckbox height
Hstack = Hdeck + 2*Htray;
echo(Hdeck=Hdeck, Hstack=Hstack);

// box metrics
// TODO: metrics for standard and small expansion boxes
Vgame = [472, 288, 94];  // big box interior
Hwrap = 79;  // cover art wrap ends here, approximately

// component metrics
Nplayers = 6;  // many components come in sixes
Hmanual = 2;
Vmanual1 = [210, 297];  // approximate (Dominion, Intrigue)
Vmanual2 = [202, 285];  // approximate (Seaside)
Vmanual3 = [235, 286];  // approximate (Prosperity)
Vmanual = [max(Vmanual1.x, Vmanual2.x, Vmanual3.x),
           max(Vmanual1.y, Vmanual2.y, Vmanual3.x), Hmanual];

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
Vmats = [Vgame.y - Vlongtray.y, Dshort, Hstack];
// Adventures tokens
// TODO: verify dimensions found online
Hadventures = 2;  // token thickness
Dadvround = 24;  // round token diameter
Nadvround = 8 * Nplayers;
Vadvsquare = [45, 35, 2];  // square token dimensions
Nadvsquare = 2 * Nplayers;

// colors
card_colors = [
    "#f0f0ff",  //  0 = action (gray)
    "#ffff00",  //  1 = treasure (yellow)
    "#a0a0ff",  //  2 = reaction (blue)
    "#008000",  //  3 = victory (green)
    "#8000ff",  //  4 = curse (purple)
    "#c0a0ff",  //  5 = attack (light purple)
    "#ff8000",  //  6 = duration (orange)
    "#804000",  //  7 = ruins (brown)
    "#404040",  //  8 = night (black)
    "#ffc080",  //  9 = reserve (tan)
    "#c00000",  // 10 = shelter (red)
    "#c0ff80",  // 11 = boon (light green)
    "#000080",  // 12 = hex (dark blue)
];
Caction = card_colors[0];
Ctreasure = card_colors[1];
Creaction = card_colors[2];
Cvictory = card_colors[3];
Ccurse = card_colors[4];
Cattack = card_colors[5];
Cduration = card_colors[6];
Cruins = card_colors[7];
Cnight = card_colors[8];
Creserve = card_colors[9];
Cshelter = card_colors[10];
Cboon = card_colors[11];
Chex = card_colors[12];
Cgold = "#ffc000";
Csilver = "#a0a0a0";
Ccopper = "#c08000";
player_colors = [
    "#ffffff",
    "#ff0000",
    "#ff9000",
    "#ffff00",
    "#00ff00",
    "#a0a0ff",
];

module lattice_cut(v, i, j=0, h0=0, dstrut=Dstrut/2, angle=Avee, r=Rint,
                   tiers=1, flip=false, open=false, center=false, cut=Dcut) {
    // v: lattice volume
    // i: horizontal position
    // j: vertical position
    // h0: z intercept of pattern start (e.g. Hfloor with wall_vee_cut)
    // d: strut width
    // angle: strut angle
    // r: corner radius
    // tiers: number of tiers in vertical split
    // center: start pattern at center instead of end
    htri = (v.z - dstrut) / tiers; // trestle height
    dtri = 2*eround(htri/tan(angle));  // trestle width (triangle base)
    dycut = v.y + 2*cut; // depth for cutting through Y axis
    dzcut = v.z + 2*cut; // height for cutting through Z axis
    tri = [[dtri/2, -htri/2], [0, htri/2], [-dtri/2, -htri/2]];
    xstrut = eround(dstrut/2/sin(angle));
    z0 = (v.z - htri*tiers) / 2;
    x0 = center ? 0 : eround((z0 - h0) / tan(angle)) + xstrut + dtri/2;
    y0 = dycut/2;
    nx = center ? i : i + j;
    x = nx/2 * dtri;
    y = (j+1/2) * htri;
    yflip = (1 - (2 * abs((nx+j) % 2))) * (flip ? -1 : +1);
    limit = [v.x-dstrut, v.z];
    xlimit = center ? -limit.x/2 : dstrut/2;
    translate([0, y0, 0]) rotate([90, 0, 0]) linear_extrude(dycut) {
        offset(r=r) offset(r=-dstrut/2-r) intersection() {
            translate([x0, z0] + [x, y])
                scale([1, yflip]) polygon(tri);
            translate([xlimit, 0]) square(limit);
        }
    }
    if (open && j+1 == tiers && yflip < 0) {
        xvee = x0 + x;
        hvee = z0 + y;
        dvee = dtri/2 - 2*xstrut;
        if (xlimit <= xvee - dtri/2 && xvee + dtri/2 <= xlimit+limit.x) {
            translate([xvee, 0, hvee])
                wall_vee_cut([dvee, v.y, v.z-hvee], angle=angle);
        }
    }
}

module mat_frame(size=Vmats, color=undef) {
    v = volume(size);
    well = area(v) - area(3*Dwall);
    echo(v=v, well=well);
    // notch dimensions:
    dtop = size.x - 2*Dstrut;  // corner supports
    htri = (size.z - Dstrut/2) / 3;
    hvee = htri/2 + Dstrut/2;  // halfway up the first tier
    dtri = 2*eround(htri/tan(Avee));  // trestle width (triangle base)
    xstrut = eround(Dstrut/2/sin(Avee));
    vend = [dtri/2-xstrut/2, size.y, size.z-hvee];
    colorize(color) difference() {
        // outer shell
        prism(v, r=Rext);
        // card well
        raise(Hfloor) prism(well, height=size.z+2*Dgap, r=Rint);
        // base round
        vhole = [(v.x-2*Dthumb)/3, v.y-Dthumb];
        echo(vhole=vhole);
        raise(-Dgap) for(i=[-1:1:+1])
            translate([i*(v.x-vhole.x-Dthumb)/2, 0])
            prism(vhole, height=size.z, r=Dthumb/2);
        // side cuts
        raise(hvee) wall_vee_cut(vend);  // end vee
        // lattice
        ysize = [size.y, size.x, size.z];
        for (j=[0:1:2]) for (i=[-4:1:+4]) {
            lattice_cut(size, i, j, tiers=3, flip=true, center=true);
            rotate(90)
                lattice_cut(ysize, i, j, tiers=3, flip=true, center=true);
        }
    }
}
module player_token_tray(scoop=2*Rext, color=undef) {
    vtray = Vtray;
    shell = [vtray.x, vtray.y];
    origin = [Dwall-shell.x/2, Dwall-shell.y/2];
    wella = [vtray.x-2*Dwall, Vlongtray.y - vtray.y - Dwall];
    wellb = [(vtray.x-3*Dwall)/2, vtray.y - wella.y - 3*Dwall];
    colorize(color) difference() {
        prism(vtray, r=Rext);
        raise(Hfloor) {
            walls = 2 * area(Dwall);
            dva = (vtray - wella - walls) / 2;
            dvb = (wellb - vtray + walls) / 2;
            translate(dva)
                scoop_well(wella, vtray.z-Hfloor);
            for (i=[-1,+1]) translate([i*dvb.x, dvb.y])
                scoop_well(wellb, vtray.z-Hfloor);
        }
        tray_feet_cut();
    }
    %raise(vtray.z) children();
}
module metal_token_tray(scoop=2*Rext, color=undef) {
    vtray = Vlongtray;
    shell = [vtray.x, vtray.y];
    origin = [Dwall-shell.x/2, Dwall-shell.y/2];
    wella = [vtray.x-2*Dwall, vtray.y - Vtray.y - Dwall];
    wellb = [(vtray.x-3*Dwall)/2, vtray.y - 2*wella.y - 4*Dwall];
    colorize(color) difference() {
        prism(vtray, r=Rext);
        walls = 2 * area(Dwall);
        dva = (vtray - wella - walls) / 2;
        dvb = (wellb - vtray + walls) / 2;
        raise(Hfloor) for (i=[-1,+1]) {
            translate([0, i*dva.y])
                scoop_well(wella, vtray.z-Hfloor);
            translate([i*dvb.x, 0])
                scoop_well(wellb, vtray.z-Hfloor);
        }
        tray_feet_cut();
    }
    %raise(vtray.z) children();
}

module raise_deck(n=0, deck=1, gap=Dgap/2) {
    raise(deck*(Hdeck+gap) + n*(Htray+gap)) children();
}
module layout_tray(n, rows=4, gap=Dgap) {
    col = floor(n/rows);  // column number
    row = floor(n-col*rows);  // row number
    sx = 1 - 2*(col % 2);  // x side (-1 left / +1 right)
    nx = sx * floor(col/2);  // x distance from center
    ny = row + (1 - rows)/2;  // y distance from center
    dy = Vgame.y / rows + gap;  // row height
    dx = Vlong.y + gap;  // column width
    origin = sx * [Dshort/2 + Vlong.y/2 + gap, 0];
    angle = rows==2 ? 90+sign(ny)*90 : -sx*90;
    translate(origin + [nx*dx, ny*dy]) rotate(angle) children();
}
module layout_deck(n, gap=Dgap) {
    layout_tray(n=n, rows=2, gap=Dgap) children();
}

module organizer(tier=undef) {
    // box shape and manuals
    // everything needs to fit inside this!
    %box_frame();
    // main card storage
    for (i=[0:1:7]) {
        color = i < 4 ? "#c0c080" : "#a0a0ff";
        layout_deck(i) rotate(90) deck_box(width=Dlong, color=color);
    }
    // player mats
    translate(-[0, Vmats.x/2 - Vgame.y/2 - Dgap/2]) rotate(-90) {
        mat_frame(Vmats, color=Cnight);
    }
    // starting decks (including heirlooms & shelters)
    if (!tier || 1 < tier) raise_deck(2, deck=0)
        translate([0, Dlong/2 - Vgame.y/2])
            deck_box(width=Dshort, color="#c0c080");
    // base cards
    if (!tier || 1 < tier) raise_deck() {
        layout_tray(0)
            card_tray(height=2*Htray, cards=30, color=Cgold);  // gold
        layout_tray(1)
            card_tray(height=2*Htray, cards=40, color=Csilver);  // silver
        layout_tray(2)
            card_tray(height=2*Htray, cards=32, color=Ccopper);  // copper
        layout_tray(3)
            card_tray(height=2*Htray, cards=30, color=Ccurse);  // curses
        // extra cards for 5+ players
        layout_tray(4)
            card_tray(height=2*Htray, cards=18, color=Cgold);  // gold
        layout_tray(5)
            card_tray(height=2*Htray, cards=30, color=Csilver);  // silver
        layout_tray(6)
            card_tray(height=2*Htray, cards=20, color=Cruins);  // trash
        layout_tray(7)
            card_tray(height=2*Htray, cards=30, color="#ffa000");  // page->champion
        layout_tray(8)
            card_tray(cards=12, color=Csilver);  // platinum
        layout_tray(9)
            card_tray(cards=18, color=Cvictory);  // colony
        layout_tray(10)
            card_tray(cards=13, color=Cruins);  // states
        layout_tray(11)
            card_tray(cards=12, color=Chex);  // hexes
        layout_tray(12)
            player_token_tray(color=player_colors[1]);
        layout_tray(13)
            player_token_tray(color=player_colors[0]);
        layout_tray(14)
            player_token_tray(color=player_colors[5]);
        layout_tray(15)
            card_tray(height=2*Htray, color="#a020ff");  // peasant->teacher
    }
    if (!tier || 1 < tier) raise_deck(1) {
        layout_tray(8)
            card_tray(cards=18, color=Cvictory);  // province
        layout_tray(9)
            card_tray(cards=12, color=Cvictory);  // duchy
        layout_tray(10)
            card_tray(cards=12, color=Cvictory);  // estate
        layout_tray(11)
            card_tray(cards=12, color=Cboon);  // boons
        layout_tray(12)
            player_token_tray(color=player_colors[2]);
        layout_tray(13)
            player_token_tray(color=player_colors[3]);
        layout_tray(14)
            player_token_tray(color=player_colors[4]);
    }
    // these should accommodate all of the Adventures tokens
    translate([0, Vgame.y/2-Vmats.x-Vlongtray.y/2-Dgap]) {
        metal_token_tray(color=Cnight);
        raise_deck(1, 0) metal_token_tray(color=Cnight);
    }
}

*deck_box(width=40, $fa=Qprint);
*deck_box(width=60, $fa=Qprint);
*deck_box(width=Dshort, $fa=Qprint);
*deck_box(width=Dlong, $fa=Qprint);
*mat_frame($fa=Qprint);
*card_tray(height=2*Htray, cards=50, $fa=Qprint);
*card_tray(cards=10, $fa=Qprint);
*draw_tray(height=2*Htray, $fa=Qprint);
*player_token_tray($fa=Qprint);
*metal_token_tray($fa=Qprint);
*tray_foot($fa=Qprint);
*deck_divider($fa=Qprint);
*tray_divider($fa=Qprint);
*creasing_tool(cards=10, $fa=Qprint);
*creasing_tool(cards=12, $fa=Qprint);

*grid_divider(Vomnihive_tray, Homnihive_tray_notch, grid=[3, 2], $fa=Qprint);
*rotate(-90) bookend_divider(Vomnihive-[2,2], Homnihive_rail-2, $fa=Qprint);

*test_game_shapes();
*organizer(tier=1);
organizer();
