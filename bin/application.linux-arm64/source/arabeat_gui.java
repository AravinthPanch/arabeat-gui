import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import grafica.*; 
import controlP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class arabeat_gui extends PApplet {

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



public void setup()
{
  
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

public void draw()
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

public void stop() {
  close_log();
} 
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

public void createAnimation(int bpm) 
{
  int timeDiff =  millis() - lastTime;  
  int requiredTimeDiff = PApplet.parseInt((60*1000)/(bpm*sequenceLength));

  image(animationSequence[lastFrame], width*0.55f+120, height*0.45f+180);

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

public void controlEvent(ControlEvent theEvent) 
{

  if (theEvent.isController() &&  (theEvent.getController().getName()).equals("baudrate")) 
  {
    int index = PApplet.parseInt(theEvent.getController().getValue());
    baudrate = baudrateList[index];
    println("Baudrate Choosen : "+ baudrate); 
  } else if (theEvent.isController() &&  (theEvent.getController().getName()).equals("choosePort")) 
  {
    int portNumber= PApplet.parseInt(theEvent.getController().getValue());
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
public void draw_digital_graph()
{
  plot2.setPosition(73, arabeat_logo.height+height*0.45f+85)
    .setSize(PApplet.parseInt(width*0.56f), PApplet.parseInt(height*0.20f));
}


/*
Draws legends for the graph
 */
int legend_width = 20;
int legend_height = 20;
public void draw_legends()
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
public void draw_heart_beat_animation()
{
  //image(animationSequence[1], 1000, 150);
  // Add Header Image  
  //createAnimation(bpm);
  bpm = PApplet.parseInt(cp5.getController("BPM").getValue());
}


/*
Draws other settings of the canvas
 */
public void draw_arabeat_logo()
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
public void set_rtor_in_ms_data(int val) 
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
public void set_hands_on_count_data(int val) 
{ 
  //println("HANDS_ON_COUNT:"+val); 

  cp5.getController("HANDS_ON_COUNT").setValue(val);
}


/*
Set received HANDS_OFF_COUNT value to side panel
 */
public void set_hands_off_count_data(int val) 
{ 
  //println("HANDS_OFF_COUNT:"+val); 

  cp5.getController("HANDS_OFF_COUNT").setValue(val);
}


/*
Set received SAMPLE_COUNT value to side panel
 */
public void set_sample_count_data(int val) 
{ 
  //println("SAMPLE_COUNT:"+val); 

  cp5.getController("SAMPLE_COUNT").setValue(val);
}


/*
Set received HANDS_ON_COUNT_THRESHOLD value to side panel
 */
public void set_hands_on_count_threshold_data(int val) 
{ 
  //println("HANDS_ON_COUNT_THRESHOLD:"+val);

  cp5.getController("HANDS_ON_COUNT_THRESHOLD").setValue(val);
}


/*
Set received HANDS_OFF_COUNT_THRESHOLD value to side panel
 */
public void set_hands_off_count_threshold_data(int val) 
{ 
  //println("HANDS_OFF_COUNT_THRESHOLD:"+val);

  cp5.getController("HANDS_OFF_COUNT_THRESHOLD").setValue(val);
}


/*
Set received STABLE_RTOR_STATUS value to side panel
 */
public void set_stable_rtor_status_data(int val) 
{ 
  //println("STABLE_RTOR_STATUS:"+val);

  cp5.getController("STABLE_RTOR_STATUS").setValue(val);
}


/*
Set received HANDS_ON value to side panel
 */
public void set_hands_on_data(int val) 
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
public void draw_side_panel()
{
  accordion.setPosition(arabeat_logo.width + spacing_x, top_margin);
}


/*
Set RTOR interrupt pulse data into the graph and side panel
 */
public void set_RTOR_interrupt_pulse_data(int val) {

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
public void set_heart_pulse_data(int val) {
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
public void set_ecg_analog_voltage_data(int val) 
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
public void draw_analog_graph()
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
public void GUIDraw() 
{
  draw_arabeat_logo();
  draw_analog_graph();
  draw_side_panel();
  draw_legends();
}
/*
This file contains the Functions that are called while the Initial Setup of the
 GUI which Includes adding the Header Images, Creating the Graphs, Initializing the Frames
 for Animation and setting up of the Side Menu(Accordion)
 */




public GPlot plot1;
PImage arabeat_logo, buttonFullScreenImage, buttonMinimizeImage, buttonRefreshImage;
public GPointsArray ecg_analog_voltage_data_layer, heart_pulse_data_layer, RTOR_interrupt_pulse_data_layer;
ControlP5 cp5;
Accordion accordion;
Button buttonFullScreen, buttonRefresh;
Chart plot2;
DropdownList choosePortDropdown, baudrateDropdown;

//List of the Baudrate to Show on the DropdownList
int baudrateList[] = {9600, 31250, 115200};


/*
This creates heartbeat animation UI
 */
public void add_heart_beat_animation()
{

  for (int i= 1; i<=sequenceLength; i++) {
    animationSequence[i] = loadImage("heart"+i+".gif");
    animationSequence[i].resize(100, 0);
  }
}


/*
This creates digital graph UI for binary information
 */
public void add_digital_graph()
{

  plot2 = cp5.addChart("Heart Pulse")
    .setPosition(73, arabeat_logo.height+height*0.45f+85)
    .setSize(PApplet.parseInt(width*0.56f), PApplet.parseInt(height*0.20f))
    .setRange(-0.5f, 1.5f)
    .setView(Chart.LINE)
    .setStrokeWeight(1.5f)
    .setColorCaptionLabel(color(40));

  plot2.addDataSet("digitalData");
  plot2.setData("digitalData", new float[100]);
}


/*
This adds araBeat Logo to the canvas
 */
public void add_arabeat_logo()
{  
  arabeat_logo = loadImage("arabeat.png");
  arabeat_logo.resize(250, 0);
}


/*
This creates side panel UI for numeric display and settings
 */
int left_margin = 30;
int top_margin = 30;
int right_margin = 100;
int side_panel_height = 170;
int spacing_x = 50;
int first_column = 10;
int second_column = first_column + 220;
int third_column = second_column + 170;
int fourth_column = third_column + 170;
int fifth_column = fourth_column + 170;
int first_row = 10;
int second_row = first_row + 30;
int third_row = second_row + 30;
int fourth_row = third_row + 30;
int fifth_row = fourth_row + 30;
int slider_width = 50;
int slider_height = 20;

public void add_side_panel() {

  // List Setup
  Group accordionGroup1 = cp5.addGroup("Configuration")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(side_panel_height)
    .setHeight(10);

  buttonFullScreenImage = loadImage("fullscreen.png");
  buttonFullScreenImage.resize(20, 20);
  buttonMinimizeImage = loadImage("minimize.png");
  buttonMinimizeImage.resize(20, 20);
  buttonFullScreen = cp5.addButton("setFullScreen")
    .setPosition(first_column, fifth_row)    
    .setImage(buttonFullScreenImage)
    .updateSize()
    .moveTo(accordionGroup1);

  buttonRefreshImage = loadImage("refresh.png");
  buttonRefreshImage.resize(20, 20);
  buttonRefresh = cp5.addButton("refreshEverything")
    .setPosition(first_column + 30, fifth_row)    
    .setImage(buttonRefreshImage)
    .updateSize()
    .moveTo(accordionGroup1);


  cp5.addSlider("timeScale")
    .setPosition(first_column, third_row)
    .setSize(slider_width, slider_height)
    .setCaptionLabel("Time Scale")
    .setRange(0, 500)
    .setValue(400)
    .setMin(0)
    .setMax(500)
    .moveTo(accordionGroup1);

  baudrateDropdown = cp5.addDropdownList("baudrate")
    .setPosition(first_column, second_row)
    .setBackgroundColor(color(190))
    .setItemHeight(15)
    .setWidth(60)
    .setBarHeight(20)
    .moveTo(accordionGroup1)
    .setColorActive(color(255, 128))
    .setCaptionLabel("115200")
    .setOpen(false);

  // Add all the serial baudrates to the list
  for (int i=0; i<baudrateList.length; i++) {
    baudrateDropdown.addItem(Integer.toString(baudrateList[i]), i);
  }

  choosePortDropdown = cp5.addDropdownList("choosePort")
    .setPosition(first_column, first_row)
    .setWidth(180)
    .setBackgroundColor(color(190))
    .setItemHeight(15)
    .setBarHeight(20)
    .setColorActive(color(255, 128))
    .moveTo(accordionGroup1)
    .setCaptionLabel("Choose Port")
    .setOpen(false);

  // Add all the available serial ports to the list
  for (int i=0; i<(Serial.list()).length; i++) {
    choosePortDropdown.addItem(Serial.list()[i], i);
  }
  // Add option to choose from file
  choosePortDropdown.addItem("Select File",(Serial.list()).length);
  
  // Add Side UI for ECG Analog Voltage data
  cp5.addSlider("ECG_MAX")
    .setLabel("ECG MAX")
    .setPosition(second_column, first_row)
    .setSize(slider_width, slider_height)
    .setRange(-pow(2, 16), +pow(2, 16))
    .lock()
    .setValue(0)
    .moveTo(accordionGroup1);

  // Add Side UI for ECG Analog Voltage data
  cp5.addSlider("ECG_MIN")
    .setLabel("ECG MIN")
    .setPosition(second_column, second_row)
    .setSize(slider_width, slider_height)
    .setRange(-pow(2, 16), +pow(2, 16))
    .lock()
    .setValue(0)
    .moveTo(accordionGroup1);

  // Add Side UI for Heart Pulse data
  cp5.addSlider("HEART_PULSE")
    .setLabel("Heart Pulse")
    .setPosition(second_column, third_row)
    .setSize(slider_width, slider_height)
    .setRange(0, 1)
    .setValue(0)
    .lock()
    .setMin(0)
    .setMax(1)
    .moveTo(accordionGroup1); 

  // Add Side UI for RTOR data
  cp5.addSlider("RTOR_IN_MS")
    .setLabel("RTOR in Milliseconds")
    .setPosition(second_column, fourth_row)
    .setSize(slider_width, slider_height)
    .setRange(500, 1000)
    .lock()
    .setValue(833)
    .moveTo(accordionGroup1);

  // Add Side UI for Beats Per Minute
  cp5.addSlider("BPM")
    .setPosition(second_column, fifth_row)
    .setSize(slider_width, slider_height)    
    .setRange(50, 120)
    .lock()
    .setValue(72)
    .moveTo(accordionGroup1);


  // Add Side UI for HANDS_ON_COUNT data
  cp5.addSlider("HANDS_ON_COUNT")
    .setLabel("HANDS ON COUNT")
    .setPosition(third_column, first_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 200)
    .setValue(0)
    .lock()
    .moveTo(accordionGroup1);

  // Add Side UI for HANDS_OFF_COUNT data
  cp5.addSlider("HANDS_OFF_COUNT")
    .setLabel("HANDS OFF COUNT")
    .setPosition(third_column, second_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 200)
    .setValue(0)
    .lock()
    .moveTo(accordionGroup1);

  // Add Side UI for SAMPLE_COUNT data
  cp5.addSlider("SAMPLE_COUNT")
    .setLabel("SAMPLE COUNT")
    .setPosition(third_column, third_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 200)
    .setValue(0)
    .lock()
    .moveTo(accordionGroup1);

  // Add Side UI for HANDS_ON data
  cp5.addSlider("HANDS_ON")
    .setLabel("HANDS ON")
    .setPosition(third_column, fourth_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 1)
    .setValue(0)
    .lock()
    .setMin(0)
    .setMax(1)
    .moveTo(accordionGroup1);

  // Add Side UI for STABLE_RTOR_STATUS data
  cp5.addSlider("STABLE_RTOR_STATUS")
    .setLabel("STABLE RTOR STATUS")
    .setPosition(third_column, fifth_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 2)
    .setValue(0)
    .lock()    
    .moveTo(accordionGroup1);

  // Add Side UI for HANDS_ON_COUNT data
  cp5.addSlider("HANDS_ON_COUNT_THRESHOLD")
    .setLabel("HANDS ON COUNT THRESHOLD")
    .setPosition(fourth_column, first_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 200)
    .setValue(0)
    .lock()
    .moveTo(accordionGroup1);

  // Add Side UI for HANDS_OFF_COUNT data
  cp5.addSlider("HANDS_OFF_COUNT_THRESHOLD")
    .setLabel("HANDS OFF COUNT THRESHOLD")
    .setPosition(fourth_column, second_row)
    .setSize(slider_width, slider_height)    
    .setRange(0, 200)
    .setValue(0)
    .lock()
    .moveTo(accordionGroup1);


  // create a new accordion
  accordion = cp5.addAccordion("Data")
    .setPosition(arabeat_logo.width + spacing_x, top_margin)
    .setWidth(width - arabeat_logo.width - right_margin)
    .addItem(accordionGroup1);

  accordion.open(0);
  accordion.setCollapseMode(Accordion.MULTI);
}

/*
This creates analog graph UI for two bytes information
 */
float plot1_width_in_percent = width * 11.5f;
float plot1_height_in_percent = height * 4.5f;
int plot1_x = 10;
int plot1_y = 200;
float legend_y = top_margin + side_panel_height + plot1_height_in_percent + 80;

public void add_analog_plot()
{
  // add data layers for analog graph
  ecg_analog_voltage_data_layer = new GPointsArray();
  heart_pulse_data_layer = new GPointsArray();
  RTOR_interrupt_pulse_data_layer = new GPointsArray();

  plot1 = new GPlot(this);
  plot1.setPos(plot1_x, plot1_y);
  plot1.setDim(plot1_width_in_percent, plot1_height_in_percent);  
  plot1.addLayer("layer1", ecg_analog_voltage_data_layer);
  plot1.getLayer("layer1").setLineColor(color(0, 0, 255));
  plot1.addLayer("layer2", heart_pulse_data_layer);
  plot1.getLayer("layer2").setLineColor(color(255, 0, 0));
  plot1.addLayer("layer3", RTOR_interrupt_pulse_data_layer);
  plot1.getLayer("layer3").setLineColor(color(0, 255, 0));
  plot1.getXAxis().getAxisLabel().setText("Time");
  //plot1.getYAxis().getAxisLabel().setText("ECG Analog Voltage");
}


public void setupGUI() {

  noStroke();
  smooth();

  //Makes the screen flexible to Scal
  surface.setResizable(true);

  cp5 = new ControlP5(this);

  add_arabeat_logo();
  add_analog_plot();
  add_side_panel();
}

//File Handling 
PrintWriter log_writer;
BufferedReader log_reader;
Boolean create_log = true; 
Boolean read_log = false;
int log_delay = 10;

public String getTimeStamp(){
  int day = day();
  int month = month();
  int hour = hour();
  int minute = minute();
  int second = second();
  String TimeStamp = day + "_"+ day + "_"+ month+ "_"+ hour+ "_"+ minute+ "_"+ second;
  return(TimeStamp);
}

public void initalize_log_writer(){
  if(create_log){
    log_writer = createWriter("data_"+getTimeStamp()); 
  }
}

public void initalize_log_reader(){
    selectInput("Select a file to process:","logSelected");
}

public void logSelected(File selection){
  if(selection == null){
    println("File was not Selected");
  }
  else{
    println(selection.getAbsolutePath());
    log_reader = createReader(selection.getName());
    read_log = true;
  }
}

// Read Byte
public int read_log(){
  if(read_log){
    try{
      int data = log_reader.read();
      delay(log_delay);
      return data;
    }catch (Exception e) {
      e.printStackTrace();
    }
  }
  return 0;
}

// This writes the data into the file 
public void write_log(int data){
  if(create_log){
    log_writer.write(data);
  }
}

public void flush_log(){
  if(create_log){
    log_writer.flush();
  }
}

public void close_log(){
  if(create_log){
    log_writer.close();
  }
}
/*
This file contains the function which reads the Byte serial and converts into command
 and Data.Then using this data plot the Graph.
 */

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
checks if the data is awailable
*/
public int data_available(){
  if(read_log){
    // fixMe: Return 0 if the file is ended
    return 1;
  }
  else{
    return serial.available();
  }
}

/*
Reads from Serial and logs the data
or reads the data from previous logs
*/
public int data_read(){
  int data;
  if(read_log){
    data = read_log();
  }
  else{
    data = serial.read();
    write_log(data);
  }
 
  return data;
}


/*
Read and parse two bytes data
 */
public int read_two_bytes_data()
{
  int result = 0;

  // For first 2 MSB
  while (data_available()==0) {
    delay(1);
  }
  result= (data_read())<<7;

  //For middle 7 Bits
  while (data_available()==0) {
    delay(1);
  }
  result= (result|data_read())<<7;

  //For last 7 Bits
  while (data_available()==0) {
    delay(1);
  }
  result= (result|data_read());
  return result;
}


/*
Reads the Serial using MIDI and Firmat Protocol
 and calls the Plot function according the data
 Detailed Explanation in the README.md
 */
public void serialMIDIRead() {
  command= data_read();
  data= 0;
  switch(command) {

  case ECG_ANALOG_VOLTAGE:
    data = read_two_bytes_data();

    // if the first MSB has set bit then the Val is negative
    if (data>32767) data= data| negativeConversion;

    set_ecg_analog_voltage_data(data);
    break;

  case HEART_PULSE:
    while (data_available()==0) {
      delay(1);
    }
    data=data_read();
    set_heart_pulse_data(data);
    break;

  case RTOR_IN_MS:
    data = read_two_bytes_data();
    set_rtor_in_ms_data(data);
    break;

  case HANDS_ON:
    while (data_available()==0) {
      delay(1);
    }
    data=data_read();
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
  public void settings() {  size(1280, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "arabeat_gui" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
