int button_input = 2;
#define INPUT_SIZE 30
int motors[] = {10,9,3,5};

int fadeMotor[] = {-1,0,0};
int motorPwm[] = {0,0,0,0};

void setup()
{
    Serial.begin(9600);
    pinMode(3,OUTPUT);
    pinMode(5,OUTPUT);
    pinMode(9,OUTPUT);
    pinMode(10,OUTPUT);
    pinMode(2,INPUT);

}

void motorFade(int motorNo,int pwm,int delay1){

  int counter_loop  = 0;

  
  Serial.println(motorNo);
  int brightness = 0;    // how bright the LED is
  int fadeAmount = 10; 


  while(counter_loop<100){
  analogWrite(motorNo, brightness);
  brightness = brightness + fadeAmount;


  if (brightness <= 0 || brightness >= pwm) {
    fadeAmount = -fadeAmount;
  }
  delay(delay1);
  counter_loop++;
  }
  delay(100);
 fadeMotor[0] = -1;
 }

void loop() {


if (digitalRead(2)==HIGH){
  Serial.println("1");
  }


if (Serial.available()!=0){

char input[INPUT_SIZE + 1];
byte size = Serial.readBytes(input, INPUT_SIZE);
// Add the final 0 to end the C string
input[size] = 0;

// Read each command pair 
char* command = strtok(input, "&");
int counter =0;
while (command != 0)
{

    
    char* separator = strchr(command, ':');
    if (separator != 0)
    {
        // Actually split the string in 2: replace ':' with 0
        *separator = 0;
        int pwm = atoi(command);
        ++separator;
        int delay1 = atoi(separator);

        if (delay1 !=0){
          fadeMotor[0] = motors[counter];
          fadeMotor[1] = pwm;
          fadeMotor[2] = delay1;
          
          motorPwm[counter] = 0;
          
          }
        else{
          motorPwm[counter] = pwm;
          }
        
    }
    command = strtok(0, "&");
    counter++;
}
analogWrite(motors[0],motorPwm[0]);
analogWrite(motors[1],motorPwm[1]);
analogWrite(motors[2],motorPwm[2]);
analogWrite(motors[3],motorPwm[3]);


if (fadeMotor[0]!=-1)
{ 

  motorFade(fadeMotor[0],fadeMotor[1],fadeMotor[2]);
  fadeMotor[0]=-1;
}

}
}
