/*
This file contains the Functions that are called while the Initial Setup of the
 GUI which Includes adding the Header Images, Creating the Graphs, Initializing the Frames
 for Animation and setting up of the Side Menu(Accordion)
 */

import grafica.*;
import controlP5.*;

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
void add_heart_beat_animation()
{

  for (int i= 1; i<=sequenceLength; i++) {
    animationSequence[i] = loadImage("heart"+i+".gif");
    animationSequence[i].resize(100, 0);
  }
}


/*
This creates digital graph UI for binary information
 */
void add_digital_graph()
{

  plot2 = cp5.addChart("Heart Pulse")
    .setPosition(73, arabeat_logo.height+height*0.45+85)
    .setSize(int(width*0.56), int(height*0.20))
    .setRange(-0.5, 1.5)
    .setView(Chart.LINE)
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(40));

  plot2.addDataSet("digitalData");
  plot2.setData("digitalData", new float[100]);
}


/*
This adds araBeat Logo to the canvas
 */
void add_arabeat_logo()
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
int first_row = 10;
int second_column = first_column + 220;
int second_row = first_row + 30;
int third_column = second_column + 220;
int third_row = second_row + 30;
int fourth_row = third_row + 30;
int fifth_row = fourth_row + 30;

void add_side_panel() {

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
    .setPosition(first_column, fourth_row)    
    .setImage(buttonFullScreenImage)
    .updateSize()
    .moveTo(accordionGroup1);

  buttonRefreshImage = loadImage("refresh.png");
  buttonRefreshImage.resize(20, 20);
  buttonRefresh = cp5.addButton("refreshEverything")
    .setPosition(first_column, fifth_row)    
    .setImage(buttonRefreshImage)
    .updateSize()
    .moveTo(accordionGroup1);

  cp5.addSlider("timeScale")
    .setPosition(first_column, third_row)
    .setSize(100, 20)
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

  // Add Side UI for ECG Analog Voltage data
  cp5.addSlider("ECG_ANALOG_VOLTAGE")
    .setLabel("ECG Analog Voltage")
    .setPosition(second_column, first_row)
    .setSize(100, 20)
    .setRange(-pow(2, 16), +pow(2, 16))
    .lock()
    .setValue(100)
    .moveTo(accordionGroup1);

  // Add Side UI for Heart Pulse data
  cp5.addSlider("HEART_PULSE")
    .setLabel("Heart Pulse")
    .setPosition(second_column, second_row)
    .setSize(100, 20)
    .setRange(0, 1)
    .setValue(0)
    .lock()
    .setMin(0)
    .setMax(1)
    .moveTo(accordionGroup1);

  // Add Side UI for Beats Per Minute
  cp5.addSlider("BPM")
    .setPosition(second_column, third_row)
    .setSize(100, 20)    
    .setRange(50, 120)
    .setValue(72)
    .moveTo(accordionGroup1);

  // Add Side UI for RTOR data
  cp5.addSlider("RTOR_IN_MS")
    .setLabel("RTOR in Milliseconds")
    .setPosition(second_column, 100)
    .setSize(100, 20)
    .setRange(500, 1000)
    .setValue(833)
    .moveTo(accordionGroup1);

  // Add Side UI for HANDS_ON data
  cp5.addSlider("HANDS_ON")
    .setLabel("HANDS ON")
    .setPosition(second_column, 130)
    .setSize(100, 20)    
    .setRange(0, 1)
    .setValue(0)
    .lock()
    .setMin(0)
    .setMax(1)
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
float plot1_width_in_percent = width * 11.5;
float plot1_height_in_percent = height * 4.5;
int plot1_x = 10;
int plot1_y = 200;

void add_analog_plot()
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


void setupGUI() {

  noStroke();
  smooth();

  //Makes the screen flexible to Scal
  surface.setResizable(true);

  cp5 = new ControlP5(this);

  add_arabeat_logo();
  add_analog_plot();
  add_side_panel();
}
