MIDI
====
[Source](https://www.midi.org/specifications/item/table-1-summary-of-midi-message)  

Every midi message is 1 byte long  
Two types of midi messages: Command and Data  
* Command Message always starts with a set bit (ie: 1xxxxxxx)
* Data Message always starts with a clear bit (ie: 0xxxxxxx)  
* Eg: 
    1) for key press stopped
        Command=> 1000nnnn (n is for channel)  
        Data=> 0kkkkkkk 0vvvvvvv (k is key and v is velocity)  
    2) Command 11111111 to power off
    3) Command 11110000 system exclusive designed by manufactures  
        Data 0iiiiiii all the i bit cant be set my the manufactures (eg: Specific MIDI info)

####Firmata

[Source](http://firmata.org/wiki/Protocol)

Firmata is a protocol for communicating with microcontrollers from software on a computer (or smartphone/tablet, etc).   
Firmata is based on the midi message format in that commands bytes are 8 bits and data bytes are 7 bits.  

Eg:

1) Analog I/O Message    
    Command=> 0xE0(1110nnnn)
    Data=> 0jjjjjjj 0kkkkkkk (j=>7 LSB and k=>7 MSB)  
    Originally this command is Used in midi for Pich Blend Change  


###Protocol for AraBeat 

* To send analog values  
    - Comand Byte=> 0xE0-0xEF(1110nnnn) (n will be data id known by both sender and reciever)  
    - Data Byte 1=> 0jjjjjjj (j is the first 7 MSB)  
      Data Byte 2=> 0kkkkkkk (k is the last 7 LSB)  
      Data Byte 3=> 0lllllll (only used if the data is bigger than 14bits)    
    - The command is very similar to how firmata sends Analog values,   originally this message means a pitch bend in the MIDI

* To send digital values  
    - Command Byte=> 0x90-0x9F
    - Data Byte=>  0x01(ON)/ 0x00(OFF)s
    - The command is very similar to how firmata sends Digital values,   originally this message means a key pressed in the MIDI
    - If more than one analog values has to be sent then Bitmask could be  
      used in the data byte 
      Eg: D4=>1 D3=>1 D2=>0 D1=>1: 00001101

       
* This protocol is compatible with general MIDI as well as the FIRMATA protocol 


