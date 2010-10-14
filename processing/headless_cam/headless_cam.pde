import hypermedia.video.*;
import java.awt.Rectangle;
import processing.video.*;

OpenCV opencv;  //Main OpenCV variable
Capture cam;   // Connects to a camera

boolean detectBackground = true;
PImage bg, fg;

void setup() {
    size( 400, 300 );  //Larger screen sizes make it difficult to do this in real time
    cam = new Capture(this, width,height);
    bg = createImage(width,height,RGB);  // Create an image to hold the background
    fg = createImage(width,height,RGB); // Image for the foreground
    //Create the openCV buffer that's used to detect faces
    opencv = new OpenCV(this);
    opencv.allocate( width, height ); //Create a buffer for OpenCV where we can detect faces
    opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );    // load the FRONTALFACE description file
}

//Computes an enlarged version of the face box
Rectangle enlargeFaceBox (float incPct, int x, int y, int w,int h) {
    float r = dist(0,0,w,h) / 2;  //Computes radius of the center diagonal
    float theta = atan2(h,w);  //Computes the angle of the diagonal
    float dx = r*incPct*cos(theta); //Finds 
    float dy = r*incPct*sin(theta);
    return new Rectangle( (int) (x - dx), (int) (y - dy), (int) (w + 2*dx), (int) (h + 2*dy));
}

void draw() {
    cam.read();  //Pull in the image from the webcam
    if (detectBackground) {
      image( cam, 0, 0 );
      text("Step out of scene and press any key", 10,20); 
    } else {
      fg.copy(cam,0,0,width,height,0,0,width,height);  //Copy the camera image into  fg
      opencv.copy(cam);  //Copy the image into openCV's buffer   
      //Detect faces and replace them with background image
      Rectangle[] faces = opencv.detect();  // detect anything ressembling a FRONTALFACe
      bg.loadPixels();
      Rectangle faceBox = new Rectangle();  //Create a rectangle that will hold the enlarged box for the face
      for( int i=0; i<faces.length; i++ ) {
         faceBox = enlargeFaceBox(0.75, faces[i].x, faces[i].y, faces[i].width, faces[i].height);
         //Test boundaries to make sure box is still inside the visible screen area
         if (faceBox.x < 0) {faceBox.x = 0; }
         if (faceBox.x + faceBox.width > width) { faceBox.width = width - faceBox.x; }
         if (faceBox.y < 0) { faceBox.y = 0; }
         if (faceBox.y + faceBox.height >  height) { faceBox.height = height - faceBox.y; }
         //Now replace the pixels insode the faceBox with the same pixels, but this
         //time take from the origina background image.  This makes everything inside the box
         //appear to disappear.
         for (int y = faceBox.y; y < (faceBox.y + faceBox.height); y++) {
            for (int x = faceBox.x; x < (faceBox.x + faceBox.width); x++) {
              int loc = x + y * width;  //Nice little forumla from Daniel Shiffman
              fg.pixels[loc] =  bg.pixels[loc];
           }
         }
      }
      fg.updatePixels();
      image(fg,0,0);
    }
}

//Flip the mode
void keyPressed() {
  detectBackground = !detectBackground;
  //Copy the image into a background 
  bg.copy(cam,0,0,width,height,0,0,width,height);
  bg.updatePixels();
}
