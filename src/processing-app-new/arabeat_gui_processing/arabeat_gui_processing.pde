
import processing.serial.*;
import grafica.*;
import controlP5.*;

Serial serial;
int baudRate=9600;

PImage headerImage;

public GPlot plot1;
public GPointsArray plotData1;
int plotHeight1= 300;
int plotWidth1= 500;
int relativeTime= 0;
float currentAmplitude= 0;

ControlP5 cp5;
Accordion accordion;

void settings() {
  fullScreen();
}

void setup() 
{
  background(255);
  noStroke();
  smooth();
  //surface.setResizable(true);
  
  // Start 
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, baudRate);
  
  // Add the Header Image to the Canva
  headerImage = loadImage("arabeat.png"); 
  headerImage.resize(250, 0);
  
  
  // Setup for the first plot 
  plot1 = new GPlot(this);
  plot1.setPos(10, headerImage.height+10);
  plot1.setDim(plotWidth1, plotHeight1);
  plot1.getTitle().setText("Frequency");
  plot1.getXAxis().getAxisLabel().setText("Time");
  plot1.getYAxis().getAxisLabel().setText("Amplitude");
  
  
  // List Setup     lock()             
  cp5 = new ControlP5(this);
  
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
     
  cp5.addSlider("BPM")
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
 
}


void draw()
{
  //To Refresh the Background
  background(255);
  
  // Add Header Image
  image(headerImage, (width/2)-125 , 10);
  if ( serial.available() > 0) {  
    String val = serial.readString();
    currentAmplitude = float(val);
    print(currentAmplitude+" "+val+"\n");
    if(!Float.isNaN(currentAmplitude))
    {
      plot1.addPoint(relativeTime,currentAmplitude);
    }
    
  }
  
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
