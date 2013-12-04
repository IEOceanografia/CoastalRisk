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
// version 1.0

class guiElement {
  String name = "";
  float width, height, x0, y0;
  
  boolean update() {return false;}
  
  boolean offerMousePress() {return false;}
  
  float[] position() {
    float[] r = {x0, y0, width, height};
    return r;
  }  
}



class button extends guiElement {
  color neutralColor, activeColor, highlightColor;
  color backgroundColor = color(255);
  // these make a color palette, that can be used in different ways.
  // use foreColor() and bkgndColor() for drawing.
  boolean active = false;
  boolean pressed = false;
  boolean hidden = false;
  int thetextsize = 9;
  float leading = 0.8;
  
  void construct(String name0, float[] pos, color neutral, color actv) {
    neutralColor = neutral;
    activeColor = actv;
    highlightColor = darken(activeColor);
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
    name = name0;
  }

  void drawFace() {
    noStroke();
    fill(foreColor());
    rectMode(CORNER);
    rect(x0,y0,width,height);
  }
  
  void drawName() {
    fill(bkgndColor());
    textAlign(CENTER);
    textSize(thetextsize);
    textLeading(leading*thetextsize);
    text(name,x0+width/2,y0+height/2+thetextsize/2);
  }
  
  color foreColor() {
    if (pressed) {
      return(highlightColor);
    } else if (over()) {
      return(activeColor);
    } else {
      return(neutralColor);
    }
  }
  
  color bkgndColor() {
    return backgroundColor;
  }
  
  void draw() {
    if (!hidden) {
      drawFace();
      drawName();
    }
  }
  
  boolean over() {
    return (((mouseX>=x0) && (mouseX<=x0+width)) && ((mouseY>=y0) && (mouseY<=y0+height)));
  }
  
  boolean offerMousePress() {
    pressed = over() && (!hidden);
    return pressed;
  }
  
  boolean update() {
    // returns true when the button is released.
    boolean result = false;
    if (pressed) {
      active = over();
      pressed = mousePressed;
    }
    if (active && (!mousePressed)) {
      pressed = false;
      active = false;
      result = true;
    } 
    draw();
    return result;
  }
  
}


class textButton extends button {

  textButton(String name0, float[] pos, color neutral, color actv) {
    construct(name0, pos, neutral, actv);
    thetextsize = round(height/3);
  }   
}


class polyButton extends button {
  
  float[] px,py; // coords of the polygon
  boolean drawSecondPoly = false;
  float[] px2, py2; // optional second polygon, for more complex shapes
  boolean drawCutoutPoly = false;
  float[] cx,cy; // option extra polygon in bkgndColor() instead of foreColor()
  boolean showName = true;
  
  polyButton(String name0, float[] pos, color neutral, color actv, float[] xx, float[] yy) {
    construct(name0, pos, neutral, actv);
    thetextsize = round(height/3);
    definePoly(xx,yy);
  }   

  void definePoly(float[] xx, float[] yy) {
    px = xx;
    py = yy;
  }
  
  void defineSecondPoly(float[] xx, float[] yy) {
    drawSecondPoly = true;
    px2 = xx;
    py2 = yy;
  }
  
  void defineCutoutPoly(float[] xx, float[] yy, color col) {
    drawCutoutPoly = true;
    cx = xx;
    cy = yy;
  }
  
  void drawFace() {
    fill(foreColor());
    noStroke();
    beginShape(POLYGON);
    for (int i=0; i<px.length; i++) {
      vertex(x0+width*px[i],y0+height*(1-py[i]));
    }
    endShape();
    if (drawSecondPoly) {
      beginShape(POLYGON);
      for (int i=0; i<px2.length; i++) {
        vertex(x0+width*px2[i],y0+height*(1-py2[i]));
      }
    }
    if (drawCutoutPoly) {
      fill(bkgndColor());
      beginShape(POLYGON);
      for (int i=0; i<px2.length; i++) {
        vertex(x0+width*px2[i],y0+height*(1-py2[i]));
      }
    }
  }
  
  void drawName() {
    if (showName) {
      textSize(thetextsize);
      textAlign(CENTER);
      textLeading(leading*thetextsize);
      fill(foreColor());
      text(name, x0+width/2, y0+height+1.2*thetextsize);
    }
  }

}




class multistatePolyButton extends guiElement {
  
  polyButton[] states;
  int lastDefined = -1;
  int current = 0;
  boolean hidden = false;
  
  multistatePolyButton(int N, float[] pos) {
    states = new polyButton[N];
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
  }
  
  multistatePolyButton(int N, polyButton firstState) {
    states = new polyButton[N];
    addState(firstState);
    x0 = firstState.x0; y0 = firstState.y0; width = firstState.width; height = firstState.height;
  }
  
