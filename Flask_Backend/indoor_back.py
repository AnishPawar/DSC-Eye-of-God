
import os
import cv2
import numpy as np
import json
from matplotlib import pyplot as plt
import time

if len(os.listdir("depth_maps"))==1:
    os.remove('depth_maps/.DS_Store')

print(os.listdir("depth_maps"))
while len(os.listdir("depth_maps"))==0:
    print("It is empty")

with open('test_json_files/test_indoor.json') as f:
    data = json.load(f)

whatToPush = {}

while True:
    depth_paths = os.listdir("depth_maps")

    for depth_path in depth_paths:
        x2 = depth_path.split('-')[1]
        print(x2)
        dodge = cv2.imread("depth_maps/"+depth_path)
        try:
            if bool(data['received_images/'+x2]) and dodge is not None:
                print("Going in")       
                height, width = dodge.shape[:2]
                jojo = 1000000
                for cls in list(data['received_images/'+x2][0].keys()):
                    x = int(float(data['received_images/'+x2][0][cls][0]))
                    y = int(float(data['received_images/'+x2][0][cls][1]))
                    w = int(float(data['received_images/'+x2][0][cls][2]))
                    h = int(float(data['received_images/'+x2][0][cls][3]))
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
                        
                mappo = 0.017*jojo**2 - 3.55*jojo + 255
                whatToPush[x2] = [dodge1, dodge2, dodge3, dodge4, d1, d2, d3, d4, cls, time.time()]
                with open("test_json_files/push_indoor.json", "w") as outfile: 
                    json.dump(whatToPush, outfile)
        except Exception as e:
            print(e)

        
        
