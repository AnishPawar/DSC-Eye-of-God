#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer* pServer = NULL;
#define INPUT_SIZE 30
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t value = 0;

//================ Motor Init================
int brightness = 0;    
int fadeAmount = 5;
#define INPUT_SIZE 30
int motors[] = {25,26,12,14};

int fadeMotor[] = {-1,0,0};
int motorPwm[] = {0,0,0,0};
const int freq = 5000;


int motorChannels[] = {0,1,2,3};
const int resolution = 10;

//================ Motor Init================




BLECharacteristic *characteristicTX;
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"


class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};


//================ Motor Fade================
void motorFade(int motorNo,int pwm,int delay1){

  int counter_loop  = 0;

  Serial.println("Motor is:");
  Serial.println(motorNo);
  int brightness = 0;
  int fadeAmount = 10; 


  while(counter_loop<100){
  ledcWrite(motorChannels[motorNo],brightness);
  brightness = brightness + fadeAmount;


  if (brightness <= 0 || brightness >= pwm) {
    fadeAmount = -fadeAmount;
  }
  delay(delay1);
  counter_loop++;
  }
  delay(100);
 fadeMotor[0] = -1;
 ledcWrite(motorChannels[motorNo],0);
 }
//================ Motor Fade================



class CallBacks: public BLECharacteristicCallbacks{
    void onWrite(BLECharacteristic *pCharacteristic){
      std::string value = pCharacteristic->getValue();
      if(value.length()>0)
      {
        

      char input[INPUT_SIZE + 1];
      byte size = value.length();
//      input = value.copy();
      strcpy(input, value.c_str());
      input[size] = 0;
      
      // Read each command pair 
      char* command = strtok(input, "&");
      Serial.println("Printing COmmand");
      Serial.println(command);
      
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
            fadeMotor[0] = motorChannels[counter];
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

      Serial.println("Motor1 Intent:");
      for(int i=0; i < value.length(); i++){
        Serial.print(value[i]);
      }
      ledcWrite(motorChannels[0],motorPwm[0]);
      Serial.println("Motor2 Intent:");
      Serial.println(motorPwm[1]);
      ledcWrite(motorChannels[1],motorPwm[1]);
      Serial.println("Motor3 Intent:");
      Serial.println(motorPwm[2]);
      ledcWrite(motorChannels[2],motorPwm[2]);
      Serial.println("Motor4 Intent:");
      Serial.println(motorPwm[3]);
      ledcWrite(motorChannels[3],motorPwm[3]);

      if (fadeMotor[0]!=-1)
      { 
        motorFade(fadeMotor[0],fadeMotor[1],fadeMotor[2]);
        fadeMotor[0]=-1;
      }
    }

   }
 };

void setup() {
  Serial.begin(115200);
  pinMode(27, INPUT);
  
  BLEDevice::init("ESP32");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE|
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristic->setCallbacks(new CallBacks());
  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();


  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);
  BLEDevice::startAdvertising();


//================ Motor Setup================

  pinMode(12,OUTPUT);
  pinMode(25,OUTPUT);
  pinMode(26,OUTPUT);
  pinMode(14,OUTPUT);
  
  ledcSetup(motorChannels[0], freq, resolution);
  ledcSetup(motorChannels[1], freq, resolution);
  ledcSetup(motorChannels[2], freq, resolution);
  ledcSetup(motorChannels[3], freq, resolution);

  
  ledcAttachPin(motors[0], motorChannels[0]);
  ledcAttachPin(motors[1], motorChannels[1]);
  ledcAttachPin(motors[2], motorChannels[2]);
  ledcAttachPin(motors[3], motorChannels[3]);
//================ Motor Setup================



}






void loop() {
    
    if (deviceConnected) 
    {
      int Push_button_state = digitalRead(27);
      value = -1;
      if ( Push_button_state == HIGH )
      { 
      value=1;
//      ledcWrite(motor1Channel,1023);
      }
      else 
      {
      value=0;
//      ledcWrite(motor1Channel,0);
      }

        pCharacteristic->setValue((uint8_t*)&value, 4);
        pCharacteristic->notify();
        delay(500); 
    }
    if (!deviceConnected && oldDeviceConnected) {
        delay(500);
        pServer->startAdvertising();
//        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    if (deviceConnected && !oldDeviceConnected) {
        oldDeviceConnected = deviceConnected;
    }    
}