  multistatePolyButton(String name0, int N, float[] pos) {
    name = name0;
    states = new polyButton[N];
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
  }
  
  multistatePolyButton(String name0, int N, polyButton firstState) {
    name = name0;
    states = new polyButton[N];
    addState(firstState);
    x0 = firstState.x0; y0 = firstState.y0; width = firstState.width; height = firstState.height;
  }

  
  
  int addState(polyButton btn) {
    if (lastDefined < states.length) {
      lastDefined++;
      states[lastDefined] = btn;
      states[lastDefined].hidden = true;
      if (lastDefined==current) {
        syncPosition();
      }
      return lastDefined;
    } else {
      return -1;
    }
  }
  
  polyButton currentState() {
    return states[current];
  }
  
  void syncPosition() {
    polyButton s = currentState();
    x0 = s.x0;
    y0 = s.y0;
    width = s.width;
    height = s.height;
  }
  
  boolean update() {
    boolean result = false;
    if (!hidden) {
      states[current].hidden = false;
      result = states[current].update();
      if (result) {
        states[current].hidden = true;
        current++;
        if (current==states.length) {current=0;}
        syncPosition();
      }
    }
    return result;
  }
  
  void draw() {
    if (!hidden) {
      states[current].draw();
    }
  }
  
  boolean offerMousePress() {
    boolean captured = false;
    if (!hidden) {
      captured = states[current].offerMousePress();
    }
    return captured;
  }
  
}



class slider extends guiElement {
  color neutralColor, activeColor, highlightColor;
  color backgroundColor = color(255);
  // these define a color palette, that can be used in different ways.
  // use foreColor() and bkgndColor() for drawing.
  float indicatorWidth;
  boolean active = false;
  boolean pressed = false;
  boolean hidden = false;
  boolean showName = true;
  boolean showVal = true;
  float nameTextSize, valTextSize;
  float leading = 0.8;
  int decimalPlaces = 2;
  boolean quantized = false;
  float quantizeUnit;
  
  float dataMin, dataMax;
  boolean logScale = false;
  float pos = 0.5; // current position, 0..1
  
  slider(String name0, float[] pos, color neutral, color actv, float minVal, float maxVal) {
    neutralColor = lighten(neutral);
    activeColor = actv;
    highlightColor = darken(darken(activeColor));
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
    indicatorWidth = height;
    nameTextSize = height;
    valTextSize = 1.2*height;
    name = name0;
    dataMin = minVal;
    dataMax = maxVal;
  }
  
  void quantize(float unit) {
    quantized = true;
    quantizeUnit = unit;
    if (abs(unit-round(unit)) < 1e-6) {
      decimalPlaces = 0;
    }
    setVal(getVal());
  }

  color foreColor() {
    if (pressed) {
      return(highlightColor);
    } else if (over()) {
      return(activeColor);
    } else {
      return(neutralColor);
    }
  }
  
  color bkgndColor() {
    return backgroundColor;
  }
  
  void drawBar() {
    rectMode(CORNER);
    noStroke();
    fill(bkgndColor());
    fill(220);
    rect(x0,y0,width,height);
    fill(foreColor());
    float x1 = x0 + (width-indicatorWidth)*getPos();
    rect(x1,y0,indicatorWidth,height);
  }
  
  void drawName() {
    fill(foreColor());
    textAlign(RIGHT);
    textSize(nameTextSize);
    textLeading(leading*nameTextSize);
    text(name+" ",x0,y0+height);
  }
  
  void drawVal() {
    fill(foreColor());
    textAlign(LEFT);
    //textSize(valTextSize);
    textSize(14);
    textLeading(leading*valTextSize);
    //text(" "+val2string(int(getVal())), x0+width, y0+height);  //POT
    text(" "+floor(getVal()), x0+width, y0+height);  //POT
    //text(" "+val2string(time_day[count]), x0+width, y0+height);
    //text(" "+time_day[count]+"/"+time_month[count]+"/"+time_year[count],  x0+width/5, y0+height+15);
    //text(" "+time_day[count]+" "+months[time_month[count]-1]+" "+time_year[count],  x0+width/6, y0+height+15);
  }
  
  void draw() {
    if (!hidden) {
      drawBar();
      if (showName) {drawName();}
      if (showVal) {drawVal();}
    }
  }
  
  boolean over() {
    return (((mouseX>=x0) && (mouseX<=x0+width)) && ((mouseY>=y0) && (mouseY<=y0+height)));
  }
  
  boolean offerMousePress() {
    pressed = over() && (!hidden);
    return pressed;
  }
  
