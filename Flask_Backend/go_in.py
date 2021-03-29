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
        dodge = viz
        try:
            if bool(data['received_images/testing.png']) and dodge is not None:
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
                    dodge1 = np.mean(dodge[0:int(height/4), 0:int(width)].ravel())
                    dodge1 = 0.017*dodge1**2 - 3.55*dodge1 + 255
                    dodge2 = np.mean(dodge[int(height/4):2*int(height/4), 0:int(width)].ravel())
                    dodge2 = 0.017*dodge2**2 - 3.55*dodge2 + 255
                    dodge3 = np.mean(dodge[2*int(height/4):3*int(height/4), 0:int(width)].ravel())
                    dodge3 = 0.017*dodge3**2 - 3.55*dodge3 + 255
                    dodge4 = np.mean(dodge[3*int(height/4):4*int(height/4), 0:int(width)].ravel())
                    dodge4 = 0.017*dodge4**2 - 3.55*dodge4 + 255
                    dodgeno = dodge[ul[0]:lr[0], ul[1]:lr[1]]
                    d1, d2, d3, d4 = 0, 0, 0, 0

                    if int(x+w/2) in range(0, int(height/4)):
                        impart = 1
                        dodge1 = np.mean(dodgeno.ravel())
                        dodge1 = 0.017*dodge1**2 - 3.55*dodge1 + 255
                        d1 = 0.0024*dodge1
                    elif int(x+w/2) in range(int(height/4), 2*int(height/4)):
                        impart = 2
                        dodge2 = np.mean(dodgeno.ravel())
                        dodge2 = 0.017*dodge2**2 - 3.55*dodge2 + 255
                        d2 = 0.0024*dodge2
                    elif int(x+w/2) in range(2*int(height/4), 3*int(height/4)):
                        impart = 3 
                        dodge3 = np.mean(dodgeno.ravel())
                        dodge3 = 0.017*dodge3**2 - 3.55*dodge3 + 255
                        d3 = 0.0024*dodge3
                    elif int(x+w/2) in range(3*int(height/4), 4*int(height/4)):
                        impart = 4 
                        dodge4 = np.mean(dodgeno.ravel())
                        dodge4 = 0.017*dodge4**2 - 3.55*dodge4 + 255
                        d4 = 0.0024*dodge4
                        
                #mappo = 0.017*jojo**2 - 3.55*jojo + 255
                whatToPush['testing.png'] = [dodge1, dodge2, dodge3, dodge4, d1, d2, d3, d4, cls, time.time()]
                with open("test_json_files/push_indoor.json", "w") as outfile: 
                    json.dump(whatToPush, outfile)
        except Exception as e:
            print(e)