#include <TimerOne.h>

//Variables
int led = 10; //generates pulse signal
int ledRead = 3; //reads generated pulse signal

int values = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(led, OUTPUT);
  pinMode (ledRead, INPUT);
  digitalWrite(led, LOW);

  Timer1.initialize(3300); //t = 1/f //time interval in microseconds
  
}

void loop() {
  // put your main code here, to run repeatedly:
//  digitalWrite(led, HIGH);
//  delay(1000);
//  digitalWrite(led, LOW);
//  delay(1000);

Timer1.pwm(led, 50); //sends pulse to this pin with 50% duty cycle
delay(3000);
Timer1.disablePwm(led);
delay(3000);

}
