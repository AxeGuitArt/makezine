/*
 Loney Christmas Tree - YouTube Comment Mode
 
 Circuit:
 * Ethernet shield attached to pins 10, 11, 12, 13
 * PowerTailSwitch attached to pin 9
 
 Created December 8, 2011
 
 Based on the WebClient example by David A. Mellis,
 modified by Tom Igoe, based on work by Adrian McEwen.
 
 */


#include <SPI.h>
#include <Ethernet.h>

int relayPin = 9;
char Str[11];
int prevNum = 0;
int num = 0;
long onUntil = 0;

long pollingInterval = 20000; // in milliseconds
long onTime = 60000; // time, in milliseconds, for lights to be on after new email or comment

// Enter a MAC address for your controller below.
// Newer Ethernet shields have a MAC address printed on a sticker on the shield
byte mac[] = {  0x00, 0xAA, 0xBB, 0xCC, 0xDE, 0x02 };
char serverName[] = "server.com";

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
EthernetClient client;

void setup() {
  Serial.begin(9600);
  pinMode(relayPin, OUTPUT);
  // start the Ethernet connection:
  if (Ethernet.begin(mac) == 0) {
    Serial.println("Failed to configure Ethernet using DHCP");
    // no point in carrying on, so do nothing forevermore:
    while(true);
  }
  // give the Ethernet shield time to initialize:
  delay(2000);

}

void loop()
{
    Serial.println("connecting...");

  // if you get a connection, report back via serial:
  
  if (client.connect(serverName, 80)) {
    Serial.println("connected");
    // Make a HTTP request:
    client.println("GET /path/to/yt.php");
    client.println();
    int timer = millis();
    delay(1000);
  } 
  else {
    // if you didn't get a connection to the server:
    Serial.println("connection failed");
    
  }

	// if there's data ready to be read:
  if (client.available()) {
     int i = 0;
     
     //put the data in the array:
     do {
       Str[i] = client.read();
       i++;
       delay(1);
     } while (client.available());
     
     // Pop on the null terminator:
     Str[i] = '\0';
     //convert server's repsonse to a int so we can evaluate it
     num = atoi(Str); 
     
     Serial.print("Server's response: ");
     Serial.println(num);
     Serial.print("Previous response: ");
     Serial.println(prevNum);
     if (prevNum < 0)
     { //the first time around, set the previous count to the current count
      prevNum = num; 
      Serial.println("First comment count stored.");
     }
     if (prevNum > num)
     { // handle if count goes down for some reason
      prevNum = num; 
     }
  }
  else
    {
     Serial.println("No response from server."); 
    }
    Serial.println("Disconnecting.");
    client.stop();
    if(num > prevNum) {
      Serial.println("New Comment.");
      digitalWrite(relayPin, HIGH);
      prevNum = num;
      onUntil = millis() + onTime;
    }
    else if(millis() > onUntil)
    {
     digitalWrite(relayPin, LOW); 
    }
  delay(pollingInterval);
}

