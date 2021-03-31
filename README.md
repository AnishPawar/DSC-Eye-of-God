<h1 align="center"> :eye: Eye of God :eye:</h1>

<div align="center">


<br>

[![](https://img.shields.io/badge/Made_with-Flutter-green?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![](https://img.shields.io/badge/Made_with-Google%20Maps%20Platform-green?style=for-the-badge&logo=google-maps)](https://developers.google.com/maps/documentation)
[![](https://img.shields.io/badge/Made_with-dart-green?style=for-the-badge&logo=dart)](https://dart.dev/)
[![](https://img.shields.io/badge/Made_with-Opencv-green?style=for-the-badge&logo=opencv)](https://opencv.org)
[![](https://img.shields.io/badge/Made_with-Python-green?style=for-the-badge&logo=python)](https://www.python.org)
[![](https://img.shields.io/badge/Made_with-Tensorflow-green?style=for-the-badge&logo=tensorflow)](https://www.tensorflow.org)
[![](https://img.shields.io/badge/Made_with-Flask-green?style=for-the-badge&logo=flask)](http://flask.palletsprojects.com)
[![](https://img.shields.io/badge/Made_with-Google_Cloud-green?style=for-the-badge&logo=google-cloud)](https://cloud.google.com)
[![](https://img.shields.io/badge/Made_with-Keras-green?style=for-the-badge&logo=keras)](https://keras.io)
[![](https://img.shields.io/badge/Made_with-Arduino-green?style=for-the-badge&logo=arduino)](https://www.arduino.cc)
</br>

</div>



---
<h2><strong>About</h2></strong>
<p>The World Health Organization put the global figure of visually-impaired and blind people at 285 million. For these people, navigating busy urban landscapes can be extremely challenging.</p>

<p>To offer a solution to the urban-dwelling visually-impaired, we built “Eye of God”. It is an easy-to-use navigation system for visually impaired people, acting as their “virtual-cane” to help them navigate to their destination all by themselves without needing the assistance of other people.  </p>


<p>The navigation system comes in two modes: Indoor Navigation and Outdoor Navigation. Indoor navigation is a big deal for blind people. One reason why blind people typically stay close to home is because they sense the world is not made for them. And it would be really wonderful to hear people say, 'I can walk through malls or venues without this sense of hopelessness or of missing information.' While Indoor Navigation alerts the user about obstacles in the path through voice commands, Outdoor Navigation does the same, but more. The user is prompted to speak out the destination, and the most optimal route is calculated. Since blind people are more efficient in hearing and possess strong perception than normal people, therefore the system is focused on alerting the user through vibration and voice feedback. Step by step sound-based navigation commands are provided to the user along with in-path obstacle detection.  
</p>
This innovative use of technology can help them feel more empowered and independent, thus bridging the gap and getting them at par with the sighted ones.  
</p>
<strong>In accordance with</strong>: 

* United Nations' Sustainable Development Goal 10: Reduced Inequalities. 

* United Nations' Sustainable Development Goal 9: Industry, Innovation, & Infrastructure.  

* United Nations' Sustainable Development Goal 16: Peace, Justice & Strong Institutions. 
<br>

---

<h2><strong>App Workflow</h2></strong>
<div align="center">
<img src="Readme_Assets\WorkFlow.png"> 
</div>
<br>

---

<h2><strong>Download Dependencies</strong></h2>
Download the environment.yml and paste the following command in your terminal

```conda env create --name "name" -f environment.yml```

or install the following packages manually:
  - opencv-python
  - numpy
  - keras
  - tensorflow
  - Pillow
  - json
  - pybase64
  - Werkzeug
  - spyder
---
<h2><strong>How to run</h2></strong>
<h3><strong>Depth Model<h3></strong>

Download the model from: https://drive.google.com/file/d/16iK70z22MBa694a1qzdajnnbbIT2eXBV/view?usp=sharing and place it in the 
```/Flask_Backend``` Folder

<h3><strong>Arduino Code:<h3></strong>

Compile and execute the `Arduino/Arduino_Controller.ino` file on a arduino board with the necessary circuitary.

---

<h2><strong>Circuit Diagram</h2></strong>
<div align="center">
<img src="Readme_Assets\Arduino_Circuit.JPG"> 
</div>
<br>

---

<h3><strong>For Outdoor Navigation:<h3></strong>

1.	Run `backend.py` and `go.py` on a local machine. (Make sure the received_images folder is empty before each run and both the devices are connected to the same network)

2.	Change the IP to the IP of local machine in flask_helpers/sendToFlask.dart (paste it in place of X --> http://X:5000/api) in the Outdoor section.

3.	Turn on the belt and pair the android device to HC05 via Bluetooth.

4.	Run the Flutter Application on an Android phone and mount it to a VR headset.

<h3><strong>For Indoor Navigation:<h3></strong>

1.	Run `backend.py` and `go_in.py` on a local machine. (Make sure the received_images folder is empty before each run and both the devices are connected to the same network)
2.	Change the IP to the IP of local machine in flask_helpers/sendToFlask.dart (paste it in place of X --> http://X:5000/back) in the Indoor section.
3.	Turn on the belt and pair the android device to HC05 via Bluetooth.
4.	Run the Flutter Application on an Android phone and mount it to a VR headset.
---
<h2><strong>App Screenshots</strong>
<strong>Circuit Diagram</strong>
<div align="center">
<img src="Readme_Assets\App_Screenshot.png"> 
</div>


---
<h2>References</h2>


https://github.com/ialhashim/DenseDepth

https://youtu.be/P6AwCCvGC58

https://github.com/am15h/object_detection_flutter

https://create.arduino.cc/projecthub/reanimationxp/how-to-multithread-an-arduino-protothreading-tutorial-dd2c37


<br>

---
<br>
Link to the Demo Video:
[Eye of God](https://youtu.be/heCKjZSQmQY)
<br>
---
<br>
<h3 align="center"><b>Developed by Team Hack Inversion</b></h3>

[![](https://img.shields.io/badge/LinkedIn-Anish_Pawar-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/anish-pawar-5300a9192/)

[![](https://img.shields.io/badge/LinkedIn-Gayatri_Patil-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/gayatri-patil-48316b203/)

[![](https://img.shields.io/badge/LinkedIn-Jatin_Nainani-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/jatin-nainani-a6b2331b3/)

[![](https://img.shields.io/badge/LinkedIn-Priyanka_Hotchandani-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/priyanka-hotchandani/)