  boolean update() {
    // returns true if the user is changing the position of the slider.
    boolean result = false;
    if (!hidden) {
      pressed = pressed && mousePressed;
      active = over() && pressed;
      if (active) {
        float newpos = (mouseX - x0) / (width - indicatorWidth);
        if (newpos != getPos()) {
          setPos(newpos);
          result = true;
        }
      }
      draw();
    }
    return result;
  }
  
  // use these four routines for reading & changing the position of the slider.
  // pos = relative position, 0..1
  // val = value in data units  
  float getPos() {return pos;}
  float getVal() {return pos2val(getPos());}
  void setPos(float p) {pos = constrain(p, 0, 1);}
  void setVal(float v) {setPos(val2pos(v));}

  // these are general conversion functions, that can be used for values other than the current one
  // e.g., to find out the current min and max values allowed, use pos2val(0) and pos2val(1)
  String val2string(float v) {
    if (decimalPlaces==0) {
      return str(round(v));
    } else {
      float p = pow(10,decimalPlaces);
      return str(round(v*p)/(float)p);
    }
  }
  
  float val2pos(float v) {
    float p;
    if (quantized) {
      v = round(v/quantizeUnit)*quantizeUnit;
    }
    if (logScale) {
      p = (log(v)-log(dataMin))/(log(dataMax)-log(dataMin));
    } else {
      p = (v-dataMin)/(dataMax-dataMin);
    }
    return p;
  }
  
  float pos2val(float p) {
    float v;
    if (logScale) {
      v = dataMin * pow(dataMax/dataMin, p);
    } else {
      v = dataMin + (dataMax-dataMin) * p;
    }
    if (quantized) {
      v = round(v/quantizeUnit)*quantizeUnit;
    }
    return v;
  }  
  
}





class toolbar extends guiElement {
  guiElement[] elements;
  float spacing;
  int length=0; // number of defined elements
  float unoccupiedX0, unoccupiedWidth;
  boolean hidden = false;
  slider lastSliderAdded; // this is a kluge to make the "below" option work: elements[length-1].x0 returns 0 when elements[length-1] is a slider
  guiElement lastUpdated = null;
  
  toolbar(float[] pos, int maxElements) {
    elements = new guiElement[maxElements];
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
    spacing = height/2;
    unoccupiedX0 = x0;
    unoccupiedWidth = width;
  }
  
  guiElement lastAdded() {
    return elements[length-1];
  }
  
  guiElement find(String nm) {
    guiElement theOne = null;
    boolean found = false;
    for (int i=0; ((i<length) && (!found)); i++) {
      found = nm.equals(elements[i].name);
      if (found) theOne = elements[i];
    }
    return theOne;
  }
  
  guiElement addElement(guiElement E) {
    if (length < elements.length) {
      length++;
      elements[length-1] = E;
      return E;
    } else {
      return null;
    }    
  }
  
  // to add an element to the toolbar, use one of the following: arguments match the constructors for
  // each class, but replace the position rectangle with "left" or "right."
  textButton addTextButton(String name0, String alignmt, color neutral, color actv) {
    return (textButton) addElement(new textButton(name0, nextPosition(alignmt,height), neutral, actv));
  }
  
  polyButton addPolyButton(String name0, String alignmt, color neutral, color actv, float[] xx, float[] yy) {
    return (polyButton) addElement(new polyButton(name0, nextPosition(alignmt,height), neutral, actv, xx, yy));
  }

  multistatePolyButton addMultistatePolyButton(String name0, int N, String alignmt) {
    return (multistatePolyButton) addElement(new multistatePolyButton(name0, N, nextPosition(alignmt,2.5*height)));
  }

  slider addSlider(String name0, String alignmt, color neutral, color actv, float minVal, float maxVal) {
    float ht = height/3;
    float wd = 10*ht;
    float[] pos = nextPosition(alignmt,wd);
    pos[1] += (pos[3]-ht)/2;
    pos[3] = ht;
    slider S = new slider(name0, pos, neutral, actv, minVal, maxVal);
    addElement(S);
    lastSliderAdded = S;
    textSize(S.nameTextSize);
    float nameWidth = textWidth(S.name+" ");
    float valWidth = max(textWidth(S.val2string(S.pos2val(0))+" "), textWidth(S.val2string(S.pos2val(1))+" "));
    if (alignmt.equals("left") || alignmt.equals("LEFT")) {
      S.x0 += nameWidth;
      unoccupiedX0 += (nameWidth + valWidth);
      unoccupiedWidth -= (nameWidth + valWidth);
    } else if (alignmt.equals("right") || alignmt.equals("RIGHT")) {
      S.x0 -= valWidth;
      unoccupiedWidth -= (nameWidth + valWidth);
    } 
    return S;
  }
  
