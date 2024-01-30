int solenoidPin = 13;

void setup() {
  // put your setup code here, to run once:
  pinMode(solenoidPin, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(solenoidPin, HIGH); //ON
  delay(1000);
  digitalWrite(solenoidPin, LOW); //OFF
  delay(1000);
}
