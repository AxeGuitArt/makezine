void setup() {
 Serial.begin(9600);
  pinMode(9, OUTPUT); 
  
}

void loop() {
  while (Serial.available()) {
   if (Serial.read() == 'A') {
    digitalWrite(9, HIGH);
    delay(30000);
    digitalWrite(9, LOW);
    Serial.flush();
   }
  }
}
