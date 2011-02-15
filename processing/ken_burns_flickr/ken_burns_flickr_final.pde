import processing.video.*;

/*
|| Basica flow:
||   -- Read photos tagges as "Maker Faire" from flickr
||   -- Pull each photo down
||   -- Pan and zoom a la Ken burns for 1.5 seconds
||   -- record as movie using MovieMaker Library
*/

/*********************************************************
Be sure to remove these before going live!!!
*********************************************************/
String apiKey = "***** Paste  api key here ***";
String sharedSecret = "*** Paste secret here ***";

// Variables used in the flickr calls
String groupId = "69453349%40N00";  // Make group id
String tags = "faire";  //Search tag.  You can replace this with something else, but be sure to replace spaces with '+'
int numPhotos = 25;  // Number of photos to include in the movie
ArrayList photos;  //List of photos


// Variables for working w/Moviemaker
// Read docs here: 
//    http://processing.org/reference/libraries/video/MovieMaker.html
MovieMaker mm;  // Declare MovieMaker object
int FPS = 30; //Number of frames per second in move
float MIN_PAN_SECS = 2;  // Min time to display photo
float MAX_PAN_SECS = 4;  // Max time to display photo
int framesToDisplay;  //The number of frames to display based on the min and max display time
String outfileName = "maker_faire.mov";
boolean done = false;
int photosDisplayed = 0;


//Determines motion used for the Ken Burns effect -- how fast, direction, zoom, etc
int panFrameIdx = 0;  //Counter to keep up with how many frames have been written
float panX, panY; // x & y offsets for the pan
float panSpeed = 1.0;  //Speed factor
float zoom = 1;  // current zoom level
float zoomFactor = 1.005;  //How fast t

// Pan & zoom code from:
//    http://wiki.processing.org/w/Pan_a_large_image
PImage buf;
float copyOffsetX;
float copyOffsetY;
float copyWidth;
float copyHeight;



//Pulls out error codes for the given XMLElement
String[] getStatus(XMLElement xml) {
  String[] retVal = {"","",""};
  retVal[0] = xml.getStringAttribute("stat");
  if (retVal[0].equals("fail")) {
     retVal[1] = xml.getChild(0).getStringAttribute("code");
     retVal[2] = xml.getChild(0).getStringAttribute("msg");
  }
  return retVal;
}

//Pulls out the first 100 phots in the makezin flickr pool
void getPhotosByGroup(String _groupId, String _tags) {
  // Set up the call to get the Token, as described here:
  // http://www.flickr.com/services/api/auth.howto.desktop.html
  String url = "http://api.flickr.com/services/rest/?api_key="+apiKey+"&group_id="+_groupId+"&tags="+_tags+"&method=flickr.groups.pools.getPhotos&per_page="+numPhotos;
  String[] results = loadStrings(url); //Load the URL
  XMLElement xml = new XMLElement(join(results,"\n")); //Collapse array elements into a string
  String[] errCodes = getStatus(xml);  //Pull error codes (if any) from the XML
  if (errCodes[0].equals("ok")) {  
     XMLElement root = xml.getChild(0);
     for (int i=0; i < root.getChildCount(); i++) {
        String id = root.getChild(i).getStringAttribute("id");
        String owner = root.getChild(i).getStringAttribute("owner");
        String title = root.getChild(i).getStringAttribute("title");
        photos.add( new Photo(id, title, owner));
     }
  } else {
    println ("Error! Here are some codes:\n" + errCodes);
  }
}  

/*
|| Flickr stores multiple sizes for an image.  So, to get the URL for one, we need to 
|| scan through an pic out the size we want.  In this case, "Medium"
*/
String getPhotoURL(String id) {
  String retVal = "";
  String url = "http://api.flickr.com/services/rest/?api_key="+apiKey+"&photo_id="+id+"&method=flickr.photos.getSizes";
  String[] results = loadStrings(url); //Load the URL
  XMLElement xml = new XMLElement(join(results,"\n")); //Collapse array elements into a string
  String[] errCodes = getStatus(xml);  //Pull error codes (if any) from the XML
  if (errCodes[0].equals("ok")) {  
     XMLElement root = xml.getChild(0);
     for (int i=0; i < root.getChildCount(); i++) {
        String label = root.getChild(i).getStringAttribute("label");
        if (label.equals("Medium 640")) {
           retVal = root.getChild(i).getStringAttribute("source");
        }
     }
  } else {
    println ("Error! Here are some codes:\n" + errCodes);
  }
  return retVal;
}  



void setup() {
  size (480, 360);
  mm = new MovieMaker(this, width, height, outfileName,  FPS, MovieMaker.H263, MovieMaker.BEST);
  photos = new ArrayList();
  getPhotosByGroup(groupId, tags);
  for (int i=0; i < photos.size(); i++) {
    Photo p = (Photo) photos.get(i);
    p.url = getPhotoURL(p.id);
    println(p.title + " -> " + p.url);
  }
  Photo p = (Photo) photos.get(0);
  buf = loadImage(p.url);
  resetPanAndZoom();
}

// Copies the "panned" portion of the image that will be displayed
PImage getBufSlice() {
  return buf.get((int) copyOffsetX, (int) copyOffsetY, (int) copyWidth, (int) copyHeight);
}


// Resets all the pan and zoom information to a new random direction
void resetPanAndZoom() {
  
  framesToDisplay = (int) (FPS * random(MIN_PAN_SECS, MAX_PAN_SECS));
  //Center the offset window over the center of the image
  copyOffsetX = (int) (abs(buf.width - width) / 2.0);
  copyOffsetY = (int) (abs(buf.height - height) / 2.0);
  copyWidth = width;
  copyHeight = height;
  // Select a new  direction to pan
  float angle = radians(random(-45,45));
  float direction = 1.0;
  if (random(10) > 5) {
    direction = -1.0;
  }
  panX = direction * panSpeed * cos(angle);
  panY = panSpeed * sin(angle);
  // Reset zoom
  zoom = 1.0;
}

  
void draw() {
  background(0);
  if (!done) {
     Photo p = (Photo) photos.get(photosDisplayed);
     //Display the image
     pushMatrix();
     scale(zoom);
     image(getBufSlice(),0,0);
     popMatrix();
     // Display text label
     fill(204);
     stroke(204);
     rect(0,320,width, 20);
     fill(0);
     text(p.title + " by " + p.owner, 20, 335);
     // Update the panning and zooming variables
     zoom *= zoomFactor;
     copyOffsetX += panX;
     copyOffsetY += panY;
     panFrameIdx += 1;
     // Check if we've panned and zoomed on this image long enough
     if (panFrameIdx > framesToDisplay) {
        panFrameIdx = 0;
        resetPanAndZoom();
        photosDisplayed += 1;
        if (photosDisplayed < photos.size()) {
           p = (Photo) photos.get(photosDisplayed);
           buf = loadImage(p.url);
        }
      }
      mm.addFrame(); //Save the frame in the movie file
      // Now test if we've displayed all the images and quit if so
      if ( photosDisplayed == photos.size()) {
         mm.finish();  // Finish the movie if space bar is pressed!
         done = true;
      } 
  } else {
     //Indicate that we're all done
     fill(255);
     text("All done!", 10,10);
  }
}


/*
|| Class to hold the photo info from the XML
*/
class Photo {
  String id, title, owner;
  String url;
  
  Photo (String _id, String _title, String _owner) {
    id = _id;
    title = _title;
    owner = _owner;
  }
  
}
