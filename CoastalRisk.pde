/* @pjs preload="Mapa_base_small.gif; */
/* @pjs font="f1, f2, f3"; */

//  This Processing sketch visualizes the coastal exposure to oil spills (accidental
//  or illegal discharge) coming from the Finisterre Traffic Separation Scheme off
//  Cape Finisterre (Spain), where more than 40,000 ships navigate thorough the year.
//
//  Data are based on an operational configuration of the ROMS model (1 km spatial resolution)
//  and wind from the WRF model (12 km spatial resolution) plus other physical approaches that
//  were taken into account for running a 2D lagrangian model. Data correspond to 2012.
//
//  Pablo Otero, June 2013.
//  otero_pablo@hotmail.com

PFont f, f2, f3;
ADRadio radioButton;

String[] options = {"Annual","Weekly"};
toolbar tools;

String[] lines, lines2, lines3; 

float[] time = new float[366];

int[] partida = new int[144];
int[] llegada = new int[144];
int[] dia = new int[144];
float[] prob = new float[144];

float[] windtime = new float[366];
float[] u = new float[366];
float[] v = new float[366];
float[] miu = new float[7];
float[] miv = new float[7];
int semana = 0;
float a1 = 1;

int[] wtime = new int[7632];
int[] wpartida = new int[7632];
int[] wllegada = new int[7632];
int[] wdia = new int[7632];
float[] wprob = new float[7632];  

float[] xpos_partida = { -10.19, -10.10, -9.95, -9.79, -9.6, -10.0 }; 
float[] ypos_partida = { 43.27, 43.20, 43.13, 43.04, 43.75, 42.5 };

float[] xpos_llegada = { -8.14, -8.57, -9.17, -9.11, -8.87, -8.8 }; 
float[] ypos_llegada = { 43.65, 43.31, 43.17, 42.72, 42.24, 41.5 };


// Base map and its limits
PImage b;
float minlon = -10.4;
float maxlon = -7.74;
float minlat = 41.0;
float maxlat = 44.1;

color darkblue = #6F85AD;
color aqua = #66C1A4;
color salmon = #F78C65;
color sky = #8C9FCA;
color pink = #E888C2;
color apple = #A6D951;
color banana = #FFD82F;
color colorfondo = #45A9BC;

int[] paleta = {aqua, salmon, sky, pink, apple, banana}; 

float factorcircle = 50;

float tic;
float[][] a_old = new float[6][6];
int[][]   index_old = new int[6][6];

float[][] por_accum = new float[6][4];

int corridor_selected = 0;

 //Create a PVector for each corridor
 PVector[] corridor1=new PVector[6];
 PVector[] corridor2=new PVector[6];
 PVector[] corridor3=new PVector[6];
 PVector[] corridor4=new PVector[6];
 PVector[] corridor5=new PVector[4];
 PVector[] corridor6=new PVector[4];

boolean looped=true;

windRose mirosa;

