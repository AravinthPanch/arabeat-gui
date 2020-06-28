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

void createAnimation(int bpm) 
{
  int timeDiff =  millis() - lastTime;  
  int requiredTimeDiff = int((60*1000)/(bpm*sequenceLength));

  image(animationSequence[lastFrame], width*0.55+120, height*0.45+180);

  if (timeDiff>=requiredTimeDiff) 
  {
    //change frame
    lastTime= millis();
    lastFrame= (lastFrame%sequenceLength)+1;
  }
}



/*
This function is called when any of the dropdown is selected. (Baudrate/Port)
 */
boolean isPortChoosen = false;

void controlEvent(ControlEvent theEvent) 
{

  if (theEvent.isController() &&  (theEvent.getController().getName()).equals("baudrate")) 
  {
    int index = int(theEvent.getController().getValue());
    baudrate = baudrateList[index];
    println("Baudrate Choosen : "+ baudrate); 
  } else if (theEvent.isController() &&  (theEvent.getController().getName()).equals("choosePort")) 
  {
    int portNumber= int(theEvent.getController().getValue());
    if(portNumber == Serial.list().length){
      // if the person chooses to select from a file 
      initalize_log_reader();
    }
    else{
      portName = Serial.list()[portNumber];
      println("Port Choosen : "+ portName);
      serial = new Serial(this, portName, baudrate);
      isPortChoosen = true;
    }
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
Draws legends for the graph
 */
int legend_width = 20;
int legend_height = 20;
void draw_legends()
{   
  fill(0, 0, 255);
  rect(left_margin + 50, legend_y, legend_width, legend_height);
  text("ECG Analog Voltage", left_margin + 50 + legend_width + 10, legend_y + legend_height / 2); 

  fill(255, 0, 0);
  rect(left_margin + 200, legend_y, legend_width, legend_height);
  text("Heart Pulse", left_margin + 200 + legend_width + 10, legend_y + legend_height / 2);

  fill(0, 255, 0);
  rect(left_margin + 300, legend_y, legend_width, legend_height);
  text("RTOR Pulse", left_margin + 300 +legend_width + 10, legend_y + legend_height / 2);
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

public void setFullScreen() 
{
  if (!isFullScreen) 
  {
    buttonFullScreen.setImage(buttonMinimizeImage);
    surface.setSize(displayWidth, displayHeight);
    isFullScreen = true;
  } else 
  {
    buttonFullScreen.setImage(buttonFullScreenImage);
    surface.setSize(window_x, window_y);
    isFullScreen = false;
  }
}


/*
This Stops the Serial, Cleans the Graph, and Refreshes the Serial Port List
 */
public void refreshEverything() 
{
  if (isPortChoosen) 
  {
    isPortChoosen = false;
    serial.stop();
  }

  choosePortDropdown.clear();

  for (int i=0; i < (Serial.list()).length; i++) 
  {
    choosePortDropdown.addItem(Serial.list()[i], i);
  }

  while (plot1.getPointsRef().getNPoints()>0) 
  {
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
Set received HANDS_ON_COUNT value to side panel
 */
void set_hands_on_count_data(int val) 
{ 
  //println("HANDS_ON_COUNT:"+val); 

  cp5.getController("HANDS_ON_COUNT").setValue(val);
}


/*
Set received HANDS_OFF_COUNT value to side panel
 */
void set_hands_off_count_data(int val) 
{ 
  //println("HANDS_OFF_COUNT:"+val); 

  cp5.getController("HANDS_OFF_COUNT").setValue(val);
}


/*
Set received SAMPLE_COUNT value to side panel
 */
void set_sample_count_data(int val) 
{ 
  //println("SAMPLE_COUNT:"+val); 

  cp5.getController("SAMPLE_COUNT").setValue(val);
}


/*
Set received HANDS_ON_COUNT_THRESHOLD value to side panel
 */
void set_hands_on_count_threshold_data(int val) 
{ 
  //println("HANDS_ON_COUNT_THRESHOLD:"+val);

  cp5.getController("HANDS_ON_COUNT_THRESHOLD").setValue(val);
}


/*
Set received HANDS_OFF_COUNT_THRESHOLD value to side panel
 */
void set_hands_off_count_threshold_data(int val) 
{ 
  //println("HANDS_OFF_COUNT_THRESHOLD:"+val);

  cp5.getController("HANDS_OFF_COUNT_THRESHOLD").setValue(val);
}


/*
Set received STABLE_RTOR_STATUS value to side panel
 */
void set_stable_rtor_status_data(int val) 
{ 
  //println("STABLE_RTOR_STATUS:"+val);

  cp5.getController("STABLE_RTOR_STATUS").setValue(val);
}


/*
Set received HANDS_ON value to side panel
 */
void set_hands_on_data(int val) 
{ 
  //println("HANDS_ON:"+val); 

  cp5.getController("HANDS_ON").setValue(val);

  // reset max & min value for every hands on data arrival
  prev_max_val = -15; // midline of hands off
  prev_min_val = 0; // midline of hands on
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
  while (RTOR_interrupt_pulse_data_layer.getNPoints() > cp5.getController("timeScale").getValue()) 
  {
    RTOR_interrupt_pulse_data_layer.remove(0);
  }

  RTOR_interrupt_pulse_data_layer.add(relativeTime, val);
  relativeTime += 1;
}


/*
Set heart pulse data into the graph and side panel
 */
void set_heart_pulse_data(int val) {
  //println("PULSE:"+val);

  // add data to graph by add a point and removing prevoious point.
  while (heart_pulse_data_layer.getNPoints() > cp5.getController("timeScale").getValue()) 
  {
    heart_pulse_data_layer.remove(0);
  }

  heart_pulse_data_layer.add(relativeTime, val);
  relativeTime += 1;

  // add data to side panel
  cp5.getController("HEART_PULSE").setValue(val);
}


/*
Set analg ecg voltage data into the graph and side panel
 */
int prev_max_val = 0;
int prev_min_val = 0;
void set_ecg_analog_voltage_data(int val) 
{
  println("ECG:"+val);

  // add data to graph by add a point and removing prevoious point.
  while (ecg_analog_voltage_data_layer.getNPoints() > cp5.getController("timeScale").getValue()) 
  {
    ecg_analog_voltage_data_layer.remove(0);
  }

  ecg_analog_voltage_data_layer.add(relativeTime, val);
  relativeTime += 1;

  if (val > prev_max_val)
    prev_max_val = val;

  if (val < prev_min_val)
    prev_min_val = val;

  // add data to side panel
  cp5.getController("ECG_MAX").setValue(prev_max_val);
  cp5.getController("ECG_MIN").setValue(prev_min_val);
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
  draw_legends();
}
