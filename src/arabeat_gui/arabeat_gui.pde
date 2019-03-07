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
  
  To read log set read log to true and specify the log file name
  also specify the time interval between every data point.
  
  Donot set read and write log at the same time!
  */
  read_log= false;
  create_log= true;
  log_delay=10;
  logFile = "7_7_3_20_33_45_data";
  initalize_log_reader(logFile);
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
