/**
 * environment mutant (mind)
 *
 * @author iosif miclaus
 * @www iosif.miclaus.net/#environment-mutant 
 */
 
import processing.serial.*;
import SimpleOpenNI.*;

//import java.util.Collections;


/// constants

final int FPS = 12;
final boolean mirror = true;
final int winWidth = 800, winHeight = 600;
final int hWinWidth = winWidth/2, hWinHeight = winHeight/2;
final int controlWidth = 200, controlHeight = 40;
final int handDotWH = 10;
final int hControlWidth = controlWidth/2;
final int controlXPos = hWinWidth - hControlWidth;
final int controlYPos = hWinHeight;

/// constants end


/// vars

SimpleOpenNI kinect;
PImage fgImg, kinectDepthImage;

float centerX, centerY;

Serial myPort;

PVector handPos = null;
boolean showControls = false;

boolean recording = false;
int lastRecordedActionIndex = 0;
ArrayList<Integer> recordedAction = new ArrayList<Integer>();

/// vars end


/**
 * initalises environmental mutant "mind"
 */
void setup () 
{
  //frameRate(FPS);
  
  // loads the foreground image
  fgImg = loadImage("fg.png");
  
  // kinect with SimpleOpenNI context
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.setDepthImageColor(241, 12, 73);
  
  // point of view / perspective
  kinect.setMirror(mirror);
  
  // starts looking for hand gestures 
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);
  
  // "clone" variables to use in different context (therefore the different name)
  centerX = hWinWidth;
  centerY = hWinHeight;
  
  // size the interface window
  size(winWidth, winHeight);
  
  
  // uncomment noLoop() if you want to start the program manually
  // @see keyReleased() for assigned keys
  //noLoop();
  
  // the cursor only stands in the way (comment out if you want to see the cursor)
  noCursor();
  
  // uncomment this block print all possible serials
  /*String serials[] = Serial.list();
  for (int i = 0; i < serials.length; i++) 
  {
    println(serials[i]);
  }*/
  
  
  // choose the serial port to work with
  // here it's chosen manually, use the previous block to find your appropiate port 
  
  //String portName = Serial.list()[2];
  //myPort = new Serial(this, portName, 9600);
  myPort = new Serial(this, "/dev/tty.usbmodem1431", 9600);
}


/**
 * runs each frame for the environmental mutant "mind"
 */
void draw () 
{
  // kinect.enableDepth();
   
  kinect.update();
  
  // draw kinect image (depthImageMap)
  kinectDepthImage = kinect.depthImage();
  imageMode(CENTER);
  image(kinectDepthImage, centerX, centerY);
  
  // draw foreground image
  imageMode(CORNER);
  image(fgImg, 0, 0);
  
  
  // shows the field for controlling the environment 
  if ( showControls ) 
  {
    noStroke();
    //fill(130, 30, 200);
    fill(130, 30, 200, 77.7);
    rect(controlXPos, controlYPos, controlWidth, controlHeight);
  }
  
  
  // draw a circle representing virtual position of the hand
  if ( handPos != null ) 
  {
    noStroke();
    fill(0, 200, 0);
    
    float actualHandPosX = handPos.x + hWinWidth;
    float actualHandPosY = hWinHeight - handPos.y;
    
    ellipse(actualHandPosX, actualHandPosY, handDotWH, handDotWH);
  }
  
  
  // creator signature ;)
  //fill(241, 12, 73);
  fill(130, 29, 198);
  int whoY = winHeight-100;
  text("#envmutant", 100, whoY);
  text("by iosif miclaus", winWidth-150, whoY);
  // thank you, jesus loves you
}


/**
 * key realeased listener
 */
void keyReleased () 
{
  switch ( key ) 
  {
    // pauses looping
    case '0' : noLoop(); break;
    
    // continues looping
    case '1' : loop(); break;
    
    // ...  
    default  : break;
  }
  
  // ...
}


/**
 * as soon as a gesture is recognized
 */
void onCompletedGesture (SimpleOpenNI context, int gestureType, PVector pos)
{
  //println("type: " + gestureType + ", pos: " + pos);
  
  // switch between gestures
  switch ( gestureType ) 
  {
    // wave gesture
    // SimpleOpenNI.GESTURE_WAVE
    case 0 :
      // start or stop recording
      recording = ! recording;
      
      // new recording
      if ( recording ) 
      {
        // prepare steps buffer, overrides old steps
        recordedAction = new ArrayList<Integer>();
        
        println("New recording.");
        
        // tell environment mutant body it's a new recording
        myPort.write('n');
      }
      else 
      {
        println("Finished recording.");
        
        // reverse the action 
        // uncomment this if you want the action to be played as recorded and not in reverse
        // @note don't be confused, obviously it will jump at the first recorded position 
        //        and then continue the rest of the steps
        //Collections.reverse(recordedAction);
        
        // replay steps
        for ( int n = recordedAction.size()-1; n >= 0; n-- ) 
        {
          // get the value at step n from steps buffer
          int servoValue = recordedAction.get(n);
          
          // tell environment mutant body to move at certain position
          myPort.write(servoValue);
        }
      }
      break;
      
    // SimpleOpenNI.GESTURE_HAND_RAISE
    case 2 :
      // starts tracking new hand
      int handId = kinect.startTrackingHand(pos);
      break;
      
    default :
      // unknown gesture
      println("Gesture not found."); 
      break;
  }
}


/** 
 * as soon as a new hand is recognized
 */
void onNewHand (SimpleOpenNI context, int handId, PVector pos)
{
  //println("ID: " + handId + " ->");
  //println("pos: " + pos);
  
  // remember to show the controls
  showControls = true;
}


/** 
 * whilst tracking hand
 */
void onTrackedHand (SimpleOpenNI context, int handId, PVector pos)
{
  //println("pos: " + pos);
  
  handPos = pos;
  
  float actualHandPosX = handPos.x + hWinWidth;
  float actualHandPosY = hWinHeight - handPos.y;
  
  int controlXPosEnd = controlXPos + controlWidth;
  int controlYPosEnd = controlYPos + controlHeight;
  
  // check if the position of the virtual hand marker is in the control field
  if (actualHandPosX > controlXPos && actualHandPosX < controlXPosEnd && 
      actualHandPosY > controlYPos && actualHandPosY < controlYPosEnd) 
  {
    // if not yet recording, start recording
    if ( ! recording ) 
    {
      recording = true;
    }
    
    // translate the virtual hand marker to the servo position/degree
    int servoValue = floor(map(actualHandPosX, controlXPos, controlXPosEnd, 0, 70));
    //println(servoValue);
    
    // tell environment mutant body to move at certain position
    myPort.write(servoValue);
    
    // remember action step in steps buffer
    recordedAction.add(servoValue);
  }
  
  // remember to show the control field
  showControls = true;
}


/** 
 * as soon as hand is lost
 */
void onLostHand (SimpleOpenNI context, int handId)
{
  // remember to hide the control field
  showControls = false;
}

/// that's all folks
