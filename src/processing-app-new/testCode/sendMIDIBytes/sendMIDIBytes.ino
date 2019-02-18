/*
 * Sending random MIDI for AraBeat Testing   
 */

#define AnalogVal0 0xE0
#define DigitalVal0 0x90
#define TestByte 0x7B


void setup() {
  //  Set MIDI baud rate:
 // Serial.begin(31250);
 Serial.begin(115200);
}

void loop() {
  MidiMessage(TestByte, 45);
  delay(1000);
}

//send MIDI message
void MidiMessage(int command, int val) {
  Serial.write(command);//Send Command Byte 
  Serial.write(val);//Send Value Byte
}