  float[] unoccupied() {
    float[] r = {unoccupiedX0, y0, unoccupiedWidth, height};
    return r;
  }

  float[] nextPosition(String alignmt, float dx) {  
    float dxtot = dx;
    float[] r;
    if (alignmt.equals("left") || alignmt.equals("LEFT")) { // in the main toolbar, aligned left
      if (unoccupiedX0 > x0) {dxtot += spacing;} // add spacer unless all the way at the left
      unoccupiedX0 += dxtot;
      unoccupiedWidth -= dxtot;
      r = defineRect(unoccupiedX0 - dx, y0, dx, height);
    } else if (alignmt.equals("right") || alignmt.equals("RIGHT")) { // in the main toolbar, aligned right
      if (unoccupiedX0+unoccupiedWidth < x0+width) {dxtot += spacing;} // add spacer unless all the way at the right
      unoccupiedWidth -= dxtot;
      r = defineRect(unoccupiedX0 + unoccupiedWidth, y0, dx, height);
    } else if (alignmt.equals("below") || alignmt.equals("BELOW")) { // directly below the last element defined
      // note: when the last element is a slider, the line below returns 0
      float xx = elements[length-1].x0;
      float yy = elements[length-1].y0 + elements[length-1].height + spacing;
      if (elements[length-1] instanceof slider) {
        xx = lastSliderAdded.x0;
        yy = lastSliderAdded.y0+1.5*lastSliderAdded.height;
      }
      r = defineRect(xx, yy, dx, height);
    } else {
      r = defineRect(0,0,0,0);
    }
    return r;
  }
    
  boolean update() {
    boolean result = false;
    if (!hidden) {
      for (int i=0; i<length; i++) {
        boolean updated = elements[i].update();
        if (updated) {
          lastUpdated = elements[i];
          result = true;
        }
      }
    }
    return result;
  }
  
  boolean offerMousePress() {
    boolean captured = false;
    for (int i=length-1; ((i>=0) && (!captured)); i=i-1) {
      captured = elements[i].offerMousePress();
    }
    return captured;
  } 
 
}



class dragSelector {
  float awareWidth, awareHeight, awareX0, awareY0; // the screen region that's monitored and selectable
  float selectedWidth, selectedHeight, selectedX0, selectedY0; // the current size of the selected rectangle; when not pressed, stores the last rect selected
  boolean pressed = false;
  boolean aware = true;
  
  dragSelector(float[] pos) {
    setAwareRect(pos);
    selectedX0 = -1; selectedY0 = -1; selectedWidth = -1; selectedHeight = -1;
  }
  
  void setAwareRect(float[] pos) {
    awareX0 = pos[0]; awareY0 = pos[1]; awareWidth = pos[2]; awareHeight = pos[3];
  }

  void draw() {
    fill(color(255,255,255,0.2*255));
    stroke(color(255,255,255));
    rectMode(CORNER);
    rect(selectedX0,selectedY0,selectedWidth,selectedHeight); 
  }
  
  boolean over() {
    return (((mouseX>=awareX0) && (mouseX<=awareX0+awareWidth)) && ((mouseY>=awareY0) && (mouseY<=awareY0+awareHeight)));
  }
  
  boolean offerMousePress() {
    pressed = false;
    if (aware) {
      pressed = over();
      if (pressed) {
        selectedX0 = mouseX;
        selectedY0 = mouseY;
        selectedWidth = 0;
        selectedHeight = 0;
      }
    }
    return pressed;
  }
  
  boolean update() {
    boolean released = false;
    if (aware) {
      pressed = (pressed) && (mousePressed); // already activated and mouse still down?
      if (pressed) {
        float x1 = constrain(mouseX, awareX0, awareX0+awareWidth);
        selectedWidth = x1 - selectedX0;   
        float y1 = constrain(mouseY, awareY0, awareY0+awareHeight);  
        selectedHeight = y1 - selectedY0;
        draw();
      } else {
        released = true;
      }
    }
    return released;
  }
  
  float[] selection() {
    float[] r = {selectedX0, selectedY0, selectedWidth, selectedHeight};
    return r;
  }
  
}

// version 1.0

// color utilities ---------------------------------------

color colorblend(color c1, color c2, float r) {
  return color(lerp(red(c1),red(c2),r),lerp(green(c1),green(c2),r),lerp(blue(c1),blue(c2),r),lerp(alpha(c1),alpha(c2),r));
}

color shift(color col, float r) {
  if (r>0) {
    return colorblend(col,color(255,255,255,alpha(col)),r);
  } else {
    return colorblend(col,color(0,0,0,alpha(col)),-r);  
  }
}

color lighten(color col) {return shift(col,0.25);}

color darken(color col) {return shift(col,-0.25);}

