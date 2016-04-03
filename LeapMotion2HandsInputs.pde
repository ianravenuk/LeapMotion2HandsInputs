
import de.voidplus.leapmotion.*;

import oscP5.*;
// Originally adapted from https://github.com/nok/leap-motion-processing/blob/master/examples/e1_basic/e1_basic.pde
// By Rebecca Fiebrink?
//
// Modified by Ian Raven to remove finger information but add data for both hands instead
// Sends 18 features ((x,y,z) position, (x, y, z) rotation,  grab strenth, pinch strength and number of outstretched fingers for each hand) to Wekinator
// Also removed a lot of code from the original example that wasn't actually doing anything - so this is now more compact, to the point and understandable :-)
// Sends to port 6448 using /wek/inputs OSC message
// Also sends all input names to Wekinator (run Wekinator, hit listen in the new project dialog box and then run this code for this to work)

import netP5.*;

int num=0;
OscP5 oscP5;
NetAddress dest;
LeapMotion leap;
int numFound = 0;
boolean oneHandisLeft = false;

float[] featuresL = new float[9];
float[] featuresR = new float[9];

void setup() {
  size(800, 500, OPENGL);
  background(255);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);

  leap = new LeapMotion(this);
  sendInputNames();
}

void draw() {
  background(255);

  // ========= HANDS =========
  numFound = 0;
  for (Hand hand : leap.getHands ()) {
      numFound++;

    boolean hand_is_left     = hand.isLeft();
    boolean hand_is_right    = hand.isRight();   

    if (hand_is_left) //<>//
      oneHandisLeft = true;
    else
      oneHandisLeft = false;

    if (hand_is_left) {
      PVector hpos = hand.getPosition();
      featuresL[0] = hpos.x;
      featuresL[1] = hpos.y;
      featuresL[2] = hpos.z;
      PVector hdyn = hand.getDynamics();
      featuresL[3] = hdyn.x;
      featuresL[4] = hdyn.y;
      featuresL[5] = hdyn.z;
      float hgrab = hand.getGrabStrength();   
      featuresL[6] = hgrab;
      float hpin = hand.getPinchStrength();   
      featuresL[7] = hpin;
      float NumOutstretchedFingers = hand.getOutstretchedFingers().size();
      featuresL[8] = NumOutstretchedFingers;
    }
    else if (hand_is_right) {
      PVector hpos = hand.getPosition();
      featuresR[0] = hpos.x;
      featuresR[1] = hpos.y;
      featuresR[2] = hpos.z;
      PVector hdyn = hand.getDynamics();
      featuresR[3] = hdyn.x;
      featuresR[4] = hdyn.y;
      featuresR[5] = hdyn.z;
      float hgrab = hand.getGrabStrength();   
      featuresR[6] = hgrab;
      float hpin = hand.getPinchStrength();   
      featuresR[7] = hpin;
      float NumOutstretchedFingers = hand.getOutstretchedFingers().size();
      featuresR[8] = NumOutstretchedFingers;
    }      

    // ----- DRAWING -----
    hand.draw();
  }

  // =========== OSC ============
  if (num % 3 == 0) {
     sendOsc();
  }
  num++;
}


//====== OSC SEND ======
void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");

  switch(numFound) {
    case 0:
      for (int i = 0; i < featuresL.length; i++) {
        msg.add(0.);
      }
      for (int i = 0; i < featuresR.length; i++) {
        msg.add(0.);
      }
      break;
      
    case 1: 
        if (oneHandisLeft) {           //<>//
          for (int i = 0; i < featuresL.length; i++) {
            msg.add(featuresL[i]);
          }
          for (int i = 0; i < featuresR.length; i++) {
            msg.add(0.);
          }
        }
        else {
          for (int i = 0; i < featuresL.length; i++) {
            msg.add(0.);
          }
          for (int i = 0; i < featuresR.length; i++) {
            msg.add(featuresR[i]);
          }
        }
        break;
    
    case 2: 
        for (int i = 0; i < featuresL.length; i++) {
          msg.add(featuresL[i]);
        }
        for (int i = 0; i < featuresR.length; i++) {
          msg.add(featuresR[i]);
        }
        break;  
  }
  
  oscP5.send(msg, dest);
}

void sendInputNames() {
   OscMessage msg = new OscMessage("/wekinator/control/setInputNames");

   msg.add("L Hand Pos X"); 
   msg.add("L Hand Pos Y"); 
   msg.add("L Hand Pos Z"); 
   msg.add("L Hand Rot X"); 
   msg.add("L Hand Rot Y"); 
   msg.add("L Hand Rot Z"); 
   msg.add("L Hand Grab Str");
   msg.add("L Hand Pin Str");
   msg.add("L Hand Num Fing");
   
   msg.add("R Hand Pos X"); 
   msg.add("R Hand Pos Y"); 
   msg.add("R Hand Pos Z"); 
   msg.add("R Hand Rot X"); 
   msg.add("R Hand Rot Y"); 
   msg.add("R Hand Rot Z"); 
   msg.add("R Hand Grab Str");
   msg.add("R Hand Pin Str");
   msg.add("R Hand Num Fing");
      
   oscP5.send(msg, dest);   
   println("Sent input names");
}