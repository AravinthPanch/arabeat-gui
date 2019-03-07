/*
This file contains the function which reads the Byte serial and converts into command
 and Data.Then using this data plot the Graph.
 */
import processing.serial.*;
Serial serial;

final int ECG_ANALOG_VOLTAGE = 0xE0;
final int RTOR_IN_MS = 0xE1;
final int RTOR_INTERRUPT_PULSE = 0xE2;
final int HANDS_ON_COUNT = 0xE3;
final int HANDS_OFF_COUNT = 0xE4;
final int SAMPLE_COUNT = 0xE5;
final int HANDS_ON_COUNT_THRESHOLD = 0xE6;
final int HANDS_OFF_COUNT_THRESHOLD = 0xE7;
final int STABLE_RTOR_STATUS = 0xE8;
final int HEART_PULSE = 0x90;
final int HANDS_ON = 0x91;

int baudrate= 115200;
String portName;
int negativeConversion = -65536;
int data;
int command;


/*
Read and parse two bytes data
 */
int read_two_bytes_data()
{
  int result = 0;

  // For first 2 MSB
  while (serial.available()==0) {
    delay(1);
  }
  result= (serial.read())<<7;

  //For middle 7 Bits
  while (serial.available()==0) {
    delay(1);
  }
  result= (result|serial.read())<<7;

  //For last 7 Bits
  while (serial.available()==0) {
    delay(1);
  }
  result= (result|serial.read());

  return result;
}


/*
Reads the Serial using MIDI and Firmat Protocol
 and calls the Plot function according the data
 Detailed Explanation in the README.md
 */
void serialMIDIRead() {
  command= serial.read();
  data= 0;
  switch(command) {

  case ECG_ANALOG_VOLTAGE:
    data = read_two_bytes_data();

    // if the first MSB has set bit then the Val is negative
    if (data>32767) data= data| negativeConversion;

    set_ecg_analog_voltage_data(data);
    break;

  case HEART_PULSE:
    while (serial.available()==0) {
      delay(1);
    }
    data=serial.read();
    set_heart_pulse_data(data);
    break;

  case RTOR_IN_MS:
    data = read_two_bytes_data();
    set_rtor_in_ms_data(data);
    break;

  case HANDS_ON:
    while (serial.available()==0) {
      delay(1);
    }
    data=serial.read();
    set_hands_on_data(data);
    break;

  case RTOR_INTERRUPT_PULSE:
    data = read_two_bytes_data();
    set_RTOR_interrupt_pulse_data(data);
    break;

  case HANDS_ON_COUNT:
    data = read_two_bytes_data();
    set_hands_on_count_data(data);
    break;

  case HANDS_OFF_COUNT:
    data = read_two_bytes_data();
    set_hands_off_count_data(data);
    break;

  case SAMPLE_COUNT:
    data = read_two_bytes_data();
    set_sample_count_data(data);
    break;

  case HANDS_ON_COUNT_THRESHOLD:
    data = read_two_bytes_data();
    set_hands_on_count_threshold_data(data);
    break;

  case HANDS_OFF_COUNT_THRESHOLD:
    data = read_two_bytes_data();
    set_hands_off_count_threshold_data(data);
    break;

  case STABLE_RTOR_STATUS:
    data = read_two_bytes_data();
    set_stable_rtor_status_data(data);
    break;
  }
}
