da6 = 1 / cos(180 / 6) / 2;
da8 = 1 / cos(180 / 8) / 2;

left = -1;
right = 1;
top = 1;
bottom = -1;

thickness = 5.2;
slot_overhead = thickness+3;
min_material_thickness = 3;

use <boxcutter.scad>;

max_book_width = 205;
max_book_thickness = 50;
mount_bracket_height = max_book_thickness-3;
side_support_width = max_book_thickness + thickness + min_material_thickness;
book_support_len = side_support_width*2;
book_support_angle = 45;
num_shelves = 3;


// sides
// main support
// back
// spine?

bed_holes = 209;

belt_holder_screw_spacing = 41;

bearing_spacing_x = 170;
bearing_spacing_y = 70;
bearing_length = 24;
bearing_width_at_depth = 10;
bearing_ziptie_spacing = 20;

space_between = sqrt(2) * side_support_width;

module shelf_support_side() {
  rotate([0,0,90-book_support_angle]) {
    translate([0,max_book_thickness/2,0])
      box_side([max_book_thickness,book_support_len],[0,2,2,0]);

      translate([-slot_overhead/2,-book_support_len/2-slot_overhead*1.5,0])
        cube([max_book_thickness+slot_overhead+thickness,max_book_thickness+slot_overhead+thickness,thickness],center=true);
  }
}

module shelf_support_bottom() {
  box_side([max_book_width,book_support_len],[1,1,0,1]);
}

module shelf_support_back() {
  box_side([max_book_width,max_book_thickness],[0,1,2,1]);
}

module mount_bracket() {
  box_side([max_book_width,mount_bracket_height],[0,2,0,2]);
}

do_mount_bracket = 1;
do_mount_bracket = 0;

module side() {
  backside_x = space_between/2+sqrt(pow(slot_overhead,2))/2;
  difference() {
    union() {
      //for(n=[0]) {
      for(n=[0:num_shelves-1]) {
        translate([0,(space_between-0.05)*-n,0])
          shelf_support_side();
      }
      translate([0,0,0])
        rotate([0,0,-45])
          translate([0,max_book_thickness,0])
            cube([book_support_len,max_book_thickness+2,thickness],center=true);
    }
    translate([0,space_between,0]) cube([book_support_len*2,space_between,30],center=true);
    translate([0,-space_between*num_shelves-sqrt(pow(slot_overhead,2)),0]) cube([book_support_len*2,space_between,30],center=true);

    translate([backside_x+space_between/2,0,0]) {
      cube([space_between,space_between*num_shelves*2,thickness+1],center=true);
    }

    // mount bracket negative
    for(n=[0:num_shelves-1]) {
      if (n == 0 || n == num_shelves-1) {
        if (do_mount_bracket) {
          translate([backside_x,space_between/2+(space_between-0.05)*-n-mount_bracket_height/2+0.05,0]) {
            cube([30*2-0.05,mount_bracket_height,thickness+1],center=true);
          }
        } else {
          translate([backside_x-thickness,space_between/2+(space_between-0.05)*-n-mount_bracket_height/2+0.05,0]) {
            for(y=[-1,1]) {
              translate([0,mount_bracket_height*.25*y,0])
                cylinder(r=3/2,h=thickness+1,center=true,$fn=16);
            }
          }
        }
      }
    }
  }

  if (do_mount_bracket) {
    for(n=[0:num_shelves-1]) {
      if (n == 0 || n == num_shelves-1) {
        translate([backside_x-30/2-thickness/2,space_between/2+(space_between-0.05)*-n-mount_bracket_height/2+0.05,0])
          box_side([30-thickness,mount_bracket_height],[0,0,0,1]);
      }
    }
  }
}

module headboard_hook() {
  headboard_thickness = 30;
  mount_hole_spacing = mount_bracket_height*.25*2;
  echo("HOLE SPACING: ", mount_hole_spacing);

  hook_thickness = min_material_thickness*3;
  height = mount_hole_spacing + thickness*2;
  depth = thickness*2 + headboard_thickness + hook_thickness;

  rounded_diam = 3;

  difference() {
    translate([0,-height/2,0])
      cube([depth,height*2,thickness],center=true);

    for(y=[-1,1]) {
      translate([-depth/2+thickness,mount_hole_spacing/2*y,0]) {
        cylinder(r=3/2,h=thickness+1,center=true,$fn=16);
      }
    }

    translate([depth/2-hook_thickness-headboard_thickness/2,-height*1.5,0]) {
      hull() {
        translate([headboard_thickness/2-rounded_diam/2,height-rounded_diam/2,0]) {
          cylinder(r=rounded_diam*da8,h=thickness+1,center=true,$fn=16);

          translate([0,-height,0]) {
            cube([rounded_diam,rounded_diam,thickness+1],center=true);

            translate([-depth,0,0])
              cube([rounded_diam,rounded_diam,thickness+1],center=true);
          }
        }

        translate([-depth,height-rounded_diam/2,0]) cube([rounded_diam,rounded_diam,thickness+1],center=true);
      }
    }
  }

  /*
  translate([-depth/2+thickness*2+headboard_thickness+hook_thickness/2,-height/2,0]) {
    cube([hook_thickness,height*2,thickness],center=true);
  }
  */
}

module assembly() {
  for (side=[left,right]) {
    translate([(max_book_width/2+thickness/2)*side,0,0])
      rotate([0,0,90]) rotate([90,0,0])
        side();
  }

  translate([0,-150,0]) rotate([-45,0,0])
    shelf_support_bottom();

  translate([0,75,0]) rotate([45,0,0])
    shelf_support_back();
}

module plate() {
  // TODO: make parametric
  /*
  for(side=[left,right]) {
    translate([67.5*-side,62.5*side,0])
      rotate([0,0,90*side])
        side();
  }
  */

  translate([0,70,0])
    rotate([0,0,90])
      translate([5,67.5,0])
        side();

  translate([44,-50,0])
    rotate([0,0,90])
      translate([0,70,0])
        rotate([0,180,0])
          side();

  translate([-max_book_width/2,-book_support_len/2,0])
    headboard_hook();

  translate([-max_book_width/2-slot_overhead,-book_support_len*1.5,0])
    shelf_support_bottom();

  translate([max_book_width/2+slot_overhead,-book_support_len*1.2,0])
    shelf_support_back();

  if (do_mount_bracket) {
    translate([max_book_width/2+slot_overhead,-book_support_len*2+mount_bracket_height/2,0])
      mount_bracket();
  }
}

module kerf_plate() {
  minkowski() {
    plate();
    cube([.04,.04,0.0001],center=true);
  }
}

//kerf_plate();
//assembly();
plate();
//headboard_hook();

/*
translate([-max_book_width-slot_overhead-thickness/2,-book_support_len*1-book_support_len,0]) {
  % translate([0,0,0]) cube([1,1,200],center=true);
  % translate([133,325,0]) cube([1,1,200],center=true);
  % translate([109,302,0]) cube([1,1,200],center=true);
}
*/
