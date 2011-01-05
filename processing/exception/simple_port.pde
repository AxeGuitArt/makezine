import processing.serial.*;

Serial port;  // Create object from Serial class


//Used for the timer variables
int oldTime;  //timer variable
int reportingInterval = 1000;  //Number of miliiseconds between when sensor data is recorded

int idx = 0;  // Index that counts the number of reporting periods that have elapsed
float val = 0.0;  // The value read from the port


void setup() {
  //Set up the serial port to read data
  //This code comes from example 11-8 of Getting Started with Processing
  size(200,100);
  textFont(createFont("",12),12);
  println(Serial.list());
  String arduinoPort = Serial.list()[0];
  port = new Serial(this, arduinoPort, 9600);
}

// Reads the port
void readPort() {
  val = 0.0;
  if (port.available() > 0) { // If data is available,
    val = port.read();        // read it and store it in val
  }
  //Determine if we need to report the level
  if ((millis() - oldTime) > reportingInterval) {
    oldTime = millis();
    idx += 1;
  }      
}

void draw() {
  background(0);
  text(idx + ": " + val, width/2, height/2);
  readPort();
}



