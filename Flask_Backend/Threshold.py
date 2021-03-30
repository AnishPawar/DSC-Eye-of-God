# from _typeshed import NoneType
import os

import cv2
import numpy as np
import json
from matplotlib import pyplot as plt
import time
# if len(os.listdir("received_images"))!=0:

if len(os.listdir("depth_maps"))==1:
    os.remove('depth_maps/.DS_Store')

print(os.listdir("depth_maps"))
while len(os.listdir("depth_maps"))==0:
    print("It is empty")


with open('test_json_files/test.json') as f:
    data = json.load(f)



#classAccepted = ["laptop", "person", "car", "keyboard"]
whatToPush = {}

while True:
    # depth_paths = os.listdir("depth_maps")

    # for depth_path in depth_paths:
        # Counter1+=1
        # print(depth_path)
        # x2 = depth_path.split('-')[1]
        # print(x2)
    dodge = cv2.imread("depth_maps/Depth-testing.png")
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
                if int(x+w/2) in range(0, int(height/4)):
                    impart = 1
                elif int(x+w/2) in range(int(height/4), 2*int(height/4)):
                    impart = 2
                elif int(x+w/2) in range(2*int(height/4), 3*int(height/4)):
                    impart =3 
                elif int(x+w/2) in range(3*int(height/4), 4*int(height/4)):
                    impart = 4 
                dodgeno = dodge[ul[0]:lr[0], ul[1]:lr[1]]
                histogram = dodgeno.ravel()
                if np.mean(histogram) < jojo:
                    fclass = cls
                    jojo = np.mean(histogram)
                    fimpart = impart
            
            if jojo <= 120:
                dodgethis = cv2.bitwise_not(dodgeno)
                print("Hmmmmmmm")
                # print("this is it")
                mappo = 0.02*jojo**2 - 3.55*jojo + 300
                # whatToPush.append({'testing{}.png'.format(depth_path[-5]): [fimpart, int(mappo), fclass]})
                # print(time.time())
                # GETTING WATER BRB
                whatToPush['testing.png'] = [fimpart, int(mappo), fclass, time.time()]
                with open("test_json_files/push.json", "w") as outfile: 
                    json.dump(whatToPush, outfile)
    except Exception as e:
        print(e)

        
        