void setup() {
  size(600,600);
  
  f = createFont("ArialMT", 16);
  f2 = createFont("Arial-Black", 16);
  f3 = createFont("Borealis", 16);
  
  b = loadImage("Mapa_base_small.gif");
 
  //Add radio button
  radioButton = new ADRadio(width-100, 100, options, "radioButton");
  radioButton.setDebugOn();
  radioButton.setBoxFillColor(0); 
  radioButton.setValue(0);

  
  //Initialize variables a_old and index_old to zero
  for (int index = 0; index < 6; index++) { 
    for (int index2 = 0; index2 < 6; index2++) {
      a_old[index][index2] = 0.0;
      index_old[index][index2] = 0;
    }
  }  
  
  //Initialize variables miu and miv to zero
  for (int index = 0; index < 7; index++) {
      miu[index] = 0.0;
      miv[index] = 0.0;
  }
   
  //Load the annual data file and fill variables
  lines = loadStrings("annual_processing.txt"); 
  for (int index = 0; index < lines.length; index = index + 1) { 
     String[] annualdata = split(lines[index], '\t');
     if (annualdata.length == 4) {
       partida[index] = int(annualdata[0]);
       llegada[index] = int(annualdata[1]);
       dia[index] = int(annualdata[2]);
       prob[index] = float(annualdata[3]);
     }
  }
 
  //Load the weekly data file and fill variables
  lines2 = loadStrings("weekly_processing.txt"); 
  for (int index = 0; index < lines2.length; index = index + 1) { 
     String[] weeklydata = split(lines2[index], '\t');
     if (weeklydata.length == 5) {
       wtime[index] = int(weeklydata[0]);
       wpartida[index] = int(weeklydata[1]);
       wllegada[index] = int(weeklydata[2]);
       wdia[index] = int(weeklydata[3]);
       wprob[index] = float(weeklydata[4]);
     }
  }
 
   //Load the weekly data file and fill variables
  lines3 = loadStrings("vientos2012.txt"); 
  for (int index = 0; index < lines3.length; index = index + 1) { 
     String[] vientosdata = split(lines3[index], '\t');
     if (vientosdata.length == 3) {
       windtime[index] = int(vientosdata[0]);
       u[index] = float(vientosdata[1]);
       v[index] = float(vientosdata[2]);
     }
  }
  
  
 // add corner points of quad
 corridor1[0]=new PVector(-10.2292,42.8777); corridor1[1]=new PVector(-10.2292,43.31293); corridor1[2]=new PVector(-10.08779,43.52230); corridor1[3]=new PVector(-10.02875,43.49651); corridor1[4]=new PVector(-10.1661,43.29429); corridor1[5]=new PVector(-10.1661,42.8777);
 corridor2[0]=new PVector(-10.1386,42.8777); corridor2[1]=new PVector(-10.1386,43.28894); corridor2[2]=new PVector(-10.00128,43.49153); corridor2[3]=new PVector(-9.93261,43.46861); corridor2[4]=new PVector(-10.07131,43.27395); corridor2[5]=new PVector(-10.07131,42.8777);
 corridor3[0]=new PVector(-9.98480,42.8777); corridor3[1]=new PVector(-9.98480,43.24394); corridor3[2]=new PVector(-9.85021,43.43471); corridor3[3]=new PVector(-9.78155,43.41277); corridor3[4]=new PVector(-9.91339,43.22593); corridor3[5]=new PVector(-9.91339,42.8777);
 corridor4[0]=new PVector(-9.82550,42.8777); corridor4[1]=new PVector(-9.82550,43.20291); corridor4[2]=new PVector(-9.70053,43.38084); corridor4[3]=new PVector(-9.62991,43.35788); corridor4[4]=new PVector(-9.75134,43.18289); corridor4[5]=new PVector(-9.75134,42.8777);
 corridor5[0]=new PVector(-10.07818,43.52240); corridor5[1]=new PVector(-9.72,44.0); corridor5[2]=new PVector(-9.13,44.0); corridor5[3]=new PVector(-9.62991,43.35788); 
 corridor6[0]=new PVector(-10.2292,42.0); corridor6[1]=new PVector(-10.2292,42.8777); corridor6[2]=new PVector(-9.75134,42.8777); corridor6[3]=new PVector(-9.75134,42.0); 
 
 // convert from lon/lat to screen location
 for (int index = 0; index < 6; index = index + 1) {
    corridor1[index].x = (int)(floor(map(corridor1[index].x,minlon, maxlon, 0, 377))); corridor1[index].y = (int)(600-floor(map(corridor1[index].y,minlat, maxlat, 0, 600)));
    corridor2[index].x = floor(map(corridor2[index].x,minlon, maxlon, 0, 377)); corridor2[index].y = 600-floor(map(corridor2[index].y,minlat, maxlat, 0, 600));
    corridor3[index].x = floor(map(corridor3[index].x,minlon, maxlon, 0, 377)); corridor3[index].y = 600-floor(map(corridor3[index].y,minlat, maxlat, 0, 600));
    corridor4[index].x = floor(map(corridor4[index].x,minlon, maxlon, 0, 377)); corridor4[index].y = 600-floor(map(corridor4[index].y,minlat, maxlat, 0, 600)); 
   if (index < 4) {
    corridor5[index].x = floor(map(corridor5[index].x,minlon, maxlon, 0, 377)); corridor5[index].y = 600-floor(map(corridor5[index].y,minlat, maxlat, 0, 600));
    corridor6[index].x = floor(map(corridor6[index].x,minlon, maxlon, 0, 377)); corridor6[index].y = 600-floor(map(corridor6[index].y,minlat, maxlat, 0, 600));  
   }  
 }
 
 color gray1 = #2E4F55;
 color gray2 = darken(gray1);
 color gray3 = darken(gray2);
 float[] pos = {
    width-210, 290, width-20, 40
  };
 tools = new toolbar(pos, 2);
 tools.addSlider("Week", "left", gray2, gray3, 1, 52);
  ((slider) tools.lastAdded()).setVal(1);

     
}
  
