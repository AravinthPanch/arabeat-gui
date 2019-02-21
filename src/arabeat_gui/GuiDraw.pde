int sequenceLength= 12;
PImage[] animationSequence = new PImage[sequenceLength+1];
int lastFrame= 1;
int lastTime=1;
int bpm= 80;
boolean isPortChoosen = false;


void createAnimation(int bpm){
  int timeDiff =  millis() - lastTime;
  int requiredTimeDiff = int((60*1000)/(bpm*sequenceLength));
  image(animationSequence[lastFrame], width*0.55+120,height*0.45+180);
  if(timeDiff>=requiredTimeDiff){
    //change frame
    lastTime= millis();
    lastFrame= (lastFrame%sequenceLength)+1;
  }
}

void controlEvent(ControlEvent theEvent) {
  
  if(theEvent.isController() &&  (theEvent.getController().getName()).equals("baudrate")){
    int index = int(theEvent.getController().getValue());
    baudrate = baudrateList[index];
    println("Baudrate Choosen : "+ baudrate);
  }
  else if (theEvent.isController() &&  (theEvent.getController().getName()).equals("choosePort")) {
    int portNumber= int(theEvent.getController().getValue());
    portName = Serial.list()[portNumber];
    println("Port Choosen : "+ portName);
    serial = new Serial(this, portName, baudrate);
    isPortChoosen = true;
  }
  
}

void graph2Plot(int val){
 println("DigitalVal0:"+val);
          plot2.push("digitalData", val);
          cp5.getController("digitalVal0").setValue(val);
}

void graph1Plot(int val){
    while(plot1.getPointsRef().getNPoints()>cp5.getController("timeScale").getValue()){
           plot1.removePoint(0);
        }
    println("AnalogVal0:"+val);    
    plot1.addPoint(relativeTime,val);
    relativeTime+=1;
    cp5.getController("analogVal0").setValue(val);    
  
}

void GUIDraw(){
 
  //image(animationSequence[1], 1000, 150);
  // Add Header Image
  image(headerImage, (width/2)-125 , 10);
  createAnimation(bpm);
  bpm = int(cp5.getController("BPM").getValue());

  //Draw the first plot
  //plot1.activatePanning();
  plot1.beginDraw();
  plot1.setDim(width*0.55,height*0.45);
  plot1.setPos(10, headerImage.height+10);
  plot1.drawBackground();
  plot1.drawBox();
  plot1.drawXAxis();
  plot1.drawYAxis();
  plot1.drawTitle();
  plot1.drawGridLines(GPlot.BOTH);
  plot1.drawLines();
  plot1.endDraw();
  
  plot2.setPosition(73, headerImage.height+height*0.45+85)
       .setSize(int(width*0.56), int(height*0.20));
 
  accordion.setPosition(width*0.68,headerImage.height+50);
  
  
}
