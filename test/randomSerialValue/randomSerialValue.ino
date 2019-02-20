/*
* Generate Random Serial Values
*/


void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

void loop() {

  Serial.println(random(10000)-5000);
  delay(10);        // delay in between reads for stability


}