void draw() {
   
  smooth();
  background(255);
  textFont(f,16);
  
  //Load image 600x377
  image(b, 0, 0);
  
  //Options
  radioButton.update();
  
   
  // check if mouse pos is inside
  beginShape();
  
  if(containsPoint(corridor1,mouseX,mouseY)) {
    fill(darken(paleta[0]),200);
    //// COMO ESTABA ANTES
    //for(PVector v : corridor1) {
    // stroke(paleta[0]);
    // vertex(v.x,v.y);
    // corridor_selected=1;
    //}
    for(int index=0; index<corridor1.length; index++) {
     stroke(paleta[0]);
     vertex(corridor1[index].x,corridor1[index].y);
     corridor_selected=1;
    }
  } else if (containsPoint(corridor2,mouseX,mouseY)) {
    fill(darken(paleta[1]),200);
    for(int index=0; index<corridor2.length; index++) {
     stroke(paleta[1]);
     vertex(corridor2[index].x,corridor2[index].y);
     corridor_selected=2;
    }    
  } else if (containsPoint(corridor3,mouseX,mouseY)) {
    fill(darken(paleta[2]),200);
    for(int index=0; index<corridor3.length; index++) {
     stroke(paleta[2]);
     vertex(corridor3[index].x,corridor3[index].y);
     corridor_selected=3;
    } 
  } else if (containsPoint(corridor4,mouseX,mouseY)) {
    fill(darken(paleta[3]),200);
    for(int index=0; index<corridor4.length; index++) {
     stroke(paleta[3]);
     vertex(corridor4[index].x,corridor4[index].y);
     corridor_selected=4;
    } 
  } else if (containsPoint(corridor5,mouseX,mouseY)) {
    fill(darken(paleta[4]),200);
    for(int index=0; index<corridor5.length; index++) {
     stroke(paleta[4]);
     vertex(corridor5[index].x,corridor5[index].y);
     corridor_selected=5;
    } 
  } else if (containsPoint(corridor6,mouseX,mouseY)) {
    fill(darken(paleta[5]),200);
    for(int index=0; index<corridor6.length; index++) {
     stroke(paleta[5]);
     vertex(corridor6[index].x,corridor6[index].y);
     corridor_selected=6;
    } 
  } else {
    noFill();
    corridor_selected=0;
  }
  
  endShape(CLOSE);
  
    annotate();
  
  if(radioButton.getValue() == 0) {
   drawannual();
  } else if (radioButton.getValue() == 1) {
     textFont(f,11);
     tools.update();
     a1 = ((slider) tools.find("Week")).getVal();
     drawweekly();  
  }        
  

  
} 


