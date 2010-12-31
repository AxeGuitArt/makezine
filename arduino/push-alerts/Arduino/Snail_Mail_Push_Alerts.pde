/*
  Snail Mail Push Alerts by Matt Richardson
  Adapted from the Arduino WebClient example by David A. Mellis
  
  This sketch is part of a project which sends a push alert to your
  iPhone when your snail mail is delivered.
  This sketch requests a URL when a mailbox has been opened.
  The URL is a PHP script based on the ProwlPHP class.
  
  December 31, 2010
 */

#include <SPI.h>
#include <Ethernet.h>

#define switchPin 7  // Snap action switch which closes when the mailbox door is opened.

byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10,0,1,1 }; // local Arduino IP
byte server[] = { 1,1,1,1 }; // IP of your web server

Client client(server, 80);

void setup() {
  Ethernet.begin(mac, ip);
  Serial.begin(9600);
  delay(1000);
  pinMode(switchPin, INPUT);
}

void loop()
{
  if (digitalRead(switchPin) == HIGH) // if mailbox is opened:
  {
      Serial.println("Mailbox door opened");
    if (client.connect()) { //connect to server
      Serial.println("connected to server");
      // Make a HTTP request:
      client.println("GET /path/to/example.php"); //location of ProwlPHP script
      client.println();
    } 
    else {
      Serial.println("connection failed");
    }
    delay(1000);
    Serial.print("Response from server: ");
    while (client.available()) {
      char c = client.read();
      Serial.print(c);
    }
  
    // if the server's disconnected, stop the client:
    if (!client.connected()) {
      Serial.println("disconnecting from server");
      client.stop();
    }
    while (digitalRead(switchPin) == HIGH)
    {
      // hold here until mailbox is closed again.
    }
    Serial.println("Mailbox door closed");
    delay(500);
  }
}

