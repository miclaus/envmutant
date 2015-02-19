/**
 * environment mutant (body)
 *
 * @author iosif miclaus
 * @www iosif.miclaus.com/#environment-mutant
 *
 * @note PWM Pulse-width modulation http://en.wikipedia.org/wiki/Pulse-width_modulation
 * @note "body part" represents anything that is a controllabe part of the body (e.g. a slider door)
 */

// include servo library
#include <Servo.h> 


/// constants

const int LED = 3;
const int MOTOR = 10;
const int maxLastInput = 71;

/// constants end


/// vars

Servo servoMotor;

int lastInput = maxLastInput;

/// vars end


/**
 * initalises environmental mutant "body"
 */
void setup () 
{
  // start serial communication
  Serial.begin(9600);
  
  // attach digital (PWM) pin for light indicator (LED)
  pinMode(LED, OUTPUT);
  
  // "Let there be light,"
  digitalWrite(LED, HIGH);
  // "and there was light." (Genesis 1:3)
  
  // attach digital (PWM) pin for servo motor
  servoMotor.attach(MOTOR);
  // move body piece to start position
  servoMotor.write(maxLastInput);
}


/**
 * runs each frame for the environmental mutant "body"
 */
void loop () 
{
  // read the current body part value
  int sliderPotiValue = analogRead(A0);
  // reverse poti value
  // @note this line is not needed of the potentiomenter is the other way around
  sliderPotiValue = 1023 - sliderPotiValue;
  //Serial.println(sliderPotiValue);
  
  
  // if serial data is available
  if ( Serial.available() > 0 ) 
  {
    // read serial data
    byte input = Serial.read(); 
    //Serial.print(input);
    
    // the mind tells the body is's a new recording
    if ( input == 'n' ) 
    {
      // body should signal that it's new recording
      blink_blink_blink();
    }
    
    
    // the mind tells the body to move to a position/degree
    if ( input > 0 && input < maxLastInput ) 
    {
      // body signals movement
      digitalWrite(LED, HIGH);
      
      // remember position/degree to move to
      lastInput = input;
    }
    else 
    {
      // body stops signaling movement
      digitalWrite(LED, LOW);
    }
    
    // move body part to position/degree 
    servoMotor.write(lastInput);
  }
 
  // wait to finish body part movement
  delay(30);
}


/**
 * body sends 3 short signals (usually for a new recording)
 */
void blink_blink_blink () 
{
  digitalWrite(LED, LOW);
  delay(500);
  
  for ( int c = 0; c < 3; c++ ) 
  {
    digitalWrite(LED, HIGH);
    delay(100);
    
    digitalWrite(LED, LOW);
    delay(50);
  }
  
  digitalWrite(LED, HIGH);
}

/// that's all folks
