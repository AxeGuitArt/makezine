class Target {
  
  float x, y, dx, dy;
  float w, h;  //Width and height of the box
  Boolean inTarget = false;
  int fontSize = 48;
  String currentText, beforeText, afterText;
  
  // Constructor -- called when the object is created with "new"
  Target(String _beforeText, String _afterText) { 
     beforeText = _beforeText;
     afterText = _afterText;
     currentText = _beforeText;
     x = random(0,width);
     y = random(0,height);
     dx = random(-5,5);
     dy = random(-5,5);
     setBox();
  }
  
  //Advances the object to a new position
  // This is discussed in Chapter 7
  void step() {
    x += dx;
    y += dy;
  }
  
  //Determines if the object is still on the stage
  Boolean onStage() {
    Boolean retVal = false;
    if (((x+w) > 0) && (x < width) && (y > 0) && ((y-h) < height)) {
        retVal = true;
    }
    return retVal;
  }
  
  //Sete the height and width of the bounding text box
  void setBox() {
     h = fontSize;
     textFont(font, fontSize);
     w = textWidth(currentText);
  }
  
  //Determines is a particular x,y coordinate is within the box
  boolean detectCollision(float cx, float cy) {
     boolean retVal = false;
     if ( (cx > x) && (cx < (x+w)) && (cy > (y-h)) && (cy < y)) {
        retVal= true;
     }
     return retVal;
  }
  
  //Toggles the state of the 
  void toggle() {
     if (currentText == beforeText) {
        currentText = afterText;
     } else {
       currentText = beforeText;
     }
     setBox();
  }
  
  //Displays the text at x,y
  void paint() {
    fill(255);
    textFont(font,fontSize);
    textSize(fontSize);
    text(currentText,x,y);
  }
    
  
}