color randomshift(color col) {
  return shift(col, random(-0.5,0.5));
}

color colorinterp(float val, float lowval, float highval, color[] cmap) {return colorinterp(val,lowval,highval,cmap,"nearest");}
color colorinterp(float val, float lowval, float highval, color[] cmap, String mode) {
  if (mode.equals("linear")) {
    float level = constrain((val-lowval)/(highval-lowval),0,1-1e-6) * cmap.length;
    int level0 = floor(level);
    int level1 = constrain(ceil(level),0,cmap.length-1);
    return colorblend(cmap[level0],cmap[level1],level-level0);
  } else {
    int level = floor(constrain((val-lowval)/(highval-lowval),0,1-1e-6) * cmap.length);
    return cmap[level];
  }
}

color[] warmrainbow() {return warmrainbow(20);}
color[] warmrainbow(int n) {return warmrainbow(n, 0.9, 0.3);}
color[] warmrainbow(int n, float bright, float contrast) {
  // nice colorscale from blue to yellow to red
  float Hblue = 0.55; // hues for end & middle colors
  float Hyellow = 0.16667;
  float Hred = 0;
  float dipWidth = 1.5; // width of the dip in saturation over green
  
  float[] H = new float[n];
  float[] S = new float[n];
  float[] B = new float[n];
  int N = n-1;
  int iy = floor(n/(float)2); // index of yellow, the middle color
  
  // hue
  for (int i=0; i<=iy; i++) {
    H[i] = Hblue - (Hblue-Hyellow) *sq(i/(float)iy);
  }
  for (int i=iy+1; i<n; i++) {
    H[i] = lerp(H[iy],Hred,(i-iy)/((float)n-iy));
  }
  
  //saturation
  // find greenest color
  int ig = 0;
  for (int i=1; i<n; i++) {
    if (abs(H[i]-0.3333) < abs(H[ig]-0.3333)) {ig = i;}
  }
  // gaussian dip in saturation
  for (int i=0; i<n; i++) {
    S[i] = 1 - 0.5*exp(-dipWidth*sq(i/(float)ig-1));
  }
  
  // brightness
  float b = 4*contrast/N;
  float a = -b/N;
  for (int i=0; i<iy; i++) {
    B[i] = bright - lerp(contrast,0,i/((float)iy-1));
  }
  for (int i=iy; i<n; i++) {
    B[i] = a*sq(i) + b*i + bright - contrast;
  }
  
  colorMode(HSB);
  color[] map = new color[n];
  for (int i=0; i<map.length; i++) {
    map[i] = color(H[i]*255,S[i]*255,B[i]*255);
  }
  colorMode(RGB);
  
  return map;
}


// other utilities ---------------------------------------

float[] defineRect(float x0, float y0, float wd, float ht) {
  float[] r = {x0,y0,wd,ht};
  return r;
}

/*
 * ----------------------------------
 *  Radio Button Class for Processing 2.0
 * ----------------------------------
 *
 * this is a simple radio button class. The following shows 
 * you how to use it in a minimalistic way.
 *
 * DEPENDENCIES:
 *   N/A
 *
 * Created:  April, 12 2012
 * Author:   Alejandro Dirgan
 * Version:  0.14
 *
 * License:  GPLv3
 *   (http://www.fsf.org/licensing/)
 *
 * Follow Us
 *    adirgan.blogspot.com
 *    twitter: @ydirgan
 *    https://www.facebook.com/groups/mmiiccrrooss/
 *    https://plus.google.com/b/111940495387297822358/
 *
 * DISCLAIMER **
 * THIS SOFTWARE IS PROVIDED TO YOU "AS IS," AND WE MAKE NO EXPRESS OR IMPLIED WARRANTIES WHATSOEVER 
 * WITH RESPECT TO ITS FUNCTIONALITY, OPERABILITY, OR USE, INCLUDING, WITHOUT LIMITATION, ANY IMPLIED 
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR INFRINGEMENT. WE EXPRESSLY 
 * DISCLAIM ANY LIABILITY WHATSOEVER FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR SPECIAL 
 * DAMAGES, INCLUDING, WITHOUT LIMITATION, LOST REVENUES, LOST PROFITS, LOSSES RESULTING FROM BUSINESS 
 * INTERRUPTION OR LOSS OF DATA, REGARDLESS OF THE FORM OF ACTION OR LEGAL THEORY UNDER WHICH THE LIABILITY 
 * MAY BE ASSERTED, EVEN IF ADVISED OF THE POSSIBILITY OR LIKELIHOOD OF SUCH DAMAGES.
*/