void drawweekly() {
  int[] centrorosa = {490,220};

  int diacomienzo=((floor(a1)-1)*7)+2455928;

  for(int index=0; index<windtime.length; index++) {
    for(int index2=0; index2<7; index2++) {
      if( windtime[index]==(index2+diacomienzo) ) {
        miu[index2] = u[index];
        miv[index2] = v[index];
      }
      if( windtime[index]==(index2+diacomienzo+7) ) {
        break;
      } 
    }  
  }   
  
  mirosa = new windRose(miu,miv,centrorosa,150,4);
  mirosa.drawRose();
  
 //We sum "1" to deal with some indexes
 float[] a = new float[6];
 float[] a2 = new float[6];
 int count = 0;
 float x0, y0;
 int heightbar = 80;
 
 int index_corridor = corridor_selected-1;
 
 //Initialize variables por_accum
  for (int index = 0; index < 6; index++) { 
    for (int index2 = 0; index2 < 4; index2++) {
      por_accum[index][index2] = 0.0;
    }
  } 
 
 float timelapse = 8000;
 float tic2 = millis()%timelapse; 
 tic2=tic2/timelapse*4;
 float dt = tic2-floor(tic2);
 if(tic2<1) {
   count = 0; textFont(f,18); fill(54,54,54); text(" 0 - 24 h",180,50);
 } else if (tic2>=1 && tic2<2) {
   count = 1; textFont(f,18); fill(54,54,54); text("24 - 48 h",180,50);
 } else if (tic2>=2 && tic2<3) {
   count = 2; textFont(f,18); fill(54,54,54); text("48 - 72 h",180,50);
 } else if (tic2>=3) { 
   count = 3; textFont(f,18); fill(54,54,54); text("72 - 96 h",180,50);
 }  
 
  
  float totalprob;
  int contador;
  //Llegada
  for (int index = 0; index < 6; index = index + 1) {
    //Partida
    for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
      //Revisa...
      totalprob=0;
      contador=0;
      for (int index3 = 0; index3 < lines2.length; index3 = index3 + 1) {        
         if(wpartida[index3] == index2+1 && wllegada[index3] == index+1 && wdia[index3] == count+1 && (wtime[index3]>=diacomienzo && wtime[index3]<diacomienzo+7) ) {       
          totalprob = totalprob + wprob[index3];
          contador = contador + 1;
         }   
         if(contador>7) {
          break; 
         }
      }
      if(totalprob>0) {
           a[index2] = 2 * sqrt( totalprob/contador/PI ) * factorcircle;   
      } else {
           a[index2] = 0;
      }                 
    } 
   
    
    x0 = map(xpos_llegada[index],minlon, maxlon, 0,377);
    y0 = 600-map(ypos_llegada[index],minlat, maxlat, 0, 600);
    strokeWeight(1);
         
    a2=sort(a);
    
    //Partida para reordenar
    for (int index4 = 5; index4 >= 0; index4--) {
     for (int index5 = 0; index5 < 6; index5++) {
               
      if(a[index5] == a2[index4]) {       
       if(corridor_selected!=0) {
        stroke(paleta[index_corridor]);
        fill(paleta[index_corridor],200);
        ellipse(x0,y0,a_old[index][index_corridor]+(a[index_corridor]-a_old[index][index_corridor])*dt,a_old[index][index_corridor]+(a[index_corridor]-a_old[index][index_corridor])*dt);     
        a_old[index][index_corridor]=a_old[index][index_corridor]+(a[index_corridor]-a_old[index][index_corridor])*dt;       
        } else {  
        stroke(paleta[index5]);
        fill(paleta[index5],200);  
        ellipse(x0,y0,a_old[index][index5]+(a[index5]-a_old[index][index5])*dt,a_old[index][index5]+(a[index5]-a_old[index][index5])*dt);      
        a_old[index][index5]=a_old[index][index5]+(a[index5]-a_old[index][index5])*dt;  
        }      
        break;         
       }
       
     }    
    }
    
    // Lleva a cero al principio de la secuencia
    if(count==0 && dt<0.25) {
      for (int index5 = 0; index5 < 6; index5++) {
        a_old[index][index5]=0;
      } 
    }
  }  
  
  
    
  
  // Draw the text over the corridors
  float[] por_corridor = {0, 0, 0, 0, 0, 0};
  //Partida
  for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
    //Llegada
    totalprob = 0;
    contador = 0;
    for (int index = 0; index < 6; index = index + 1) {
      //Revisa
      contador = 0;
      for (int index3 = 0; index3 < lines2.length; index3 = index3 + 1) {       
        if(wpartida[index3] == index2+1 && wllegada[index3] == index+1 && wdia[index3] == count+1 && (wtime[index3]>=diacomienzo && wtime[index3]<diacomienzo+7) ) {     
          totalprob = totalprob + wprob[index3];
          por_corridor[index2] = por_corridor[index2] + wprob[index3];
          contador = contador +1;
        }         
      }
      if(totalprob>0) {
           //por_corridor[index2] = totalprob/contador;  
           por_corridor[index2] = por_corridor[index2]/contador;
      } else {
           por_corridor[index2] = 0;
      }  
    } 
    fill(0); textFont(f,9);
    x0 = map(xpos_partida[index2],minlon, maxlon, 0,377);
    y0 = 600-map(ypos_partida[index2],minlat, maxlat, 0, 600);
    text(nf(por_corridor[index2],1,2) + "%",x0-10,y0-10);
   }
   
  /*
  // Draw the accumulated probability
  int apila = 0;
  int apila_previous = height-40;
   //Partida
  for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
    totalprob=0;
    //Llegada
    for (int index = 0; index < 6; index = index + 1) {
      //Revisa
      contador=0;
      for (int index3 = 0; index3 < lines2.length; index3 = index3 + 1) {
        // Dia a dia
        for (int index6 = 0; index6 < 4; index6 = index6 + 1) {
          for (int contaje = 0; contaje < 7; contaje++) {
             if(wpartida[index3] == index2+1 && wllegada[index3] == index+1 && wdia[index3] == index6+1 && wtime[index3]==diacomienzo+contaje) {    
                 totalprob = totalprob + wprob[index3];
                 contador = contador +1;
             }   
          }
          if(totalprob>0 && contador!=0) {         
            por_accum[index2][index6] = por_accum[index2][index6] + totalprob/contador; 
          }  else {
            por_accum[index2][index6] = por_accum[index2][index6];
          }  
        }  
      }     
    }
  */
 
   // Draw the accumulated probability
  int apila = 0;
  int apila_previous = height-40;
  float totalcorredores;
  boolean muyalto = false;
  
   //Partida
  for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
    // Dia a dia    
    for (int index6 = 0; index6 < 4; index6 = index6 + 1) {     
      //Llegada
      totalcorredores = 0;
      for (int index = 0; index < 6; index = index + 1) { 
         //Revisa
         totalprob=0;
         contador=0;
         for (int contaje = 0; contaje<7; contaje++) {          
            for (int index3 = 0; index3 < lines2.length; index3 = index3 + 1) {
            // Dia a dia
             if(wpartida[index3] == index2+1 && wllegada[index3] == index+1 && wdia[index3] == index6+1 && wtime[index3]==diacomienzo+contaje) {    
                 totalprob = totalprob + wprob[index3];
                 contador = contador +1;
             }   
            }
          }
          if(totalprob>0) {
            totalprob = totalprob/contador;
          } else {
            totalprob = 0;
          }          
          totalcorredores = totalcorredores + totalprob;
        }
        por_accum[index2][index6] =  totalcorredores;      
      }     
             
   apila = apila + round( (por_accum[index2][0]+por_accum[index2][1]+por_accum[index2][2]+por_accum[index2][3])/6 );
   //Multiplico por una factor
   int altocorredor = round(por_accum[index2][0]+por_accum[index2][1]+por_accum[index2][2]+por_accum[index2][3]); 
   stroke(paleta[index2]);
   fill(paleta[index2],200);
   rect(430,apila_previous-altocorredor,20,altocorredor);
   
   fill(0); textFont(f2,9);
   
   //if(altocorredor>5) {
   if(index2==5) {  
     textAlign(RIGHT);
     text(apila + "%",428,apila_previous-altocorredor);
     textAlign(LEFT);
   }
   
   if(corridor_selected == index2+1) {
         
     stroke(paleta[index_corridor]);
     fill(darken(paleta[index_corridor]),200);
     rect(430,apila_previous-altocorredor,20,altocorredor);
         
     stroke(paleta[index_corridor]);
     fill(paleta[index_corridor],200);
         
     int total = (int)(round(por_accum[index2][0]+por_accum[index2][1]+por_accum[index2][2]+por_accum[index2][3]));  
     
     if(total>0) {
       
     rect(530,height-40-round(por_accum[index_corridor][0]*heightbar/total),20,round(por_accum[index_corridor][0]/total*heightbar));
     rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1])*heightbar/total ),20,round(por_accum[index_corridor][1]/total*heightbar));
     rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2])*heightbar/total),20,round(por_accum[index_corridor][2]/total*heightbar));
     rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total ),20,round(por_accum[index_corridor][3]/total*heightbar));
            
     stroke(darken(paleta[index_corridor]),200);
     fill(darken(paleta[index_corridor]),200);
     if (count==0) {
       rect(530,height-40-round(por_accum[index_corridor][0]*heightbar/total),20,round(por_accum[index_corridor][0]/total*heightbar));
       text("Day 1",555, height-40-round(por_accum[index_corridor][0]*heightbar/total)+round(por_accum[index_corridor][0]/total*heightbar)/2);
     } else if (count==1) {
       rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1])*heightbar/total ),20,round(por_accum[index_corridor][1]/total*heightbar));
       text("Day 2",555, height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1])*heightbar/total )+round(por_accum[index_corridor][1]/total*heightbar)/2);
     } else if (count==2) {
       rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2])*heightbar/total),20,round(por_accum[index_corridor][2]/total*heightbar));
       text("Day 3",555, height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2])*heightbar/total)+round(por_accum[index_corridor][2]/total*heightbar)/2);
     } else if (count==3) {
       rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total ),20,round(por_accum[index_corridor][3]/total*heightbar));
       text("Day 4",555, height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total )+round(por_accum[index_corridor][3]/total*heightbar)/2);
     }  
     
     line(450,apila_previous,530,height-40);
     line(450,apila_previous-altocorredor,530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total ));    
    
     } 
  
    }    
   apila_previous = apila_previous-altocorredor;  
  }
  
   fill(0);
   textFont(f,11);
   text("    % virtual oil spills reaching", 385,height-25);
   text("    the coast during the first 96 h",385,height-10);     
   if(corridor_selected != 0) {   
     text(" Relative prob.", 510,height-25);
     text("and arrival time",510,height-10); 
   }

}  


