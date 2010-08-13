import processing.video.*;

Capture cam;

int colorDist = 50;  //Controls how close the current pixel color must match to the target color
color targetColor =  color(255,255,255);   //Color of the target
boolean acquireMode = false;  // Flag that indicates if we're supposed to be setting the new target color

//Controls the size of the target box
int targetX = 10;
int targetY = 25;
int targetSide = 10;

//Used to find the geometric center of the target based on an average
int numPoints = 0;
int sx = 0;
int sy = 0;


void setup() {
  size (320, 240);
  cam = new Capture(this, width, height);
  frameRate(60);
}

// Finds the average target color that has been placed in the target box
// Loops through each pixel in the target acquisition area and determines 
// the "average" color
color fetchTargetColor() {
   int r = 0;
   int g = 0;
   int b = 0;
   int cnt = 0;
   for (int i = 0; i < targetSide; i++) {
      for (int j=0; j < targetSide; j++) {
        cnt += 1;
        int x = targetX + i;  //x point inside the target box
        int y = targetY + j;  //y point inside the target box
        // Pull out the current pixel color
        color c = cam.pixels[y*width + x];
        r += red(c);
        g += green(c);
        b += blue(c);
      }
   }
   targetColor = color(r/cnt, g/cnt, b/cnt);
   return targetColor;
}

//Acquire the target color.  Searches each pixel in the entire image
// and compares it to the target color.  If the distance is less than the 
// threshold colorDist, it's assummed to be a match
void acquireTarget() {
  numPoints = 0;  //Number of points found
  sx = 0;  //Sum of all x coordinates found
  sy = 0;  //Sum of all the y coordinates found
  for (int i=0; i < width; i++) {
    for (int j=0; j < height; j++) {
      color pix = cam.pixels[j*width + i]; //Grab pixel at i,j
      float dr = red(targetColor) - red(pix);
      float dg = green(targetColor) - green(pix);
      float db = blue(targetColor) - blue(pix);
      float d = sqrt ( pow(dr,2) + pow(dg,2) + pow(db,2));
      // If it's a match, then keep a running total
      if (d < colorDist) {
         numPoints += 1;
         sx += i;
         sy += j;
      }
    }
  }
}

void draw() {
   if (cam.available()) {
      cam.read();     
      // This is a nify little trick from Processing guru Daniel Shiffman to make
      // viewing yourself on a webcam much more natural that viewing the raw image
      // Where your right is the image's left, and so forth
      pushMatrix();
      scale(-1.0, 1.0);
      image(cam,-cam.width,0);
      popMatrix();
      image(cam,0,0);
   }
   //Display the current target color
   fill(targetColor);
   rect(targetX,targetY - 2 * targetSide,targetSide, targetSide);      
   //Display the acqisition target here
   if (!acquireMode) {
      fill(color(255,255,255));
      rect(targetX,targetY,targetSide, targetSide);
      textSize(10);
      text("Place target in square and press 'a' when done.", targetX + 1.5 * targetSide,targetY + targetSide);
      targetColor = fetchTargetColor();
   }  else {
      acquireTarget();
      if (numPoints >  5) {
         createGradient(sx/numPoints, sy/numPoints, 30.0,
        color(int(random(255)), int(random(255)), int(random(255))),
        color(int(random(255)), int(random(255)), int(random(255))) );
      }
   }      
}

//Toggle the acquire mode
void keyPressed() {
   acquireMode = !acquireMode;
}


//This is based on Ira Greenberg's  nifty radial gradient example at:
// http://processing.org/learning/basics/radialgradient.html
//
void createGradient (float x, float y, float radius, color c1, color c2){
  float px = 0, py = 0, angle = 0;

  // calculate differences between color components 
  float deltaR = red(c2)-red(c1);
  float deltaG = green(c2)-green(c1);
  float deltaB = blue(c2)-blue(c1);
  // hack to ensure there are no holes in gradient
  // needs to be increased, as radius increases
  float gapFiller = 8.0;

  for (int i=0; i< radius; i++){
    for (float j=0; j<360; j+=1.0/gapFiller){
      px = x+cos(radians(angle))*i;
      py = y+sin(radians(angle))*i;
      angle+=1.0/gapFiller;
      color c = color(
      (red(c1)+(i)*(deltaR/radius)),
      (green(c1)+(i)*(deltaG/radius)),
      (blue(c1)+(i)*(deltaB/radius)) 
        );
      set(int(px), int(py), c);      
    }
  }
  // adds smooth edge 
  // hack anti-aliasing
  noFill();
  smooth();
  noStroke();
  ellipse(x, y, radius*2, radius*2);
}

