$fn = 30;

floor = 6;
walls = 1.8;

MiniSlotSize = 43;
XRows = 5;
YRows = 3;

TotalX = MiniSlotSize * XRows + walls;
TotalY = MiniSlotSize * YRows + walls; 
TotalZ = 64;

ConnType = "Male";
//ConnType = "Female";

echo("Dimensions: ", TotalX,TotalY,TotalZ);

module RCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y-ipR,ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,ipR]) sphere(ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y-ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,z-ipR]) sphere(ipR);
      }  
} 

module HalfRCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y,ipR]) rotate([90,0,0])cylinder(h=ipR,r=ipR);
      translate([x-ipR,y,ipR]) rotate([90,0,0])cylinder(h=ipR,r=ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y,z-ipR]) rotate([90,0,0])cylinder(h=ipR,r=ipR);
      translate([x-ipR,y,z-ipR]) rotate([90,0,0])cylinder(h=ipR,r=ipR);
      }  
}

module regular_polygon(order, r){
     angles=[ for (i = [0:order-1]) i*(360/order) ];
     coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
     polygon(coords);
 }

module pinhole(h=10, r=4, lh=3, lt=1, t=0.3, tight=true) {
  // h = shaft height
  // r = shaft radius
  // lh = lip height
  // lt = lip thickness
  // t = tolerance
  // tight = set to false if you want a joint that spins easily
  
  union() {
    pin_solid(h, r+(t/2), lh, lt);
    cylinder(h=h+0.2, r=r);
    // widen the cylinder slightly
    // cylinder(h=h+0.2, r=r+(t-0.2/2));
    if (tight == false) {
      cylinder(h=h+0.2, r=r+(t/2)+0.25);
    }
    // widen the entrance hole to make insertion easier
    translate([0, 0, -0.1]) cylinder(h=lh/3, r2=r, r1=r+(t/2)+(lt/2));
  }
}


// this is mainly to make the pinhole module easier
module pin_solid(h=10, r=4, lh=3, lt=1) {
  union() {
    // shaft
    cylinder(h=h-lh, r=r, $fn=30);
    translate([0, 0, h-lh]) cylinder(h=lh*0.25, r1=r, r2=r+(lt/2), $fn=30);
    translate([0, 0, h-lh+lh*0.25]) cylinder(h=lh*0.25, r=r+(lt/2), $fn=30);    
    translate([0, 0, h-lh+lh*0.50]) cylinder(h=lh*0.50, r1=r+(lt/2), r2=r-(lt/2), $fn=30);    
  }
}


module pin(h=10, r=4, lh=3, lt=1) {
  // h = shaft height
  // r = shaft radius
  // lh = lip height
  // lt = lip thickness

  difference() {
    pin_solid(h, r, lh, lt);
    
    // center cut
    translate([-r*0.5/2, -(r*2+lt*2)/2, h/4]) cube([r*0.5, r*2+lt*2, h]);
    translate([0, 0, h/4]) cylinder(h=h+lh, r=r/2.5, $fn=20);
    // center curve
    // translate([0, 0, h/4]) rotate([90, 0, 0]) cylinder(h=r*2, r=r*0.5/2, center=true, $fn=20);
  
    // side cuts
    translate([-r*2, -lt-r*1.125, -1]) cube([r*4, lt*2, h+2]);
    translate([-r*2, -lt+r*1.125, -1]) cube([r*4, lt*2, h+2]);
  }
}

module minislot() {
    translate([0,0,walls]) linear_extrude(floor+1) rotate ([0,0,30])regular_polygon(6, 20.5);
    cylinder(r=12,h=10);
}

module base(){
  difference(){
    
    HalfRCube(TotalX,TotalY,TotalZ,1);
      
    // scope out each row  
    for (x = [0: XRows-1])      
       translate([MiniSlotSize*(x-2),walls,floor+walls]) RCube(MiniSlotSize-walls,TotalY,TotalZ,2);

    // Create the Hex base for the minis
    for (x = [0: XRows-1])
        for(y = [0:YRows-1])
            translate([MiniSlotSize*(x-2),MiniSlotSize*(y-1)+walls/2,0]) minislot();

    // Remove material from y walls
    for (x = [0: XRows-1])      
      translate([MiniSlotSize*(x-2),0,TotalZ/2+4]) scale([1,1,1.4]) rotate([90,0,0])cylinder(r=(MiniSlotSize/2)*0.6,h=TotalY+10);

    // Remove material from x walls
    for (y = [0: YRows-1])      
      translate([-TotalX/2,MiniSlotSize*(y-1),TotalZ/2+4]) scale([1,1,1.4]) rotate([0,90,0])cylinder(r=(MiniSlotSize/2)*0.6,h=TotalX+20);

    if(ConnType == "Female")
    {
      //  Hole or pin under each inner wall
      for (x = [0: XRows-2])      
        translate([MiniSlotSize*(x-1.5),TotalY/2,4])rotate([90,0,0]) pinhole(h=5, r=2.8, lh=3, lt=1, t=0.4, tight=true);

      //  Hole by each outer wall
      translate([TotalX/2-5,TotalY/2,4])rotate([90,0,0]) pinhole(h=5, r=2.8, lh=3, lt=1, t=0.4, tight=true);
      translate([-TotalX/2+5,TotalY/2,4])rotate([90,0,0]) pinhole(h=5, r=2.8, lh=3, lt=1, t=0.4, tight=true);
    }
   } // end difference
   
   if(ConnType == "Male")
    {
      //  Hole or pin under each inner wall
      for (x = [0: XRows-2])      
        translate([MiniSlotSize*(x-1.5),TotalY/2,4])rotate([-90,0,0]) pin(h=5, r=2.8, lh=3, lt=1);

      //  Hole by each outer wall
      translate([TotalX/2-5,TotalY/2,4])rotate([-90,0,0]) pin(h=5, r=2.8, lh=3, lt=1);
      translate([-TotalX/2+5,TotalY/2,4])rotate([-90,0,0]) pin(h=5, r=2.8, lh=3, lt=1);
    
        // Add connectors to each inner wall
//        for (x = [0: XRows-2]) 
//        {
 //           translate([MiniSlotSize*(x-1.5)-walls/2,TotalY/2,TotalZ-11]) rotate([0,-90,0]) linear_extrude(1,scale=0.8) regular_polygon(order=4,r=7);
//            translate([MiniSlotSize*(x-1.5)+walls/2,TotalY/2,TotalZ-11]) rotate([0,90,0]) linear_extrude(1,scale=0.8) regular_polygon(order=4,r=7);
  //      }
    }
}


base();