void drawannual() {
  
 //We sum "1" to deal with some indexes
 float[] a = new float[6];
 float[] a2 = new float[6];
 int count = 0;
 float x0, y0;
 int heightbar = 80;
 
 int index_corridor = (int)(corridor_selected-1);
 
 //Initialize variables por_accum
  for (int index = 0; index < 6; index++) { 
    for (int index2 = 0; index2 < 4; index2++) {
      por_accum[index][index2] = 0.0;
    }
  } 
 
 float timelapse = 8000;
 float tic2 = millis()%timelapse; 
 tic2=tic2/timelapse*4;
 float dt = tic2-floor(tic2);
 if(tic2<1) {
   count = 0; textFont(f,18); fill(54,54,54); text(" 0 - 24 h",180,50);
 } else if (tic2>=1 && tic2<2) {
   count = 1; textFont(f,18); fill(54,54,54); text("24 - 48 h",180,50);
 } else if (tic2>=2 && tic2<3) {
   count = 2; textFont(f,18); fill(54,54,54); text("48 - 72 h",180,50);
 } else if (tic2>=3) { 
   count = 3; textFont(f,18); fill(54,54,54); text("72 - 96 h",180,50);
 }  
 
  //Llegada
  for (int index = 0; index < 6; index = index + 1) {
    //Partida
    for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
      //Revisa...
      for (int index3 = 0; index3 < lines.length; index3 = index3 + 1) {         
        if(partida[index3] == index2+1 && llegada[index3] == index+1 && dia[index3] == count+1) {       
          a[index2] = 2 * sqrt( prob[index3]/PI ) * factorcircle;
          break; 
        }    
      }      
    } 
    
    x0 = map(xpos_llegada[index],minlon, maxlon, 0,377);
    y0 = 600-map(ypos_llegada[index],minlat, maxlat, 0, 600);
    strokeWeight(1);
         
    a2=sort(a);
    
    //Partida para reordenar
    for (int index4 = 5; index4 >= 0; index4--) {
     for (int index5 = 0; index5 < 6; index5++) {
               
      if(a[index5] == a2[index4]) {       
       if(corridor_selected!=0) {
        stroke(paleta[index_corridor]);
        fill(paleta[index_corridor],200);
        ellipse(x0,y0,a_old[index][index_corridor]+(a[index_corridor]-a_old[index][index_corridor])*dt,a_old[index][index_corridor]+(a[index_corridor]-a_old[index][index_corridor])*dt);     
        a_old[index][index_corridor]=a_old[index][index_corridor]+(a[index_corridor]-a_old[index][index_corridor])*dt;       
        } else {  
        stroke(paleta[index5]);
        fill(paleta[index5],200);  
        ellipse(x0,y0,a_old[index][index5]+(a[index5]-a_old[index][index5])*dt,a_old[index][index5]+(a[index5]-a_old[index][index5])*dt);      
        a_old[index][index5]=a_old[index][index5]+(a[index5]-a_old[index][index5])*dt;  
        }      
        break;         
       }
       
     }    
    }
    
    // Lleva a cero al principio de la secuencia
    if(count==0 && dt<0.25) {
      for (int index5 = 0; index5 < 6; index5++) {
        a_old[index][index5]=0;
      } 
    } 
  
  }
  
  // Draw the text over the corridors
  float[] por_corridor = {0, 0, 0, 0, 0, 0};
  //Partida
  for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
    //Llegada
    for (int index = 0; index < 6; index = index + 1) {
      //Revisa
      for (int index3 = 0; index3 < lines.length; index3 = index3 + 1) {       
        if(partida[index3] == index2+1 && llegada[index3] == index+1 && dia[index3] == count+1) {    
          por_corridor[index2] = por_corridor[index2] + prob[index3];
          break; 
        }    
      }     
    }
    fill(0); textFont(f,9);
    x0 = map(xpos_partida[index2],minlon, maxlon, 0,377);
    y0 = 600-map(ypos_partida[index2],minlat, maxlat, 0, 600);
    text(nf(por_corridor[index2],1,2) + "%",x0-10,y0-10);
  }
  
  // Draw the accumulated probability
  int apila = 0;
  int apila_previous = height-40;
   //Partida
  for (int index2 = 0; index2 < 6; index2 = index2 + 1) {
    //Llegada
    for (int index = 0; index < 6; index = index + 1) {
      //Revisa
      for (int index3 = 0; index3 < lines.length; index3 = index3 + 1) {
        // Dia a dia
        for (int index6 = 0; index6 < 4; index6 = index6 + 1) {
          if(partida[index3] == index2+1 && llegada[index3] == index+1 && dia[index3] == index6+1) {    
           por_accum[index2][index6] = por_accum[index2][index6] + prob[index3];
          }   
        }  
      }     
    }
   
   apila = apila + int( (floor(por_accum[index2][0]+por_accum[index2][1]+por_accum[index2][2]+por_accum[index2][3]))/6 );
   //Multiplico por factor 2
   int altocorredor = (int)(floor(por_accum[index2][0]+por_accum[index2][1]+por_accum[index2][2]+por_accum[index2][3])*2);
   stroke(paleta[index2]);
   fill(paleta[index2],200);
   //rect(430,apila_previous-apila,20,apila);
   rect(430,apila_previous-altocorredor,20,altocorredor);
   
   fill(0); textFont(f2,9);
   if(index2==5) {
      text(apila + "%",410,apila_previous-altocorredor);
   }
   
   if(corridor_selected == index2+1) {
         
     stroke(paleta[index_corridor]);
     fill(darken(paleta[index_corridor]),200);
     rect(430,apila_previous-altocorredor,20,altocorredor);
         
     stroke(paleta[index_corridor]);
     fill(paleta[index_corridor],200);
         
     int total = (int)(floor(por_accum[index2][0]+por_accum[index2][1]+por_accum[index2][2]+por_accum[index2][3]));  
     rect(530,height-40-round(por_accum[index_corridor][0]*heightbar/total),20,round(por_accum[index_corridor][0]/total*heightbar));
     rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1])*heightbar/total ),20,round(por_accum[index_corridor][1]/total*heightbar));
     rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2])*heightbar/total),20,round(por_accum[index_corridor][2]/total*heightbar));
     rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total ),20,round(por_accum[index_corridor][3]/total*heightbar));
    
     stroke(darken(paleta[index_corridor]),200);
     fill(darken(paleta[index_corridor]),200);
     if (count==0) {
       rect(530,height-40-round(por_accum[index_corridor][0]*heightbar/total),20,round(por_accum[index_corridor][0]/total*heightbar));
       text("Day 1",555, height-40-round(por_accum[index_corridor][0]*heightbar/total)+round(por_accum[index_corridor][0]/total*heightbar)/2);
     } else if (count==1) {
       rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1])*heightbar/total ),20,round(por_accum[index_corridor][1]/total*heightbar));
       text("Day 2",555, height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1])*heightbar/total )+round(por_accum[index_corridor][1]/total*heightbar)/2);
     } else if (count==2) {
       rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2])*heightbar/total),20,round(por_accum[index_corridor][2]/total*heightbar));
       text("Day 3",555, height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2])*heightbar/total)+round(por_accum[index_corridor][2]/total*heightbar)/2);
     } else if (count==3) {
       rect(530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total ),20,round(por_accum[index_corridor][3]/total*heightbar));
       text("Day 4",555, height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total )+round(por_accum[index_corridor][3]/total*heightbar)/2);
     }  
     
     line(450,apila_previous,530,height-40);
     line(450,apila_previous-altocorredor,530,height-40-round( (por_accum[index_corridor][0]+por_accum[index_corridor][1]+por_accum[index_corridor][2]+por_accum[index_corridor][3])*heightbar/total ));    
     
    }    
   
   apila_previous = apila_previous-altocorredor;  
   
  }
  
  
   fill(0);
   textFont(f,11);
   text("    % virtual oil spills reaching", 385,height-25);
   text("    the coast during the first 96 h",385,height-10);    
   if(corridor_selected != 0) {   
     //text(" Relative prob.", 510,height-25);
     //text("and arrival time",510,height-10); 
   }
    
}  


