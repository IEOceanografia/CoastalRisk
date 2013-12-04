
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




