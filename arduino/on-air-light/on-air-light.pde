// Arduino Code for "On Air" Light
// Be sure to enter your Ustream API key into appropriate line below.
// Requires XBee Internet Gateway


const int relayPin = 12;
String response;
char c;

void setup () {
 pinMode(relayPin, OUTPUT); 
 Serial.begin(115200);
 delay(5000);
}

void loop() {
  Serial.println("http://api.ustream.tv/json/channel/make-live/getValueOf/status?key=USTREAM_API_HERE!");
  delay(3000);
  if (Serial.available() > 0) //If there is at least one char in the serial buffer
    {
      do {
        c=Serial.read(); // read a char from the serial buffer
        response += c; // append that char to the string response
      } while (Serial.available() > 0); // until there are no more chars in the buffer
    if (response.indexOf("live") > 0) // search the string for the substring "live" (will evaluate as -1 if not found)
        digitalWrite(relayPin, HIGH); // if "live" is found in response, turn on the light
    else if (response.indexOf("offline") > 0) //search the string for the substring "offline" (will evaluate as -1 if not found)
      digitalWrite(relayPin, LOW); // if "offline" is found in response, turn off the light
    response = ' ';
  Serial.flush();
    }
}
