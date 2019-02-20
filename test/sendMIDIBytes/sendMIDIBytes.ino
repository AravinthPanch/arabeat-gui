/*
 * Sending random MIDI for AraBeat Testing   
 * 
 * 0010111011011010 => 11994
 * 1011010 =>90
 * 
 */
#define AnalogVal0 0xE0
#define DigitalVal0 0x90
#define DigitalON 0x00
#define DigitalOFF 0X01

#define AnalogValueSize 32

void setup() {
  //  Set MIDI baud rate:
 // Serial.begin(31250);
 Serial.begin(115200);
}



void loop() {
  MidiMessage(AnalogVal0, random(-1000000,100000));
  MidiMessage(DigitalVal0, random(200)%2);
  delay(10);
}

//send MIDI message
void MidiMessage(int command,unsigned int val) {
  // the val is intentionally made unsigned to perform bit operations  
  
  //Send Command Byte
  Serial.write(command);
  
  if(command>= 0xE0 && command <=0xEF){
    //the Bit operations are designed assuming that the size of Int is 16 bits
    // Returns the first 2 bits (MSB)
    Serial.write(val>>14);
    // Returns the next 7 bits
    Serial.write((val<<2)>>9);
    // Returns the last 7 bits (LSB)
    Serial.write((val<<9)>>9);
  }
  else{
    // For Digital values either return 0 or 1
    Serial.write(val); 
  }
}