/*
 this is a simple radio button class. The following shows you how to use it in a minimalistic way.


String[] options = {"First","Second","Third", "Fourth"}; 
ADradio radioButton;
int radio;


PFont output; 

void setup()
{
  size(300,300);
  smooth();
  output = createFont("Arial",24,true);  

  radioButton = new ADradio(117, 78, options, "radioButton"); 
  radioButton.setDebugOn();
  radioButton.setBoxFillColor(#F7ECD4);  
  radioButton.setValue(1);

}

void draw()
{
  background(#FFFFFF);

  radioButton.update();

  textFont(output,24);   
  text(options[radioButton.getValue()], (width-textWidth(options[radioButton.getValue()]))/2, height-20);

}


*/

class ADRadio
{
  
  color externalCircleColor=#000000;
  color externalFillCircleColor=#FFFFFF;
  color internalCircleColor=#000000;
  color internalFillCircleColor=#000000;
  
  boolean fillExternalCircle=false;
  
  PFont rText;
  color textColor=#000000;
  color textShadowColor=#7E7E7E;
  boolean textShadow=false;
  int textPoints=12;
  
  int xTextOffset=20;
  int yTextSpacing=14;
  
  int circleRadius=12;
  float circleLineWidth=0.5;
 
  float boxLineWidth=0.2;
  boolean boxFilled=false;
  color boxLineColor=#000000;
  color boxFillColor=#F4F5D7;
  boolean boxVisible=false;
  
  String[] radioText;
  boolean[] radioChoose; 
  
  int over=0;
  int nC;
  
  int rX, rY;
  
  float maxTextWidth=0;
  
  String radioLabel;
  
  boolean debug=false;
  
  int boxXMargin=5;
  int boxYMargin=5;
  
