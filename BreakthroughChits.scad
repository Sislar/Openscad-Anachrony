// Width of a single card
CardWidth = 32;    

// Height of a single card
CardHeight = 30;  

// Box Height
TotalZ = 30; 

// Size of each Card slot
//Slots = [10,10];
Slots = [10,10,10];

// Number of rows of cards
Rows = 5;

// Slant the front of the box 
SlantFront = true;

// Size of botton cutout, % of width
AccessDepth = 0.4;

// Wall Thickness
gWT = 1.6;

// Roundness
$fn = 30;

AddonX = 32;


function SumList(list, start, end) = (start == end) ? list[start] : list[start] + SumList(list, start+1, end);




Angle = (((TotalZ-gWT)/CardHeight) < 1) ? acos((TotalZ-gWT)/CardHeight) : 0;
  
//Wall space for tilted wall
gWS =  gWT / cos(Angle);
BoxWidth = CardWidth + 2*gWT;

SlotsAdj = [for (i = [0:len(Slots)-1]) Slots[i]/cos(Angle)];
ExtraLength = CardHeight * sin(Angle);
BoxLength = SumList(SlotsAdj,0,len(SlotsAdj)-1) + ExtraLength + (len(Slots)-1) * gWS+ 2*gWT;
RailPlace = [for (i = [0:len(Slots)-1]) gWT-BoxLength/2+SumList(SlotsAdj,0,i)+gWS*i ];

TotalY = BoxWidth*Rows-gWT*(Rows-1);
TotalX = BoxLength;

// final diminsions 
echo(TotalX,TotalY, Angle);

module regular_polygon(order, r){
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


//  Main Box
module Box() {
   intersection() 
   {
     RCube(BoxLength,BoxWidth,TotalZ, 1);  
     difference() 
     {  
        union() 
        { 
           difference() 
           {    
              RCube(BoxLength,BoxWidth,TotalZ, 1);
                   
              // Hallow out the box  
              translate([gWT/2,0,TotalZ/2+gWT]) cube([BoxLength-gWT,BoxWidth-2*gWT,TotalZ], center=true);
                   
           }  // shell of box
              
           // add the dividers  
           for(x=[0:len(Slots)-1]) {  
              translate([RailPlace[x]-0.2,0,gWT-CardHeight/2])  translate([1,0,CardHeight/2]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, CardWidth, CardHeight],center=true);
           }
               
           // Add new front if configured
           if (SlantFront)
           {
               translate([-BoxLength/2,0,gWT]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, CardWidth, CardHeight],center=true);        
           } 
        } // End the union after here is substraction
              
        // create gap at top to access the cards
        AccessWidth = CardWidth * 0.4;
        hull(){
            translate([0,-AccessWidth/2+3,TotalZ+10]) rotate([0,90,0])cylinder(r=3,h=BoxLength,center=true);;
            translate([0,AccessWidth/2-3,TotalZ+10]) rotate([0,90,0])cylinder(r=3,h=BoxLength,center=true);;
            translate([0,-AccessWidth/2+3,TotalZ*(1-AccessDepth)])rotate([0,90,0])cylinder(r=3,h=BoxLength,center=true);;
            translate([0,AccessWidth/2-3,TotalZ*(1-AccessDepth)])rotate([0,90,0])cylinder(r=3,h=BoxLength,center=true);;
        } // hull
         
            translate([0,-AccessWidth/2-6,TotalZ-6])difference(){
               cube([BoxLength,12,12], center = true);
               rotate([0,90,0])cylinder(r=7,h=BoxLength,center=true);
                translate([0,-6,0])cube([BoxLength,12,12], center = true);
                translate([0,0,-6])cube([BoxLength,12,12], center = true);
            }
           translate([0,+AccessWidth/2+6,TotalZ-6]) difference(){
               cube([BoxLength,12,12], center = true);
               rotate([0,90,0])cylinder(r=7,h=BoxLength,center=true);
                translate([0,6,0])cube([BoxLength,12,12], center = true);
                translate([0,0,-6])cube([BoxLength,12,12], center = true);
            }
                      
        // If we have the slanted front remove part of the box
        if (SlantFront)
        {
           hull() { 
             translate([-BoxLength/2-200,0,gWT]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, CardWidth+10, CardHeight+2*gWT],center=true);
             translate([-BoxLength/2-2,0,gWT]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, CardWidth+10, CardHeight+2*gWT],center=true);
              }
        } // end slant
      } // end diff
   }  // Instersection
}
  
