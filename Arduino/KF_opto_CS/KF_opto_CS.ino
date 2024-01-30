//#include "toneAC.h"
#include <TimerOne.h>

/*
  Conditioning
  to regulate camera, CS (LED, tone, whisker puff, ...), US.
 */

// Outputs 
int camera = 8;
int puff = 13;
int opto = 10;
int optoRead = 3;

// Used internally to select channels for CS/US
int csout = 0;  // Not used yet
int usout = 0;  // Used for 2nd order conditioning to use "US" as CS2

// Task variables (time in ms, freq in hz)
int campretime = 200;
int camposttime = 800;
int csdur = 250;
int csch = 1;   // default to LED
int usch = 3;   // default to ipsi corneal puff
int ISI = 140;
int usdur = 30;
int residual;
int tonefreq5 = 5000;

unsigned long trialtime = 0; // For keeping track of elapsed time during trial

// the setup routine runs once when you press reset:
void setup() {
  // initialize the digital pin as an output.
  pinMode(camera, OUTPUT);
  pinMode(puff, OUTPUT);
  pinMode(opto, OUTPUT);
  pinMode(optoRead, INPUT);

  // Default all output pins to LOW - for some reason they were floating high on the Due before I (Shane) added this
  digitalWrite(camera, LOW);
  digitalWrite(puff, LOW);
  digitalWrite(opto, LOW);

  Serial.begin(115200);
}

// the loop routine runs over and over again forever:
void loop() {
  // Consider using attachInterrupt() to allow better realtime control of starting and stopping, etc.

  checkVars();
  if (Serial.available() > 0) {
    if (Serial.peek() == 1) { // This is the header for triggering; difference from variable communication is that only one byte is sent telling to trigger
      Serial.read();  // Clear the value from the buffer
      Triggered();
    }
  }
  delay(1);
}


// Check to see if Matlab is trying to send updated variables
void checkVars() {
  int header;
  int value;
  // Matlab sends data in 3 byte packets: first byte is header telling which variable to update,
  // next two bytes are the new variable data as 16 bit int
  // Header is coded numerically such that 1=trigger, 2=continuous, 3=CS channel, 4=CS dur,
  // 0 is reserved for some future function, possibly as a bailout (i.e. stop reading from buffer).
  while (Serial.available() > 2) {
    header = Serial.read();
    value = Serial.read() | Serial.read() << 8;

    if (header == 0) {
      break;
    }

    switch (header) {
      case 3:
        campretime = value;
        break;
      case 4:
        csch = value;
        break;
      case 5:
        csdur = value;
        break;
      case 6:
        usdur = value;
        break;
      case 7:
        ISI = value;
        break;
      case 8:
        tonefreq5 = value;
        break;
      case 9:
        camposttime = value;
        break;
      case 10:
        usch = value;
        break;
    }
    delay(4); // Delay enough to allow next 3 bytes into buffer (24 bits/9600 bps = 2.5 ms, so double it for safety).
  }
}


// --- function executed to start a trial ----
void Triggered() {
  unsigned long now;
  // triggering camera
  digitalWrite(camera, HIGH);  // Camera will collect the number of frames that we specify while TTL is high

  // NOTE: I removed the single short pulse because camera is now configured for "TTL High" instead of "Rising-Edge"
  //  delay(1);
  //  digitalWrite(camera, LOW);
  //  residual=campretime-1;
  residual = campretime;
  if (residual > 0) {
    delay(residual);          // wait
  }

  // starting a trial
  trialtime = millis();

  doDelay();

  now = millis();
  if (now - trialtime < camposttime) {
    //delay(int(now - trialtime));
    delay(camposttime - int(now - trialtime));
  }

  // Camera will only collect the number of frames that we specify so we only have to reset TTL
  // to low before starting the next trial. The hitch is that if we set it low too early we won't
  // collect all of the frames that we asked for and the camera will get stuck; hence the extra delay.
  delay(10); // Delay a little while longer just to be safe - so the camera doesn't get stuck with more frames to acquire
  digitalWrite(camera, LOW);
}

void doDelay() {

  csON();

  delay(ISI); 

  usON();
  
  if (csdur < (ISI+usdur)) {
   delay(csdur-ISI);
   csOFF();
   residual = usdur - (csdur-ISI);
  }
  else {
    residual = usdur;
  }   
  
  delay(residual);                  // wait for remainder of us (or all if cs is longer)
  
  usOFF();

  residual = csdur - ISI - usdur;

  if (residual > 0) {
    delay(residual);          // wait for whatever additional time cs is on
  }

  csOFF();

}

void csON() {
 if (csdur > 0) {
    switch (csch) {
      case 1:
        Timer1.initialize(3300); //t = 1/f //time interval in microseconds
        Timer1.pwm(opto, 50); //sends pulse to this pin with 50% duty cycle
        break;
    }
  } 
}


void csOFF() {
     if (csdur > 0) {
    switch (csch) {
      case 1:
        Timer1.disablePwm(opto);
        break;
    }
  }
}

void usON() {
    if (usdur > 0) {

    switch (usch) {
      case 1:
        usout = puff;
        break;
      default:
        usout = 0;
    }
  }

  if (usout > 0) {
  digitalWrite(usout, HIGH);   // turn the PUFF on (HIGH is the voltage level)
  }
}

void usOFF() { 
  if (usout > 0) {
  digitalWrite(usout, LOW);    // turn the PUFF off (HIGH is the voltage level)
  }
}