  int bX, bY, bW, bH;
  boolean pressOnlyOnce=true;
  int deb=0;    
  
///////////////////////////////////////////////////////  
  ADRadio(int x, int y, String[] op, String id)
  {
    rX=x;
    rY=y;
    radioText=op;
    
    nC=op.length;
    radioChoose = new boolean[nC];
        
    rText = createFont("Arial",16,true);      
    textFont(rText,textPoints);   
    textAlign(LEFT);
    
    for (int i=0; i<nC; i++) 
    {
      if (textWidth(radioText[i]) > maxTextWidth) maxTextWidth=textWidth(radioText[i]);
      radioChoose[i]=false;
    }
    
    radioChoose[over]=true;
    
    radioLabel=id;
    
    calculateBox();
    
  }
  
///////////////////////////////////////////////////////  
  void calculateBox()
  {
    bX=rX-circleRadius/2-boxXMargin;
    bY=rY-circleRadius/2-boxYMargin;
    bW=circleRadius*2+xTextOffset+(int )maxTextWidth;
    bH=radioText.length*circleRadius + (radioText.length-1)*yTextSpacing + boxYMargin*2;
  }  
///////////////////////////////////////////////////////  
  void setValue(int n)
  {
    if (n<0) n=0;
    if (n>(nC-1)) n=nC-1;
    
   for (int i=0; i<nC; i++) radioChoose[i]=false;
   radioChoose[n]=true;  
   over=n; 
  }
///////////////////////////////////////////////////////  
  void deBounce(int n)
  {
    if (pressOnlyOnce) 
      return;
    else
      
    if (deb++ > n) 
    {
      deb=0;
      pressOnlyOnce=true;
    }
    
  }  ///////////////////////////////////////////////////////  
  boolean mouseOver()
  {
    boolean result=false; 
    
    if (debug)
      if ((mouseX>=bX) && (mouseX<=bX+bW) && (mouseY>=bY) && (mouseY<=bY+bH))
      {
        if (mousePressed && mouseButton==LEFT && keyPressed)
        {
          if (keyCode==CONTROL)
          {
            rX=rX+(int )((float )(mouseX-pmouseX)*1);
            rY=rY+(int )((float )(mouseY-pmouseY)*1);
            calculateBox();
          }
          if (keyCode==SHIFT && pressOnlyOnce) 
          {
            printGeometry();
            pressOnlyOnce=false;
          }
          deBounce(5);
          
        }
      }
      
    for (int i=0; i<nC; i++)
    {
      if ((mouseX>=(rX-circleRadius)) && (mouseX<=(rX+circleRadius)) && (mouseY>=(rY+(i*(yTextSpacing+circleRadius))-circleRadius)) && (mouseY<=(rY+(i*(yTextSpacing+circleRadius))+circleRadius)))
      {
        result=true;
        
        if (mousePressed && mouseButton==LEFT && pressOnlyOnce)
        {
          over=i;
          setValue(over);
          pressOnlyOnce=false;
        }
        deBounce(5);
        i=nC;
      }
      else
      {
        result=false;
      }
    } 
    return result;
  }
///////////////////////////////////////////////////////  
  void drawBox()
  {
    if (!boxVisible) return;
    if (boxFilled)
      fill(boxFillColor);
    else
      noFill();
    strokeWeight(boxLineWidth);
    stroke(boxLineColor);

    rect(bX, bY, bW, bH);

  }  
///////////////////////////////////////////////////////  
  void drawCircles()
  {
    strokeWeight(circleLineWidth);
    for (int i=0; i<nC; i++)
    {
      if (!fillExternalCircle) 
        noFill();
      else
        fill(externalFillCircleColor);  
      stroke(externalCircleColor);  
      ellipse(rX, rY+(i*(yTextSpacing+circleRadius)), circleRadius, circleRadius);

      fill(internalFillCircleColor);
      stroke(internalCircleColor);  

      if (radioChoose[i])
         ellipse(rX, rY+(i*(yTextSpacing+circleRadius)), circleRadius-8, circleRadius-8);
    }
    mouseOver();
   
  }
///////////////////////////////////////////////////////  
  void drawText()
  {
    float yOffset=rY+textPoints/3+1;
    stroke(textColor);
    textFont(rText,textPoints);   
    textAlign(LEFT);

    for (int i=0; i<nC; i++)
    {
      if (textShadow)
      {
        stroke(textShadowColor);
        text(radioText[i], rX+xTextOffset+1, yOffset+(i*(yTextSpacing+circleRadius))+1);
        stroke(textColor);
      }
      text(radioText[i], rX+xTextOffset, yOffset+(i*(yTextSpacing+circleRadius)));
    }
    
  }  
  
///////////////////////////////////////////////////////  
  int update()
  {
    drawBox();
    drawCircles();
    drawText();
    
    return over;
  }

///////////////////////////////////////////////////////  
  int getValue()
  {
    return over;
  }
 
///////////////////////////////////////////////////////  
  void setDebugOn()
  {
    debug=true;
  }
///////////////////////////////////////////////////////  
  void setDebugOff()
  {
    debug=false;
  }
///////////////////////////////////////////////////////  
  void printGeometry()
  {
    println("radio = new ADradio("+rX+", "+rY+", arrayOfOptions"+", \""+radioLabel+"\");");

  }
///////////////////////////////////////////////////////  
  void setExternalCircleColor(color c)
  {
    externalCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setExternalFillCircleColor(color c)
  {
    externalFillCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setInternalCircleColorr(color c)
  {
    externalFillCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setInternalFillCircleColor(color c)
  {
    externalFillCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setTextColor(color c)
  {
    textColor=c;
  }
///////////////////////////////////////////////////////  
  void setTextShadowColor(color c)
  {
    textShadowColor=c;
  }
///////////////////////////////////////////////////////  
  void setShadowOn()
  {
    textShadow=true;
  }
///////////////////////////////////////////////////////  
  void setShadowOff()
  {
    textShadow=false;
  }
///////////////////////////////////////////////////////  
  void setTextSize(int s)
  {
    textPoints=s;
  }
///////////////////////////////////////////////////////  
  void setXTextOffset(int s)
  {
    xTextOffset=s;
  }
///////////////////////////////////////////////////////  
  void setyTextSpacing(int s)
  {
    yTextSpacing=s;
  }
///////////////////////////////////////////////////////  
  void setCircleRadius(int s)
  {
    circleRadius=s;
  }
///////////////////////////////////////////////////////  
  void setBoxLineWidth(int s)
  {
    boxLineWidth=s;
  }
///////////////////////////////////////////////////////  
  void setBoxLineColor(color c)
  {
    boxLineColor=c;
  }
///////////////////////////////////////////////////////  
  void setBoxFillColor(color c)
  {
    boxFillColor=c;
    setBoxFilledOn();
  }
///////////////////////////////////////////////////////  
  void setBoxFilledOn()
  {
    boxFilled=true;
  }
///////////////////////////////////////////////////////  
  void setBoxFilledOff()
  {
    boxFilled=false;
  }
///////////////////////////////////////////////////////  
  void setBoxVisibleOn()
  {
    boxVisible=true;
  }
///////////////////////////////////////////////////////  
  void setBoxVisibleOff()
  {
    boxVisible=false;
  }
///////////////////////////////////////////////////////  
  void setLabel(String l)
  {
    radioLabel=l;
  }

}


class windRose {
  

    boolean update() {return false;}
    boolean offerMousePress() {return false;}
  
    int s;  //This value sets size of image (100)
    int r;  //This value sets number of rings (5)    
    int xini, yini;
    float[] u;
    float[] v;
    
    windRose(float[] uwind, float[] vwind, int[] pos, int rose_size, int number_rings) {
      u = uwind;
      v = vwind; 
      xini = pos[0]; yini = pos[1]; 
      s = rose_size;
      r = number_rings;
    }
 
    void drawRose() {
      
        float cw = s*0.8;
        float ch = s*0.8;
        
        //draw circular fill
        //ellipse (xini, yini, cw, ch);
   
        //change stroke and fill characteristics
        noFill ();
        stroke(100);
        strokeWeight (s/1000);
        
        //translate matrix
        pushMatrix ();
        translate (xini, yini);
              
        //draw series of circles
        for (int f = 0; f < cw*0.99; f += (cw/r)) {
           ellipse (0, 0, (cw/r) + f, (ch/r) + f);
        }
        
        
        //change stroke and fill characteristics
        stroke (0);
        strokeWeight (s/500);
    
    
        //draw cardinal lines
        for (float lc = 0; lc < TWO_PI; lc += HALF_PI) {
         rotate (lc);
         line (0,-((ch/r)/2 - (s/100)),0, -((ch/2) + (s/100)));
         rotate (-lc);
        }
    
     
        //draw cardinal letters
        textSize (s/10);
        fill(0);
        textAlign (CENTER);
        String [] cd = { "N","E","S","W" };
        int rep = 0;
        for (float lc = 0; lc < TWO_PI; lc += HALF_PI) {
          rotate (lc);
          text (cd[rep], 0, -((ch/2) + (s/60)));
          rotate (-lc); rep ++;
        }
     
     
        //draw subdivisions stroke(100);
        strokeWeight(s/1000);
        rotate (PI/16);
        for (float ls = 0; ls < TWO_PI; ls += PI/8) {
         rotate (ls);
         line (0,-(ch/2),0,-(ch/2) - (s/35));
         rotate (-ls);
        }
        rotate (-PI/16);
     
        
        //draw cardinal letters
        /*
        textSize (s/15);
        fill(100);
        textAlign (CENTER);
        String [] sd = { "","NNE","NE","ENE", "", "ESE", "SE", "SSE", "", "SSW", "SW", "WSW", "", "WNW", "NW", "NNW" };
        rep = 0;
        for (float ls = 0; ls < TWO_PI; ls += PI/8) {
         rotate (ls);
         text (sd[rep], 0, -((ch/2) + (s/90))); rotate (-ls); rep ++;
        }
        */
 
     
        //draw wind rose
        //stroke (232, 94, 2);
        stroke (0);
        strokeWeight (s/35);
        //fill (100);
        float limit = 15;
        float speed;
        float anglewind;
        for (rep = 0; rep < u.length; rep ++) {
          //line (0, 0, 0, -(wr[rep])*((ch/2)/limit)); rotate (PI/8);  
          speed = mag(u[rep],v[rep]);
          anglewind = atan2(u[rep],v[rep]);
          rotate(anglewind);
          line (0, 0, 0, -(speed*(ch/2)/limit));
          rotate(-anglewind);
        }   
        
        /*     
        //Prueba
        stroke (255, 0, 0);
        //for (float ls = PI/16; ls < TWO_PI; ls += PI/8) {
        for (float ls = -PI; ls < PI; ls += PI/8) {
         rotate (ls);
         for (rep = 0; rep < u.length; rep ++) {
          speed = mag(u[rep],v[rep]);
          anglewind = atan2(v[rep],u[rep]);
          println(ls);
          if(anglewind>=ls && anglewind<(ls+PI/8)) {
            //line (0, 0, 0, speed*(ch/2)/limit); 
            fill(180,0,0);
            if(ls<-PI/2) {
              arc(0+(speed*(ch/2)/limit)/2,0+(speed*(ch/2)/limit)/2,(speed*(ch/2)/limit),(speed*(ch/2)/limit),0,PI/8,PIE);
            } else if (ls> -PI/2 && ls <0) {
              arc(0-(speed*(ch/2)/limit)/2,0+(speed*(ch/2)/limit)/2,(speed*(ch/2)/limit),(speed*(ch/2)/limit),0,PI/8,PIE);
            } else if (ls>0 && ls <= PI/2) {  
              arc(0-(speed*(ch/2)/limit)/2,0-(speed*(ch/2)/limit)/2,(speed*(ch/2)/limit),(speed*(ch/2)/limit),0,PI/8,PIE);
          } else {
              arc(0+(speed*(ch/2)/limit)/2,0-(speed*(ch/2)/limit)/2,(speed*(ch/2)/limit),(speed*(ch/2)/limit),0,PI/8,PIE);
          }  
          }
         }   
         rotate (-ls);                 
        }
        */        
        //Final prueba

         popMatrix ();
         
         textAlign(LEFT);
         fill(0);
         textFont(f,10);
         text("Mean daily winds", 500, 300);   
     }
     
 

}





