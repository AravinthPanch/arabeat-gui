/*
This file contains the Funtions called while the Draw function of
 processing is runs which mostly includes ploting the Graph, Making Objects Dynamic
 and Creating Animation
 */


/*
This function uses the bpm and the time since the program started (milis())
 to switch to the next frame of the animation
 */
int sequenceLength= 12;
PImage[] animationSequence = new PImage[sequenceLength+1];
int lastFrame= 1;
int lastTime=1;
int bpm= 80;

void createAnimation(int bpm) {
  int timeDiff =  millis() - lastTime;
  int requiredTimeDiff = int((60*1000)/(bpm*sequenceLength));
  image(animationSequence[lastFrame], width*0.55+120, height*0.45+180);
  if (timeDiff>=requiredTimeDiff) {
    //change frame
    lastTime= millis();
    lastFrame= (lastFrame%sequenceLength)+1;
  }
}



/*
This function is called when any of the dropdown is selected. (Baudrate/Port)
 */
boolean isPortChoosen = false;

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isController() &&  (theEvent.getController().getName()).equals("baudrate")) {
    int index = int(theEvent.getController().getValue());
    baudrate = baudrateList[index];
    println("Baudrate Choosen : "+ baudrate);
  } else if (theEvent.isController() &&  (theEvent.getController().getName()).equals("choosePort")) {
    int portNumber= int(theEvent.getController().getValue());
    portName = Serial.list()[portNumber];
    println("Port Choosen : "+ portName);
    serial = new Serial(this, portName, baudrate);
    isPortChoosen = true;
  }
}


/*
Draws digital graph UI for binary information on the canvas
 */
void draw_digital_graph()
{
  plot2.setPosition(73, arabeat_logo.height+height*0.45+85)
    .setSize(int(width*0.56), int(height*0.20));
}


/*
Draws heartbeat animation
 */
void draw_heart_beat_animation()
{
  //image(animationSequence[1], 1000, 150);
  // Add Header Image  
  //createAnimation(bpm);
  bpm = int(cp5.getController("BPM").getValue());
}


/*
Draws other settings of the canvas
 */
void draw_arabeat_logo()
{
  image(arabeat_logo, left_margin, top_margin + 50);
}


/*
Makes the size of the surface equal to that of the screen
 */
boolean isFullScreen= false;

public void setFullScreen() {
  if (!isFullScreen) {
    buttonFullScreen.setImage(buttonMinimizeImage);
    surface.setSize(displayWidth, displayHeight);
    isFullScreen = true;
  } else {
    buttonFullScreen.setImage(buttonFullScreenImage);
    surface.setSize(window_x, window_y);
    isFullScreen = false;
  }
}


/*
This Stops the Serial, Cleans the Graph, and Refreshes the Serial Port List
 */
public void refreshEverything() {
  if (isPortChoosen) {
    isPortChoosen = false;
    serial.stop();
  }
  choosePortDropdown.clear();
  for (int i=0; i<(Serial.list()).length; i++) {
    choosePortDropdown.addItem(Serial.list()[i], i);
  }
  while (plot1.getPointsRef().getNPoints()>0) {
    plot1.removePoint(0);
  }
}


/*
Set received RTOR value to side panel & caculate BPM 
 */
void set_rtor_in_ms_data(int val) 
{
  println("RTOR:"+val); 

  cp5.getController("RTOR_IN_MS").setValue(val);

  // calculate bpm based on RTOR in Millisecond
  float bpm = (float) (60 * 1000) / val;

  //println("BPM:" + bpm);

  cp5.getController("BPM").setValue(bpm);
}


/*
Set received ELECTRODES_TOUCHED value to side panel
 */
void set_electrodes_touched_data(int val) 
{ 
  println("ELECTRODES_TOUCHED:"+val); 

  cp5.getController("ELECTRODES_TOUCHED").setValue(val);
}


/*
Draws side panel UI for numeric display and settings
 */
void draw_side_panel()
{
  accordion.setPosition(arabeat_logo.width + spacing_x, top_margin);
}


/*
Set RTOR interrupt pulse data into the graph and side panel
 */
void set_RTOR_interrupt_pulse_data(int val) {
  // add data to graph by add a point and removing prevoious point.
  while (RTOR_interrupt_pulse_data_layer.getNPoints()>cp5.getController("timeScale").getValue()) {
    RTOR_interrupt_pulse_data_layer.remove(0);
  }
  RTOR_interrupt_pulse_data_layer.add(relativeTime, val);
}


/*
Set heart pulse data into the graph and side panel
 */
void set_heart_pulse_data(int val) {
  //println("PULSE:"+val);

  // add data to graph by add a point and removing prevoious point.
  while (heart_pulse_data_layer.getNPoints()>cp5.getController("timeScale").getValue()) {
    heart_pulse_data_layer.remove(0);
  }
  heart_pulse_data_layer.add(relativeTime, val);

  // add data to side panel
  cp5.getController("HEART_PULSE").setValue(val);
}


/*
Set analg ecg voltage data into the graph and side panel
 */
void set_ecg_analog_voltage_data(int val) 
{
  //println("ECG:"+val);

  // add data to graph by add a point and removing prevoious point.
  while (ecg_analog_voltage_data_layer.getNPoints()>cp5.getController("timeScale").getValue()) {
    ecg_analog_voltage_data_layer.remove(0);
  }

  ecg_analog_voltage_data_layer.add(relativeTime, val);
  relativeTime+=1;

  // add data to side panel
  cp5.getController("ECG_ANALOG_VOLTAGE").setValue(val);
}


/*
Draws analog graph UI for two bytes information
 */
void draw_analog_graph()
{
  //plot1.activatePanning();
  plot1.beginDraw();  
  plot1.setDim(plot1_width_in_percent, plot1_height_in_percent);
  plot1.setPos(plot1_x, plot1_y);
  plot1.drawBackground();
  plot1.drawBox();
  plot1.drawXAxis();
  plot1.setPoints(ecg_analog_voltage_data_layer, "layer1");
  plot1.setPoints(heart_pulse_data_layer, "layer2");
  plot1.setPoints(RTOR_interrupt_pulse_data_layer, "layer3");
  plot1.drawYAxis();
  plot1.drawTitle();
  plot1.drawGridLines(GPlot.BOTH);
  plot1.drawLines();
  plot1.endDraw();
}


/*
This function is called in every frame of Processing
 It checks the size of the Screen and according to that changes the dimensions
 of other objects in the Screen to make them more Dynamic
 */
void GUIDraw() 
{
  draw_arabeat_logo();
  draw_analog_graph();
  draw_side_panel();
}
