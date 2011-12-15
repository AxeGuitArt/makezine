/*

 Just a quick program to read the IRC chat
 log of Make: Live and send an 'A' over serial
 to the Arduino when a holiday word is caught in the chat.
 
 There's a symbolic link from the IRC's chat log to this
 sketch's data folder.
 
 By Matt Richardson

*/


import processing.serial.*;
Serial myPort;       

String[] lines;
int index = 0;
int interval = 1000;
int nextCheck = 0;
int numLines;
int newNumLines;



void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  lines = loadStrings("2011-12-14.txt");
  numLines = lines.length;
  newNumLines = lines.length;
  nextCheck = millis() + interval;
  myPort = new Serial(this, Serial.list()[0], 9600);
}

void draw() {
  if(millis() > nextCheck) {
    println("Checking.");
    lines = loadStrings("2011-12-14.txt");
    newNumLines = lines.length;
    if (newNumLines > numLines)
    {
      print(newNumLines - numLines);
      println(" new log lines ready to read.");
      for (int i = numLines; i < newNumLines; i++) {
        String checkString = lines[i].toUpperCase();
        if(
            (checkString.indexOf("MERRY") != -1) ||
            (checkString.indexOf("CHRISTMAS") != -1) ||
            (checkString.indexOf("SANTA") != -1) ||
            (checkString.indexOf("XMAS") != -1) ||
            (checkString.indexOf("HOLIDAY") != -1) ||
            (checkString.indexOf("CHEER") != -1) ||
            (checkString.indexOf("JOY") != -1) ||
            (checkString.indexOf("TREE") != -1) ||
            (checkString.indexOf("GLAD") != -1)
          )
          {
            println("Caught a holiday word. Sending serial command.");
            myPort.write(65);
          }
      }
    }
    nextCheck = millis() + interval;
    numLines = newNumLines;
    
  }
  
}
