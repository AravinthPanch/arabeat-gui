/*
This code was built with Processing 3.5.3

Depedencies
-----------
Grafica 1.9.0
ControlP5 2.2.6
Processing.Serial *

*/




int relativeTime= 0;

void setup()
{
  size(850,600);
  setupGUI();
  background(255);
}

void draw()
{
  //To Refresh the Background
  background(255);
  if(isPortChoosen){
    if ( serial.available() > 0) {
     serialMIDIRead();
    }
  }
 GUIDraw();
}
