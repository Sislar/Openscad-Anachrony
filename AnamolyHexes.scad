$fn=30;

/* [Global] */


// Render
Objects = "Box"; //  [Both, Box, Lid]

// use the following syntax to add 1 or more internal x compartment lengths (mm)
TotalX = 70;

// use the following syntax to add 1 or more internal y compartment widths (mm)
TotalY = 84;

// Total height including Lid
TotalZ = 30;

// Tolerance
gTol = 0.4;
// Wall Thickness
gWT = 1.4;

// rails
LidH = 2.2;
RailThick = 1.4;
RailWidth = LidH + RailThick;
   
// builds slot   47 x 40 x 24
BuildingX = 40;
BuildingY = 47;   
BuildingZ = 40;
CollapseR = 16;   
   
   
// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;

 module regular_polygon(order, r=1){
 	angles=[ for (i = [0:order-1]) i*(360/order) ];
 	coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
 	polygon(coords);
 }



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



module tri_lattice(ipX, ipY, DSize, WSize)  {
    lXOffset = 2*DSize;
//    lYOffset = 2*DSize + WSize;
    lYOffset = (2*DSize + WSize)/cos(30);

	difference()  {
		square([ipX, ipY]);
		for (x=[0:2*lXOffset:ipX]) {
            for (y=[0:lYOffset:ipY]){
  			   translate([x, y]) regular_polygon(3, r=DSize);
			   translate([x+DSize/2, y+lYOffset/2]) rotate([0,0,60]) regular_polygon(3, r=DSize);
  			   translate([x+lXOffset, y+lYOffset/2]) regular_polygon(3, r=DSize);
			   translate([x+DSize/2+lXOffset, y]) rotate([0,0,60]) regular_polygon(3, r=DSize);

		    }
        }        
	}
}


module lid(ipPattern = "Hex", ipTol = 0.3){
  lAdjX = TotalX;
  lAdjY = TotalY-RailWidth*2-ipTol*2;  
  lAdjZ = LidH;
  CutX = lAdjX - 8;
  CutY = lAdjY - 8;
  lFingerX = 15;
  lFingerY = 16;  

  // main square with center removed for a pattern. 0.01 addition is a kludge to avoid a 2d surface remainging when substracting the lid from the box.
  difference() {
      translate([0,0,lAdjZ/2]) cube([lAdjX+0.01, lAdjY+0.01 , lAdjZ], center=true);
      translate([0,0,lAdjZ/2]) cube([CutX, CutY, lAdjZ], center = true);      
  }
  
  // The Side triangles
  intersection () {
      union () {
          translate([-lAdjX/2,-lAdjY/2-LidH,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[LidH,0],[LidH,LidH],[0,LidH]], paths=[[0,1,2]]);
          translate([-lAdjX/2,lAdjY/2,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[0,0],[LidH,0],[LidH,LidH]], paths=[[0,1,2]]);
      }
      if (ipTol>0) 
         {cube([lAdjX, lAdjY + 2*LidH-0.2, lAdjZ*2], center=true);}
  }

  // create the nubs
  if (ipTol > 0) 
  {
  translate([5-lAdjX/2,-lAdjY/2-LidH/2,lAdjZ/2])  hull() {translate([2.5,0,0])sphere(0.4); translate([-2.5,0,0]) sphere(0.4);}
  translate([5-lAdjX/2,lAdjY/2+LidH/2,lAdjZ/2]) hull() {translate([2.5,0,0])sphere(0.4); translate([-2.5,0,0]) sphere(0.4);}
  }
  else
  {
  translate([5-lAdjX/2,-lAdjY/2-LidH/2,lAdjZ/2])  hull() {translate([2.5,0,0])sphere(0.6); translate([-2.5,0,0]) sphere(0.8);}
  translate([5-lAdjX/2,lAdjY/2+LidH/2,lAdjZ/2]) hull() {translate([2.5,0,0])sphere(0.6); translate([-2.5,0,0]) sphere(0.8);}
  }

  // Finger slot
  difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
  }

  // Solid top
  if (ipPattern == "Solid") 
    {
    difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY,   lAdjZ]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
       }
    }

  // Hex top
  if (ipPattern == "Tri") 
    {   
   difference ()
   { 
        translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) tri_lattice(CutX,CutY,4,1.5);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
    }
    }
}


module box () 
{
    
echo (TotalX, TotalY, TotalZ, AdjBoxHeight, RailWidth, LidH);    
  //  Main Box
  difference() 
  {    
    translate ([0,0,AdjBoxHeight/2]) cube([TotalX,TotalY,AdjBoxHeight], center = true);

    // Scope out compartment areas
   translate([-TotalX/2+BuildingX/2+gWT,TotalY/2-BuildingY/2-RailWidth,TotalZ/2+gWT]) cube([BuildingX,BuildingY,TotalZ],center=true);
   translate([-TotalX/2,TotalY/2-BuildingY/2-RailWidth,AdjBoxHeight])rotate([0,90,0])cylinder(r=9, h=6);   

   // Storage for dice or anamolies
//    StoreX = TotalX - 2*CollapseR-2*gWT-1;
//    StoreY = TotalY - BuildingY - 2*RailWidth - gWT;
//    translate([-TotalX/2+gWT+StoreX/2,-TotalY/2+RailWidth+StoreY/2,gWT])RCube(StoreX,StoreY,TotalZ);

    // Two hexes for collapse and non available
    translate([TotalX/2-CollapseR-1,-TotalY/2+CollapseR+RailWidth-1.8,gWT]) linear_extrude(TotalZ) regular_polygon(6,CollapseR);  
    translate([-TotalX/2+CollapseR+1,-TotalY/2+CollapseR+RailWidth-1.8,gWT]) linear_extrude(TotalZ) regular_polygon(6,CollapseR);  
  }

  // top rails
  difference() {
      union() {
          translate([0,-TotalY/2+RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);  
          translate([0,TotalY/2-RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);
           }
       
      // Trim each rail top to a 45 degree angle     
      translate([0,-TotalY/2,AdjBoxHeight+RailWidth]) rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true); 
      translate([0,TotalY/2,AdjBoxHeight+RailWidth])  rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true);  

      // Substract the lid from the rails
      translate([0,0,AdjBoxHeight]) lid(ipPattern = "Solid",ipTol =0);
      
   } // end diff for rails     
}


// Production Box
if ((Objects == "Both") || (Objects == "Box")){
  intersection() {
     box();
     RCube(TotalX,TotalY,TotalZ,1);
  }
}

// Production Lid
if ((Objects == "Both")  || (Objects == "Lid")){
  translate([-TotalX - 10,0,0]) lid(ipPattern = "any", ipTol = gTol);
}


