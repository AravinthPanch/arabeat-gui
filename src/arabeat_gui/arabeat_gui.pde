/*
This code was built with Processing 3.5.3

This is the Main Sketch for the GUI and main Setup and Draw is initialized here

Depedencies
-----------
Grafica 1.9.0
ControlP5 2.2.6
Processing.Serial *

*/



/*
The time for the y-axis of analog value graph
*/
int relativeTime= 0;

void setup()
{
  size(1280,800);
  setupGUI();
  background(255);
}

void draw()
{
  //To Refresh the Background'
  background(255);
  if(isPortChoosen){
    while ( serial.available() > 0) {
     serialMIDIRead();
    }
  }
 GUIDraw();
}
