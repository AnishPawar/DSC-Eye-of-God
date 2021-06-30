
import os

from  load_model import load_model_depth

import os
import time
import cv2

from my_utils import load_cv

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '10'
from keras.models import load_model
from layers import BilinearUpSampling2D
from utils import predict, display_images
import json
import numpy as np
depthModel = load_model_depth()


if len(os.listdir("received_images"))==1:
    os.remove('received_images/.DS_Store')

while len(os.listdir("received_images"))==0:
    print("It is empty")

time.sleep(1)
whatToPush = {}
while True:


    with open('test_json_files/test.json') as f:
        data = json.load(f)
    


    image_paths = os.listdir("received_images")
    print(image_paths)
    
    time.sleep(1)

    inputs = load_cv("received_images/testing.png")
    if inputs is not None:
        outputs = predict(depthModel, inputs)
        print("Visualising")
        viz = display_images(outputs.copy(), inputs.copy())
        
        
        
        cv2.imshow("Test",(viz/255))
        cv2.waitKey(20)
        dodge = viz
        try:
            if dodge is not None:
                print("Going in")       
                height, width = dodge.shape[:2]
                jojo = 1000000
                for cls in list(data['received_images/testing.png'][0].keys()):
                    x = int(float(data['received_images/testing.png'][0][cls][0]))
                    y = int(float(data['received_images/testing.png'][0][cls][1]))
                    w = int(float(data['received_images/testing.png'][0][cls][2]))
                    h = int(float(data['received_images/testing.png'][0][cls][3]))
                    ul = (x, y)
                    lr = (x+w, y+h)
                    if int(x+w/2) in range(0, int(width/4)):
                        impart = 1
                    elif int(x+w/2) in range(int(width/4), 2*int(width/4)):
                        impart = 2
                    elif int(x+w/2) in range(2*int(width/4), 3*int(width/4)):
                        impart =3 
                    elif int(x+w/2) in range(3*int(width/4), 4*int(width/4)):
                        impart = 4 
                    dodgeno = dodge[ul[0]:lr[0], ul[1]:lr[1]]
                    histogram = dodgeno.ravel()
                    if np.mean(histogram) < jojo:
                        fclass = cls
                        jojo = np.mean(histogram)
                        fimpart = impart
                
                if jojo <= 120:
                    #dodgethis = cv2.bitwise_not(dodgeno)
                    print("jojo is alive")
                    mappo = 0.02*jojo**2 - 3.55*jojo + 300
                    whatToPush['testing.png'] = [fimpart, int(mappo), fclass, time.time()]
                    with open("test_json_files/push.json", "w") as outfile: 
                        json.dump(whatToPush, outfile)
        except Exception as e:
            print(e)

