/*
This code was built with Processing 3.5.3

Depedencies
-----------
Grafica 1.9.0
ControlP5 2.2.6

Not for me: Add P5 2D slider
*/

import processing.serial.*;
import grafica.*;
import controlP5.*;

Serial serial;
int baudRate= 115200;
final int AnalogVal0 = 0xE0;
final int DigitalVal0 = 0x90;
int negativeConversion = -65536;
int data;
int command;

PImage headerImage;

int sequenceLength= 12;
PImage[] animationSequence = new PImage[sequenceLength+1];
int lastFrame= 1;
int lastTime=1;
int bpm= 80;

public GPlot plot1;
public GPointsArray plotData1;
int plotHeight1= 300;
int plotWidth1= 500;
int relativeTime= 0;


ControlP5 cp5;
Accordion accordion;
Chart plot2;

DropdownList choosePort;
boolean isPortChoosen = false;

void settings() {
  fullScreen();
}

void setup()
{
  background(255);
  noStroke();
  smooth();
  cp5 = new ControlP5(this);
  //surface.setResizable(true);


  // Add the Header Image to the Canva
  headerImage = loadImage("arabeat.png");
  headerImage.resize(250, 0);

  //Animation Image Sequence
  for(int i= 1; i<=sequenceLength; i++){
    animationSequence[i] = loadImage("heart"+i+".gif");
    animationSequence[i].resize(100,0);
  }
  cp5.addSlider("BPM")
     .setPosition(1000,250)
     .setSize(100,20)
     .setColorCaptionLabel(color(0,64))
     .setRange(0,200)
     .setValue(80);

  // Setup for the first plot
  plot1 = new GPlot(this);
  plot1.setPos(10, headerImage.height+10);
  plot1.setDim(plotWidth1, plotHeight1);
  plot1.getTitle().setText("Frequency");
  plot1.getXAxis().getAxisLabel().setText("Time");
  plot1.getYAxis().getAxisLabel().setText("Amplitude");


  // List Setup
  Group accordionGroup1 = cp5.addGroup("Amplitude Data")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150);

  cp5.addSlider("Max Amplitude")
     .setPosition(10,20)
     .setSize(100,20)
     .setRange(100,500)
     .setValue(100)
     .moveTo(accordionGroup1);

  cp5.addSlider("Min Amplitude")
     .setPosition(10,50)
     .setSize(100,20)
     .setRange(100,500)
     .setValue(200)
     .moveTo(accordionGroup1);

  Group accordianGroup2 = cp5.addGroup("Axis Choice")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150)
                ;

  cp5.addRadioButton("radio")
     .setPosition(10,20)
     .setItemWidth(20)
     .setItemHeight(20)
     .addItem("frquency", 0)
     .addItem("amplitude", 1)
     .addItem("bpm", 2)
     .addItem("x", 3)
     .addItem("y", 4)
     .setColorLabel(color(255))
     .activate(2)
     .moveTo(accordianGroup2);

  Group accordianGroup3 = cp5.addGroup("Osc Data")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150);

  cp5.addBang("Toggle")
     .setPosition(10,20)
     .setSize(40,50)
     .moveTo(accordianGroup3);

  cp5.addSlider("Val")
     .setPosition(60,20)
     .setSize(100,20)
     .setRange(100,500)
     .setValue(100)
     .moveTo(accordianGroup3);

  cp5.addSlider("Pitch")
     .setPosition(60,50)
     .setSize(100,20)
     .setRange(100,500)
     .setValue(200)
     .lock()
     .setMin(-10000)
     .setMax(10000)
     .moveTo(accordianGroup3);

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("Data")
                 .setPosition(plotWidth1+200,headerImage.height+50)
                 .setWidth(200)
                 .addItem(accordionGroup1)
                 .addItem(accordianGroup2)
                 .addItem(accordianGroup3);


  accordion.open(0,1,2);
  accordion.setCollapseMode(Accordion.MULTI);

  // Second Plot
  plot2 = cp5.addChart("DigitalHeartBeat")
               .setPosition(50, plotHeight1+200)
               .setSize(530, 100)
               .setRange(-0.5, 1.5)
               .setView(Chart.LINE)
               .setStrokeWeight(1.5)
               .setColorCaptionLabel(color(40));

  plot2.addDataSet("digitalData");
  plot2.setData("digitalData", new float[100]);

  choosePort = cp5.addDropdownList("choosePort")
          .setPosition(10, 10);

  choosePort.setBackgroundColor(color(190));
  choosePort.setItemHeight(20);
  choosePort.setBarHeight(15);
  choosePort.getCaptionLabel().set("Choose Port");

  for (int i=0;i<(Serial.list()).length;i++) {
    choosePort.addItem(Serial.list()[i], i);
  }
  //ddl.scroll(0);
  choosePort.setColorBackground(color(60));
  choosePort.setColorActive(color(255, 128));



}

void controlEvent(ControlEvent theEvent) {

  //|| (theEvent.getController().getName()).equals("choosePort [DropdownList]")
  if (theEvent.isController() &&  (theEvent.getController().getName()).equals("choosePort")) {
    int portNumber= int(theEvent.getController().getValue());
    String portName = Serial.list()[portNumber];
    println("Port Choosen : "+ portName);
    serial = new Serial(this, portName, baudRate);
    isPortChoosen = true;
  }
}

void createAnimation(int bpm){
  int timeDiff =  millis() - lastTime;
  int requiredTimeDiff = int((60*1000)/(bpm*sequenceLength));
  image(animationSequence[lastFrame], 1000, 150);
  if(timeDiff>=requiredTimeDiff){
    //change frame
    lastTime= millis();
    lastFrame= (lastFrame%sequenceLength)+1;
  }

}


void draw()
{
  //To Refresh the Background
  background(255);
  //image(animationSequence[1], 1000, 150);
  // Add Header Image
  image(headerImage, (width/2)-125 , 10);
  createAnimation(bpm);
  if(isPortChoosen){
    if ( serial.available() > 0) {
      command= serial.read();
      data= 0;
      switch(command){

        // Add a case for every command value you want to listen
        case AnalogVal0:
          // For first 2 MSB
          while(serial.available()==0);
          data= (serial.read())<<7;
          //For middle 7 Bits
          while(serial.available()==0);
          data= (data|serial.read())<<7;
          //For last 7 Bits
          while(serial.available()==0);
          data= (data|serial.read());
          // if the first MSB has set bit then the Val is negative
          if(data>32767) data= data| negativeConversion;
          println("AnalogVal0:"+data);
          plot1.addPoint(relativeTime,data);
          cp5.getController("Pitch").setValue(data);
          break;

        case DigitalVal0:
          while(serial.available()==0);
          data=serial.read();
          println("DigitalVal0:"+data);
          plot2.push("digitalData", data);
          break;
      }
    }
  }

  bpm = int(cp5.getController("BPM").getValue());

  relativeTime+=1;
  //Draw the first plot
  //plot1.activatePanning();
  plot1.beginDraw();
  plot1.drawBackground();
  plot1.drawBox();
  plot1.drawXAxis();
  plot1.drawYAxis();
  plot1.drawTitle();
  plot1.drawGridLines(GPlot.BOTH);
  plot1.drawLines();
  plot1.endDraw();

}
