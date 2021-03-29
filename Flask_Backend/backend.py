
import time
from flask import Flask,request,jsonify
import cv2
from numpy.core.fromnumeric import argmax
from werkzeug.datastructures import ImmutableMultiDict
import numpy as np
# from test_img import detect
import os
import io
import base64
import PIL.Image as Image

from PIL import ImageFile
import json


ImageFile.LOAD_TRUNCATED_IMAGES = True

from io import BytesIO
Countero = 0
Counteri = 0
deadMotor = 0


app = Flask(__name__)


test_dicto = {}
test_dicti = {}

@app.route('/api',methods=['POST'])
def hello_world():

    global Countero 

    Countero+=1
    
    allx = str(request.form['x'])
    ally = str(request.form['y'])
    allw = str(request.form['w'])
    allh = str(request.form['h'])
    allclasses = str(request.form['dClass'])

    allclasses = allclasses.split(',')
    allclasses.pop()
    allx = allx.split(',')
    allx.pop()
    ally = ally.split(',')
    ally.pop()
    allw = allw.split(',')
    allw.pop()
    allh = allh.split(',')
    allh.pop()

    #print(allclasses)
    mpClasses = [
    "bicycle",
    "car",
    "motorcycle",
    "airplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "stop sign",
    "bench",
    "potted plant"
    ]
    i = 0
    templist = []
    for object1 in allclasses:
        if object1 in mpClasses:
            templist.append({object1:[allx[i],ally[i],allw[i],allh[i]]})
            print(object1)
            i+=1
        

    data = request.form
    # print(type(data['Counter']))
    im = Image.open(BytesIO(base64.b64decode(data['Counter'])))
    
    # im = Image.open(BytesIO(base64.b64decode(x)))
    im.save("received_images/testing.png")



    test_dicto["received_images/testing.png"] = templist

    # print(test_dict)
    with open("test_json_files/test.json", "w") as outfile: 
        json.dump(test_dicto, outfile)


    

    if 'push.json' in os.listdir("test_json_files"):
        #print("OK went in ")
        with open("test_json_files/push.json") as outfile: 
            obj = json.load(outfile)
        times = [values[3] for values in obj.values()]
        fin = list(obj.values())[argmax(times)]
        
        global deadMotor
        deadMotor = fin[0]

        return_string = '{}:{}:{}'.format(fin[0],fin[1],fin[2])
        print(return_string)
        os.remove("test_json_files/push.json")
        return return_string

    return "{}:0:dead".format(deadMotor)


@app.route('/back',methods=['POST'])
def indoor_back():
    

    allx = str(request.form['x'])
    ally = str(request.form['y'])
    allw = str(request.form['w'])
    allh = str(request.form['h'])
    allclasses = str(request.form['dClass'])


    allclasses = allclasses.split(',')
    allclasses.pop()
    allx = allx.split(',')
    allx.pop()
    ally = ally.split(',')
    ally.pop()
    allw = allw.split(',')
    allw.pop()
    allh = allh.split(',')
    allh.pop()

    i=0
    templist = []
    # for cls in allclasses:
    #     if cls == 'potted plant':
    #         templist.append({cls:[allx[i],ally[i],allw[i],allh[i]]})
    #         i+=1
    #     else:
    #         i=-1
    if 'potted plant' in allclasses:
        for object1 in allclasses:
            templist.append({object1:[allx[i],ally[i],allw[i],allh[i]]})
            i+=1
        data = request.form
        im = Image.open(BytesIO(base64.b64decode(data['Counter'])))
        im.save("received_images/testing.png")

        test_dicti["received_images/testing.png"] = templist
        
        with open("test_json_files/test_indoor.json", "w") as outfile: 
            json.dump(test_dicti, outfile)
        
        with open("test_json_files/push_indoor.json") as outfile: 
            obj = json.load(outfile)

        times = [values[-1] for values in obj.values()]
        fin = list(obj.values())[argmax(times)]

        return_string = '{}:{}&{}:{}&{}:{}&{}:{}.{}'.format(fin[0],fin[4],fin[1],fin[5],fin[2],fin[6], fin[3], fin[7], fin[8])
        print(return_string)
        return return_string
    
    return "OK"

if __name__ == '__main__':
    if 'push.json' in os.listdir("test_json_files"):
        os.remove("test_json_files/push.json")

    app.run(host="0.0.0.0")
    