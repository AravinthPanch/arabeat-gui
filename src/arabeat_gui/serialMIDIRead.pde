/*
This file contains the function which reads the Byte serial and converts into command
 and Data.Then using this data plot the Graph.
 */
import processing.serial.*;
Serial serial;

final int ECG_ANALOG_VOLTAGE = 0xE0;
final int HEART_PULSE = 0x90;
final int R2R_IN_MS = 0xE1; 

int baudrate= 115200;
String portName;
int negativeConversion = -65536;
int data;
int command;

/*
Reads the Serial using MIDI and Firmat Protocol
 and calls the Plot function according the data
 Detailed Explanation in the README.md
 */
void serialMIDIRead() {
  command= serial.read();
  data= 0;
  switch(command) {

    // Add a case for every command value you want to listen
  case ECG_ANALOG_VOLTAGE:
    // For first 2 MSB
    while (serial.available()==0) {
      delay(1);
    }
    data= (serial.read())<<7;
    //For middle 7 Bits
    while (serial.available()==0) {
      delay(1);
    }
    data= (data|serial.read())<<7;
    //For last 7 Bits
    while (serial.available()==0) {
      delay(1);
    }
    data= (data|serial.read());
    // if the first MSB has set bit then the Val is negative
    if (data>32767) data= data| negativeConversion;
    graph1Plot(data);
    break;

  case HEART_PULSE:
    while (serial.available()==0) {
      delay(1);
    }
    data=serial.read();
    set_heart_pulse(data);
    break;

  case R2R_IN_MS:
    // For first 2 MSB
    while (serial.available()==0) {
      delay(1);
    }
    data= (serial.read())<<7;
    //For middle 7 Bits
    while (serial.available()==0) {
      delay(1);
    }
    data= (data|serial.read())<<7;
    //For last 7 Bits
    while (serial.available()==0) {
      delay(1);
    }
    data= (data|serial.read());    
    set_R2R_in_ms(data);
    break;
  }
}
