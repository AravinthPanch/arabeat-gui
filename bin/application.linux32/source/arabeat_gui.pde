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
int window_x = 1280;
int window_y = 800;



void setup()
{
  size(1280, 800);
  setupGUI();
  /*
  To create log set create log to True and it will create a 
  log file in the root dir with the current time
  
  To read from log choose select file in the Port options 
  
  Donot set read and write log at the same time!
  */
  create_log= false;
  initalize_log_writer();
  background(255);
}

void draw()
{
  //To Refresh the Background'
  background(255);
  if (isPortChoosen) {
    while ( serial.available() > 0) {
      serialMIDIRead();
    }
  }
  else if (read_log) {
    serialMIDIRead();
  }
  GUIDraw();
  flush_log();
}

void stop() {
  close_log();
} 
