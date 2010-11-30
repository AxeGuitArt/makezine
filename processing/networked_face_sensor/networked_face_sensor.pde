import hypermedia.video.*;
import java.awt.Rectangle;
import processing.video.*;
import java.net.URLEncoder;
import controlP5.*;  



OpenCV opencv;  // OpenCV object
Capture cam;
ControlP5 controlP5;  //ControlP% object


// Controls how often the image is scanned for faces
int interval = 2000;  //number of miliseconds between photos
int MIN_INTERVAL = 500;
int MAX_INTERVAL = 3000;


String transmission_url = "http://MacOdewahn.home/~odewahn/face_sensor/record.php";
int oldTime = 0; //Current interval


//Encodes a parameter to use in a query string
String encode (String name, String value) {
   String retVal = "";
   try {
      retVal = name + "=" + URLEncoder.encode(value, "UTF-8"); 
    } catch (UnsupportedEncodingException ex) {
      throw new RuntimeException("UTF not supported");
    }
    return retVal;
}     
   
//Sends the info off to the website
public void transmit(int fc) {
  String qry = "";
  String url = "";
  qry += "face_count=" + fc + "&";
  qry += "interval=" + interval + "&";
  qry += encode("room_name", ((Textfield)controlP5.controller("roomName")).getText()) + "&";
  url = transmission_url + "?" + qry;
  String[] saveRec = loadStrings(url);
}


void setup() {
    size( 600, 450 );
    frameRate(32);

    //Set up other drawing context
    oldTime = millis();  //Save the current time
    // Set up the camera
    cam = new Capture(this, 600,450);
    cam.settings(); //Allows you to pick other cameras than just the webcam
    opencv = new OpenCV(this);  //Create a new CV object
    opencv.allocate( width, height );  //Allocate space in the buffer to hold the image data
    opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT  );    // load the FRONTALFACE description file
    //Add the control
    controlP5 = new ControlP5(this);
    controlP5.addTextfield("roomName", 50, 100, 100,20);

}

//Based on code from http://ubaa.net/shared/processing/opencv/opencv_detect.html
void draw() {
    cam.read();  //Read an image from the selected camera
    opencv.copy(cam);  //Copy the image into openCV's buffer    
    image( opencv.image(), 0, 0 );
    //Take a snapshot at the interval specified and count the faces 
    int passedTime = millis() - oldTime;
    if (passedTime > interval) {
       oldTime = millis();
       // detect anything ressembling a FRONTALFACE
       Rectangle[] faces = opencv.detect();
       transmit(faces.length);
       // draw detected face area(s)
       noFill();
       stroke(255,0,0);
       for( int i=0; i<faces.length; i++ ) {
           rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height ); 
       }
       transmit(faces.length);
    }
}