void annotate() {
  
     //Linea divisoria
     stroke(darkblue);
     strokeWeight(1);
     line(377,0,377,600);
     //line(377,0,377,70); 
  
     //Play with me
     stroke(darken(colorfondo)); fill(darken(colorfondo));
     ellipse(30,30,40,40);
     stroke(240); fill(240);
     triangle(24,20,24,40,44,30);
     stroke(darken(darken(darken(colorfondo)))); fill(darken(darken(darken(colorfondo))));
     textFont(f2,24);
     text("Play", 30, 25);
     textFont(f3,18);
     text("With",3,40);
     textFont(f3,22);
     text("me",35,50);   
     
     //Draw reference circles: 5%, 2% and 1%
     stroke(255,255,255); noFill();
     float probref = 2 * sqrt( 5/PI ) * factorcircle;   
     ellipse(75,height-75,probref,probref);
     fill(255); textFont(f,10); text("5%", 75+probref/2*cos(PI/4),height-75-probref/2*sin(PI/4));
     
     stroke(255,255,255); noFill();
     probref = 2 * sqrt( 2/PI ) * factorcircle;   
     ellipse(75,height-75,probref,probref);
     fill(255); textFont(f,10); text("2%", 75+probref/2*cos(PI/4),height-75-probref/2*sin(PI/4));
  
     stroke(255,255,255); noFill();
     probref = 2 * sqrt( 1/PI ) * factorcircle;   
     ellipse(75,height-75,probref,probref);
     fill(255); textFont(f,10); text("1%", 75+probref/2*cos(PI/4),height-75-probref/2*sin(PI/4));
     
     
     if(looped) {
       //fill(darkblue);
       //textFont(f3,16);
       //text("Click over the map", width-180, 20);
       //text("        to pause  ", width-180, 35);      
     }  else {
       //fill(darkblue);
       //textFont(f3,16);
       //text("Click over the map", width-180, 20);
       //text("        to play   ", width-180, 35);      
       noLoop();  // Releasing the mouse stops looping draw()
     }
     
     
      fill(darkblue);
      textFont(f,13);
      textAlign(CENTER);
      text("CONTROLS", width-100, 20);
      textFont(f,11);
      textAlign(LEFT);
      text("· Click over the map to play/pause.", width-210, 38);
      text("· Move the cursor over one corridor", width-210,55); 
      text("  to select it.", width-210, 68);   
   
      fill(255);
      textAlign(LEFT);
      textFont(f,10);
      text("Pablo Otero", 5, height-5);
         
}  


// taken from:
// http://hg.postspectacular.com/toxiclibs/src/tip/src.core/toxi/geom/Polygon2D.java
boolean containsPoint(PVector[] verts, float px, float py) {
  int num = verts.length;
  int i, j = num - 1;
  boolean oddNodes = false;
  for (i = 0; i < num; i++) {
    PVector vi = verts[i];
    PVector vj = verts[j];
    if (vi.y < py && vj.y >= py || vj.y < py && vi.y >= py) {
      if (vi.x + (py - vi.y) / (vj.y - vi.y) * (vj.x - vi.x) < px) {
        oddNodes = !oddNodes;
      }
    }
    j = i;
  }
  return oddNodes;
}


void mousePressed() {
  boolean captured = tools.offerMousePress();  
}
  
void mouseReleased() {
 if(mouseX>0 && mouseX<377) { 
  if(looped) {
   looped = false;
  } else {  
   loop(); 
   looped = true; 
  } 
 } 
}
