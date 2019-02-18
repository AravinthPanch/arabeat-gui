// Randomly Generate OSC Values

/*
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

void loop() {

  Serial.println(random(10000)-5000);
  delay(10);        // delay in between reads for stability


}*/



/*

code written in Arduno 1.8.8

Dependencies  
[OSCMessage](https://www.arduinolibraries.info/libraries/osc)

The below code creates random OSC messages over serial for testing the GUI for arabeat.
*/

#include <OSCMessage.h>

#ifdef BOARD_HAS_USB_SERIAL
#include <SLIPEncodedUSBSerial.h>
SLIPEncodedUSBSerial SLIPSerial( thisBoardsSerialUSB );
#else
#include <SLIPEncodedSerial.h>
 SLIPEncodedSerial SLIPSerial(Serial);
#endif


// Randomly Generate OSC Values
void setup() {
  // initialize serial communication at 9600 bits per second:
  SLIPSerial.begin(9600);   
  #if ARDUINO >= 100
  while(!Serial);
  #endif

}

void loop() {
  
  OSCMessage msg("/frequency");
  msg.add((String)(random(10000)-5000));
  msg.add((String)random(255));
  
  SLIPSerial.beginPacket();  
    msg.send(SLIPSerial); // send the bytes to the SLIP stream
  SLIPSerial.endPacket(); // mark the end of the OSC Packet
  msg.empty(); // free space occupied by message
  delay(1000);       
}
