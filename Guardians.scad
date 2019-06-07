$fn = 30;

floor = 8;
gWT = 1.4;

MiniX = 35.3;
MiniY = 40.5;
XRows = 3;
YRows = 2;

TotalX = 105+2*gWT;
TotalY = 81+2*gWT; 
TotalZ = 64;

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


module regular_polygon(order, r){
     angles=[ for (i = [0:order-1]) i*(360/order) ];
     coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
     polygon(coords);
 }


module minislot() {
    translate([0,0,gWT]) linear_extrude(floor+1) rotate ([0,0,30])regular_polygon(6, MiniY/2);
    cylinder(r=12,h=10);
}

module base(){
  difference(){
    
    RCube(TotalX,TotalY,TotalZ,1);

    // Remove the inside
    translate([0,0,floor])RCube(TotalX-2*gWT,TotalY-2*gWT,TotalZ,1);

    // Create the Hex base for the minis
    for (x = [0: XRows-1])
        for(y = [0:YRows-1])
            translate([MiniX*(x-1),MiniY*(y-0.5),0]) minislot();

    translate([0,MiniY/2,gWT+5])cube([TotalX-MiniX,MiniY/2,10],center=true);
    translate([0,-MiniY/2,gWT+5])cube([TotalX-MiniX,MiniY/2,10],center=true);

    // Remove material from y walls
    for (x = [0: XRows-1])      
      translate([MiniX*(x-1),TotalY/2+5,TotalZ/2+4]) scale([1,1,1.4]) rotate([90,0,0]) cylinder(r=(MiniX/2)*0.6,h=TotalY+10);

    // Remove material from x walls
    for (x = [0: YRows-1])      
      translate([-TotalX/2-5,MiniY*(x-0.5),TotalZ/2+4]) scale([1,1,1.4]) rotate([0,90,0]) cylinder(r=(MiniX/2)*0.6,h=TotalX+10);

 
   } // end difference
   
}

//intersection(){
base();
//translate([-MiniX/2,0,0])cube([100,MiniY+2*gWT,8]);
//}
