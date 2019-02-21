import grafica.*;
import controlP5.*;

public GPlot plot1;
public GPointsArray plotData1;
int plotHeight1= 250;
int plotWidth1= 450;

PImage headerImage;

ControlP5 cp5;
Accordion accordion;
Chart plot2;

DropdownList choosePortDropdown, baudrateDropdown;
int baudrateList[] = {9600, 31250, 115200};

void setupGUI(){
  noStroke();
  smooth();
  surface.setResizable(true);
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
  
  // Setup for the first plot
  plot1 = new GPlot(this);
  plot1.setPos(10, headerImage.height+10);
  plot1.setDim(plotWidth1, plotHeight1);
  plot1.getXAxis().getAxisLabel().setText("Time");
  plot1.getYAxis().getAxisLabel().setText("Analog Val0");


  // List Setup
  Group accordionGroup1 = cp5.addGroup("Configuration")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(20)
                .setHeight(10);
                
 cp5.addSlider("timeScale")
     .setPosition(10,30)
     .setSize(100,20)
     .setCaptionLabel("Time Scale")
     .setRange(0,500)
     .setValue(20)
     .setMin(0)
     .setMax(500)
     .moveTo(accordionGroup1);               
              
                
  baudrateDropdown = cp5.addDropdownList("baudrate")
                  .setPosition(110, 10)
                  .setBackgroundColor(color(190))
                  .setItemHeight(20)
                  .setWidth(60)
                  .setBarHeight(15)
                  .moveTo(accordionGroup1)
                  .setColorActive(color(255, 128))
                  .setCaptionLabel("Baudrate")
                  .setOpen(false); 
  
  for (int i=0;i<baudrateList.length;i++) {
    baudrateDropdown.addItem(Integer.toString(baudrateList[i]), i);
  }
  
  choosePortDropdown = cp5.addDropdownList("choosePort")
                  .setPosition(10, 10)
                  .setWidth(90)
                  .setBackgroundColor(color(190))
                  .setItemHeight(20)
                  .setBarHeight(15)
                  .setColorActive(color(255, 128))   
                  .moveTo(accordionGroup1)
                  .setCaptionLabel("Choose Port")
                  .bringToFront() 
                  .setOpen(false); 

  for (int i=0;i<(Serial.list()).length;i++) {
    choosePortDropdown.addItem(Serial.list()[i], i);
  }

  


  Group accordianGroup2 = cp5.addGroup("midiData")
                .setLabel("Midi Data")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(50);

  cp5.addSlider("analogVal0")
     .setLabel("Analog Val0")
     .setPosition(10,10)
     .setSize(100,20)
     .setRange(-pow(2,16),+pow(2,16))
     .lock()
     .setValue(100)
     .moveTo(accordianGroup2);

  cp5.addSlider("digitalVal0")
     .setLabel("Analog Val0")
     .setPosition(10,40)
     .setSize(100,20)
     .setRange(0,1)
     .setValue(0)
     .lock()
     .setMin(0)
     .setMax(1)
     .moveTo(accordianGroup2);
     
 cp5.addSlider("BPM")
     .setPosition(10,70)
     .setSize(100,20)
     .moveTo(accordianGroup2)
     .setColorCaptionLabel(color(0,64))
     .setRange(0,200)
     .setValue(80);    

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("Data")
                 .setPosition(plotWidth1+120,headerImage.height+50)
                 .setWidth(200)
                 .addItem(accordionGroup1)
                 .addItem(accordianGroup2);


  accordion.open(0,1);
  accordion.setCollapseMode(Accordion.MULTI);

  // Second Plot
  plot2 = cp5.addChart("DigitalHeartBeat")
               .setPosition(60, plotHeight1+200)
               .setSize(470, 100)
               .setRange(-0.5, 1.5)
               .setView(Chart.LINE)
               .setStrokeWeight(1.5)
               .setColorCaptionLabel(color(40));

  plot2.addDataSet("digitalData");
  plot2.setData("digitalData", new float[100]);

  
  
}
