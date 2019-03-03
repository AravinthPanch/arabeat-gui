/*
This file contains the Functions that are called while the Initial Setup of the
 GUI which Includes adding the Header Images, Creating the Graphs, Initializing the Frames
 for Animation and setting up of the Side Menu(Accordion)
 */

import grafica.*;
import controlP5.*;

public GPlot plot1;
public GPointsArray plotData1;
int plotHeight1= 250;
int plotWidth1= 450;

PImage headerImage, buttonFullScreenImage, buttonMinimizeImage, buttonRefreshImage;
ControlP5 cp5;
Accordion accordion;
Button buttonFullScreen, buttonRefresh;
Chart plot2;

DropdownList choosePortDropdown, baudrateDropdown;
//List of the Baudrate to Show on the DropdownList
int baudrateList[] = {9600, 31250, 115200};

void setupGUI() {
  noStroke();
  smooth();
  //Makes the screen flexible to Scal
  surface.setResizable(true);

  cp5 = new ControlP5(this);

  // Add the Header Image to the Canva
  headerImage = loadImage("arabeat.png");
  headerImage.resize(250, 0);

  //Animation Image Sequence
  for (int i= 1; i<=sequenceLength; i++) {
    animationSequence[i] = loadImage("heart"+i+".gif");
    animationSequence[i].resize(100, 0);
  }

  // Setup for the first plot
  plot1 = new GPlot(this);
  plot1.setPos(10, headerImage.height+10);
  plot1.setDim(width*0.55, height*0.45);
  plot1.getXAxis().getAxisLabel().setText("Time");
  plot1.getYAxis().getAxisLabel().setText("Analog Val0");

  addAccordion();

  // Second Plot
  plot2 = cp5.addChart("DigitalHeartBeat")
    .setPosition(73, headerImage.height+height*0.45+85)
    .setSize(int(width*0.56), int(height*0.20))
    .setRange(-0.5, 1.5)
    .setView(Chart.LINE)
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(40));

  plot2.addDataSet("digitalData");
  plot2.setData("digitalData", new float[100]);
}

/*
This creates the Side Pane Menu (accordion)
 */
void addAccordion() {
  // List Setup
  Group accordionGroup1 = cp5.addGroup("Configuration")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(130)
    .setHeight(10);

  cp5.addSlider("timeScale")
    .setPosition(10, 70)
    .setSize(100, 20)
    .setCaptionLabel("Time Scale")
    .setRange(0, 500)
    .setValue(400)
    .setMin(0)
    .setMax(500)
    .moveTo(accordionGroup1);


  baudrateDropdown = cp5.addDropdownList("baudrate")
    .setPosition(10, 40)
    .setBackgroundColor(color(190))
    .setItemHeight(20)
    .setWidth(60)
    .setBarHeight(15)
    .moveTo(accordionGroup1)
    .setColorActive(color(255, 128))
    .setCaptionLabel("115200")
    .setOpen(false);

  for (int i=0; i<baudrateList.length; i++) {
    baudrateDropdown.addItem(Integer.toString(baudrateList[i]), i);
  }


  choosePortDropdown = cp5.addDropdownList("choosePort")
    .setPosition(10, 10)
    .setWidth(180)
    .setBackgroundColor(color(190))
    .setItemHeight(20)
    .setBarHeight(15)
    .setColorActive(color(255, 128))
    .moveTo(accordionGroup1)
    .setCaptionLabel("Choose Port")
    .setOpen(false);

  for (int i=0; i<(Serial.list()).length; i++) {
    choosePortDropdown.addItem(Serial.list()[i], i);
  }




  Group accordionGroup2 = cp5.addGroup("midiData")
    .setLabel("Midi Data")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(50);


  cp5.addSlider("analogVal0")
    .setLabel("Analog Val0")
    .setPosition(10, 10)
    .setSize(100, 20)
    .setRange(-pow(2, 16), +pow(2, 16))
    .lock()
    .setValue(100)
    .moveTo(accordionGroup2);

  cp5.addSlider("digitalVal0")
    .setLabel("Analog Val0")
    .setPosition(10, 40)
    .setSize(100, 20)
    .setRange(0, 1)
    .setValue(0)
    .lock()
    .setMin(0)
    .setMax(1)
    .moveTo(accordionGroup2);

  cp5.addSlider("BPM")
    .setPosition(10, 70)
    .setSize(100, 20)
    .moveTo(accordionGroup2)
    .setColorCaptionLabel(color(0, 64))
    .setRange(0, 200)
    .setValue(80);

  Group accordionGroup3 = cp5.addGroup("otherSettings")
    .setLabel("Settings")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(50);

  buttonFullScreenImage = loadImage("fullscreen.png");
  buttonFullScreenImage.resize(30, 30);
  buttonMinimizeImage = loadImage("minimize.png");
  buttonMinimizeImage.resize(30, 30);
  buttonFullScreen = cp5.addButton("setFullScreen")
    .setPosition(10, 10)
    .moveTo(accordionGroup3)
    .setImage(buttonFullScreenImage)
    .updateSize();

  buttonRefreshImage = loadImage("refresh.png");
  buttonRefreshImage.resize(30, 30);
  buttonRefresh = cp5.addButton("refreshEverything")
    .setPosition(50, 10)
    .moveTo(accordionGroup3)
    .setImage(buttonRefreshImage)
    .updateSize();

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("Data")
    .setPosition(width*0.68, headerImage.height+50)
    .setWidth(200)
    .addItem(accordionGroup1)
    .addItem(accordionGroup2)
    .addItem(accordionGroup3);

  accordion.open(0, 1);
  accordion.setCollapseMode(Accordion.MULTI);
}
