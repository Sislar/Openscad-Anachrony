$fn = 30;

gWT = 1.4;
gTol = 0.3;

// rails
LidH = 2.2;
RailThick = 1.4;
RailWidth = LidH + RailThick;

SuitX = 101.5;
SuitY = 70;

FirstPX = 78.6;
FirstPY = 45.6;

BoardThick1 = 1.9;
BoardThick2 = 2.9;  // Board + leader cards


TotalX = SuitX + 2*gWT + 2*gTol;
TotalY = SuitY + 2*RailWidth + 2*gTol;
TotalZ = 20;

Objects = "Lid";

// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;
gPattern = "Dominance";  //  Salvation, Dominance, Harmony, Progress, Unity

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
  translate([5-lAdjX/2,-lAdjY/2-LidH/2,lAdjZ/2])  hull() {translate([2.5,0,0])sphere(0.4); translate([-2.5,0,0]) sphere(0.6);}
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
   difference ()
   { 
        translate([0,0,lAdjZ/2]) cube([CutX,CutY,lAdjZ], center=true);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]);
        if (ipPattern == "Harmony")
           translate([-TotalX/4-13,TotalY/2-6,lAdjZ-1])linear_extrude(2) rotate([0,0,-90]) scale([0.11,0.11]) import("Harmony.dxf");
        if (ipPattern == "Dominance")
           translate([-TotalX/4-3,TotalY/2-3,lAdjZ-1])linear_extrude(2) rotate([0,0,-90]) scale([0.1,0.1]) import("Dominance.dxf");
        if (ipPattern == "Salvation")
           translate([-TotalX/4-5,TotalY/2-10,lAdjZ-1])linear_extrude(2) rotate([0,0,-90]) scale([0.1,0.1]) import("Salvation.dxf");
        if (ipPattern == "Progress")
           translate([-TotalX/4-5,TotalY/2-13,lAdjZ-1])linear_extrude(2) rotate([0,0,-90]) scale([0.1,0.1]) import("Progress.dxf");
        if (ipPattern == "Unity")
           translate([-TotalX/4-10,TotalY/2-2,lAdjZ-1])linear_extrude(2) rotate([0,0,-90]) scale([0.13,0.13]) import("Unity.dxf");
        
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
      
    // Slot for the Suit tile + Leader Call(use an extra gTOl for leader thickness
    translate([0,0,AdjBoxHeight-(BoardThick2+gTol)/2]) cube([SuitX+2*gTol,SuitY+2*gTol,BoardThick2 + gTol],center=true);         
      
    // Slot for First player marker  
    translate([0,0,AdjBoxHeight-(BoardThick1+gTol)/2-BoardThick2-gTol]) cube([FirstPX+2*gTol,FirstPY+2*gTol,BoardThick1 + gTol ],center=true);        
    StoreX = (SuitX - 6 - gWT) / 2;  
    StoreY = (SuitY - 6 - gWT) / 2;
      
    // 4 compartments  move one wall over 5 mm  
    translate([(StoreX+gWT)/2,(StoreY+gWT)/2,gWT]) RCube(StoreX,StoreY,TotalZ); 
    translate([-(StoreX+gWT)/2,(StoreY+gWT)/2,gWT]) RCube(StoreX,StoreY,TotalZ); 
    translate([(StoreX+gWT)/2-2.5,-(StoreY+gWT)/2,gWT]) RCube(StoreX+5,StoreY,TotalZ); 
    translate([-(StoreX+gWT)/2-2.5,-(StoreY+gWT)/2,gWT]) RCube(StoreX-5,StoreY,TotalZ); 
      
    translate([-TotalX/2,0,AdjBoxHeight-7])scale([1,1,1])cylinder(r=5,h=7);  
      
    //////////////////////  
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
  translate([-TotalX - 10,0,0]) lid(ipPattern = gPattern, ipTol = gTol);
}