// rails
LidH = 2.2;
RailThick = 1.4;
RailWidth = LidH + RailThick;
// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;

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
module lid(ipX, ipY, ipPattern = "Hex", ipTol = 0.3){
//  lAdjX = TotalX;
//  lAdjY = TotalY-RailWidth*2-ipTol*2;  
//  lAdjZ = LidH;
  CutX = ipX - 8;
  CutY = ipY - 8;
  lFingerX = 15;
  lFingerY = 16;  

  // main square with center removed for a pattern. 0.01 addition is a kludge to avoid a 2d surface remainging when substracting the lid from the box.
  difference() {
      translate([0,0,LidH/2]) cube([ipX+0.01, ipY+0.01 , LidH], center=true);
      translate([0,0,LidH/2]) cube([CutX, CutY, LidH], center = true);      
  }
  
  // The Side triangles
  intersection () {
      union () {
          translate([-ipX/2,-ipY/2-LidH,LidH]) rotate([0,90,0]) linear_extrude(ipX-2) polygon([[LidH,0],[LidH,LidH],[0,LidH]], paths=[[0,1,2]]);
          translate([-ipX/2,ipY/2,LidH]) rotate([0,90,0]) linear_extrude(ipX-2) polygon([[0,0],[LidH,0],[LidH,LidH]], paths=[[0,1,2]]);
      }
      if (ipTol>0) 
         {cube([ipX, ipY + 2*LidH-0.2, LidH*2], center=true);}
  }

  // create the nubs
  if (ipTol > 0) 
  {
  translate([5-ipX/2,-ipY/2-LidH/2,LidH/2])  hull() {translate([2.5,0,0])sphere(0.4); translate([-2.5,0,0]) sphere(0.4);}
  translate([5-ipX/2,ipY/2+LidH/2,LidH/2]) hull() {translate([2.5,0,0])sphere(0.4); translate([-2.5,0,0]) sphere(0.4);}
  }
  else
  {
  translate([5-ipX/2,-ipY/2-LidH/2,LidH/2])  hull() {translate([2.5,0,0])sphere(0.6); translate([-2.5,0,0]) sphere(0.8);}
  translate([5-ipX/2,ipY/2+LidH/2,LidH/2]) hull() {translate([2.5,0,0])sphere(0.6); translate([-2.5,0,0]) sphere(0.8);}
  }

  // Finger slot
  difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, LidH]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
  }

  // Solid top
  if (ipPattern == "Solid") 
    {
    difference () {
        translate([-CutX/2,-CutY/2,0]) cube([CutX,CutY,LidH]);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, LidH]); 
       }
    }

  // Triangle top
  if (ipPattern == "Tri") 
    {   
   difference ()
   { 
        translate([-CutX/2,-CutY/2,0]) linear_extrude(height = LidH) tri_lattice(CutX,CutY,4,1.5);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, LidH]); 
    }
    }
}


module addon()
{
    
  difference()
  {   
     rotate([0,0,90]) HalfRCube(TotalY,AddonX,TotalZ,1);
      
     PocketY =  TotalY/2-RailWidth-gWT/2;
      
     // create two pockets 
     translate([0,(PocketY+gWT)/2,gWT])RCube(AddonX-2*gWT,PocketY, TotalZ);
     translate([0,-(PocketY+gWT)/2,gWT])RCube(AddonX-2*gWT,PocketY, TotalZ);

    translate([0,0,AdjBoxHeight+LidH/2])cube([TotalX, TotalY-RailWidth*2,LidH], center=true);

     // Substract the lid from the rails
    rotate([0,0,180])translate([0,0,AdjBoxHeight]) lid(AddonX, TotalY-RailWidth*2, ipPattern = "Solid",ipTol =0);


    // Two hexes for collapse and non available
//    translate([0,TotalY/2-16,gWT])linear_extrude (TotalZ) regular_polygon(6,16);;   
  }    
}


difference() 
{
union() for(i=[0:Rows-1]) { translate([0,(i-2) * (BoxWidth-gWT),0]) Box(); }

     // Substract the lid from the rails
    translate([38.8,0,0]) rotate([0,0,180])translate([0,0,AdjBoxHeight]) lid(AddonX, TotalY-RailWidth*2, ipPattern = "Solid",ipTol =0);

}

translate([38.8,0,0]) addon();

//translate([80,0,0]) rotate([0,0,180]) lid(AddonX, TotalY-RailWidth*2, ipPattern = "Tri",ipTol =0.4);


