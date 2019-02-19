import processing.serial.*;
final int AnalogVal0 = 0xE0;
final int DigitalVal0 = 0x90;
int negativeConversion = -65536;

Serial serial;  // The serial port

void setup() {
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  serial = new Serial(this, Serial.list()[0], 115200);
}


int data;
int command;
void draw() {
  if(serial.available() > 0) {
    command= serial.read();
    data= 0;
    switch(command){
      
      // Add a case for every command value you want to listen
      case AnalogVal0:
        // For first 2 MSB
        while(serial.available()==0);
        data= (serial.read())<<7;
        //For middle 7 Bits
        while(serial.available()==0);
        data= (data|serial.read())<<7;
        //For last 7 Bits
        while(serial.available()==0);
        data= (data|serial.read());
        // if the first MSB has set bit then the Val is negative
        if(data>32767) data= data| negativeConversion;
        println("AnalogVal0:"+data);
        break;

      case DigitalVal0:
        while(serial.available()==0);
        data=serial.read();
        println("DigitalVal0:"+data);
        break;
    }
  }
}
