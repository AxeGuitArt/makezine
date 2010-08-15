import processing.video.*;

Capture cam;

//Variables to control the appearance of the wand when it is actire
int oldTime;
int wandFrequency = 500;   //howlong it takes the rays to emanate from the tip
color wandColor = color(204);  //The color of the magic rays that emnate from the wand

// Variables to determine the size of the box used to acquire a target
int colorDist = 50;  //Controls how close the current pixel color must match to the target color
color targetColor =  color(255,255,255);   //Color of the target
boolean acquireMode = false;
int targetX = 10;
int targetY = 25;
int targetSide = 10;

//Used to find the geometric center of the target based on an average
float wandX = 0;
float wandY = 0;
boolean wandFound = false;

//Color circle.  Moving the wand into this circle will change the color of the magic rays
//This is basically example 5-16 from "Getting Started with Processing"
int cX = 35;
int cY = 50;
int cR = 30;
int colorCircleColor = color(0);
int colorCircleFrequency = 500;  //Determines how often a new random color appears
int colorCircleMillis = 0; 

void setup() {
  size (320, 240);
  cam = new Capture(this, width, height);
  frameRate(60);
  oldTime = millis();
  colorCircleMillis = millis();
}

// Finds the average target color that has been placed in the target box
// Loops through each pixel in the target acquisition area and determines 
// the "average" color
color acquireTargetColor() {
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

//Searches for the target color.  Searches each pixel in the entire image
// and compares it to the target color.  If the distance is less than the 
// threshold colorDist, it's assummed to be a match
void searchForTargetColor() {
  // Reset wand
  wandX = 0;
  wandY = 0;
  wandFound = false;
  //Now search for pixels that match the target color
  int numPoints = 0;  //Number of points found
  int sx = 0;  //Sum of all x coordinates found
  int sy = 0;  //Sum of all the y coordinates found
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
  // If we found the target color, set the wand coordinates
  if (numPoints > 0) {
    wandX = sx / numPoints;
    wandY = sy / numPoints;
    wandFound = true;
  }
}


//Sets a random color for the wand if it is inside the control circle
void testControlBounds() {
  float d = dist(wandX,wandY,cX, cY);
  if (d < cR) {
    wandColor = colorCircleColor;
  }
}


//Sets the color circle to some new random color
void setColorCircleColor() {
  int elapsedTime = millis() - colorCircleMillis;
  if (elapsedTime > colorCircleFrequency) {
      colorCircleMillis = millis();
      colorCircleColor = color(int(random(255)), int(random(255)), int(random(255)));  //Random color for the start

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
   strokeWeight(1);
   fill(targetColor);
   rect(targetX,targetY - 2 * targetSide,targetSide, targetSide);      
   //Display the acqisition target here
   if (!acquireMode) {
      fill(color(255,255,255));
      rect(targetX,targetY,targetSide, targetSide);
      textSize(10);
      text("Place target in square and press any key when done.", targetX + 1.5 * targetSide,targetY + targetSide);
      // Set a new random color gradient
      targetColor = acquireTargetColor();
   }  else {
      setColorCircleColor();
      fill(colorCircleColor);
      ellipse(cX,cY,cR,cR);
      searchForTargetColor();
      if (wandFound) {
         testControlBounds();
         drawWand(12,50);
      }
   }      
}

//Draws an animated wand with N lines radiating R pixels out from a central point
void drawWand(int N, int R) {
   strokeWeight(6);
   stroke(wandColor);
   smooth();
   int elapsedTime = millis() - oldTime;
   float r = map(elapsedTime, 0, wandFrequency, 0, R);
   for (int i=0; i < N; i++) {
      float step = radians(360.0 / N);
      float dx = r * sin(i*step) + wandX;
      float dy = r * cos(i*step) + wandY;
      line(wandX + 10*sin(i*step),wandY+10*cos(i*step),dx,dy);
   }
   if (elapsedTime > wandFrequency) {
     oldTime = millis();
   }
}
  

//Toggle the acquire mode
void keyPressed() {
   acquireMode = !acquireMode;
}
