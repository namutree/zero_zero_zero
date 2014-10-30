

// Elie Zananiri
// Depth thresholding example
// http://www.silentlycrashing.net

import org.openkinect.*;
import org.openkinect.processing.*;
//for sound
import ddf.minim.*;

//////////Syphon////////////////////////////////////////////////////
import codeanticode.syphon.*;
import codeanticode.syphon.*;
PGraphics canvas;
SyphonServer server;
///////////////////////////////////////////////////////////////

/////sound//////////////////
Minim minim;
AudioPlayer sDeathImage;
AudioPlayer godSpeed;
float randomMusic;
//////////////////////////////////

//// serial Communication//////////
float value;
float value1, value2;
import processing.serial.*;     // import the Processing serial library
Serial myPort;                  // The serial port
/////////////////////////////////////

Kinect kinect;
int kWidth  = 640 ;
int kHeight = 480;
int kAngle  =  15;

PImage depthImg;
PImage backImg1;
int minDepth =  60;
int maxDepth = 860;

PImage backImg;

float alphaValue;
float absoluteValue; 

void setup() {
  //size(100, 100);
  size(displayWidth, displayHeight,P3D);

  //Syphon
  canvas = createGraphics(displayWidth, displayHeight, P3D);
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");

  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(true);
  kinect.tilt(kAngle);

  depthImg = new PImage(kWidth, kHeight);

//  backImg = loadImage("door_paint.png");
//  backImg1 = loadImage("door_out.png");
 backImg = loadImage("door_3-01.png");
  backImg1 = loadImage("door_3-02.png");

  ///////////serial Communication/////////////////////
  println(Serial.list());
  String portName = Serial.list()[5];
  myPort = new Serial(this, portName, 9600);
  // read bytes into a buffer until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');
  ////////////////////////////////

  ///////////sound initailization///////////////
  minim = new Minim(this);
  sDeathImage= minim.loadFile("001_Death Image.mp3");
  godSpeed = minim.loadFile("godspeed.mp3");
  ////////////////////////////////////////////////

  value1 = 0;
  value2 = 0;
}

void draw() {
  background(255, 251, 209, 100);
  // draw the raw image
  //image(kinect.getDepthImage(), 0, 0);



  // threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < kWidth*kHeight; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      //people color
      depthImg.pixels[i] = 0x958e72;
      //depthImg.pixels[i] = 0xA99F88;
    } 
    else {
      //background color
      depthImg.pixels[i] = 0xfdf8cf;
    }
  }


  // draw the thresholded image
  depthImg.updatePixels();

  //begin syphon
  canvas.beginDraw();
  
  canvas.image(depthImg, (width-kWidth)/2, (height-kHeight)/2);
  int radius=35;
  for (int i=0; i < kWidth*kHeight-1; i++) {
    ///////////// at the boarder draw a circle/////////////////
    if (abs(depthImg.pixels[i+1]-depthImg.pixels[i])>0) {
      canvas.fill(255, 251, 209, 50);
      canvas.noStroke();
      canvas.ellipse(i%kWidth+random(-20, 20)+(width-kWidth)/2, ceil(i/kWidth)+random(-20, 20)+(height-kHeight)/2, radius, radius);
    }
    //////////////////////////////////////////////////
  }

  // door background!!!//////////
  int aa = int(random(5,100));
  backImg.resize(0, kHeight );
  backImg1.resize(kWidth+aa, kHeight+aa);
  canvas.image(backImg, (width-kWidth)/2, (height-kHeight)/2);
  canvas.image(backImg1, (width-kWidth)/2-aa/2, (height-kHeight)/2-aa/2);
  //backImg1.resize(1754,1240);
 
  ////////////////////////////////

  ///// fill the boundary with balck//////////////////////
  canvas.fill(0);
  canvas.rect(0, 0, width, (height-kHeight)/2);
  canvas.rect(0, 0, (width-kWidth)/2, height);
  canvas.rect(0, (height-kHeight)/2+kHeight, width, (height-kHeight)/2);
  canvas.rect((width-kWidth)/2+kWidth, 0, (width-kWidth)/2, height);
  ///////////////////////////////////////////////////////////

  //////////////// screening and start////////////////////////////////
  alphaValue += value*0.5+3;
  absoluteValue += (alphaValue-absoluteValue)*0.1;
  if (absoluteValue>0) {
    canvas.fill(0, 0, 0, map(absoluteValue, 0, 255, 255, 0));
    canvas.rect(0, 0, width, height); 
    if (randomMusic<0.5) sDeathImage.play();
    else godSpeed.play();
  } 
  else {
    canvas.fill(0, 0, 0);
    canvas.rect(0, 0, width, height); 
    sDeathImage.pause();
    sDeathImage.rewind();
    godSpeed.pause();
    godSpeed.rewind();
    randomMusic= random(1);
  }
  
    //finish syphon
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
  
  alphaValue -=1;
  if (alphaValue<0) 
  {
    alphaValue=0;
    absoluteValue=0;
  }
  if (alphaValue>120) alphaValue-=0.5;
  if (alphaValue>255) alphaValue-=1;
  if (alphaValue>300) {
    alphaValue=300;
    absoluteValue=300;
  }
  println("absoluet: "+absoluteValue+"alphaValue: "+alphaValue+", value: "+ value);
  ///////////////////////////////////////////////////////////////////////////



  text("TILT: " + kAngle, 10, 20);
  text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
   tint(0, 0, 204,50);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      kAngle++;
    } 
    else if (keyCode == DOWN) {
      kAngle--;
    }
    kAngle = constrain(kAngle, 0, 30);
    kinect.tilt(kAngle);
  }

  else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } 
  else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  }

  else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } 
  else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  } 
  else if (key =='p') {
    absoluteValue=0;
    alphaValue=0;
  }
}

void stop() {
  kinect.quit();
  super.stop();
}

void serialEvent(Serial myPort) { 
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');

  value= float(myString);
  // print out the values you got:
  //println("Sensor: "  + value);
}

