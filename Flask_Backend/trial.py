import cv2
import json
import os
#from numpy.lib.type_check import imag


# with open('test_json_files/test.json') as f:
#     data = json.load(f)

# #print(data['received_images/testing2.png'])
# # 
# image = cv2.imread('received_images/testing4.png')
# print(image.shape)
# # start_point = (data['received_images/testing4.png'][0], data['received_images/testing4.png'][2])
# # end_point = (data['received_images/testing4.png'][1], data['received_images/testing4.png'][3])

# for i in range(len(data['received_images/testing4.png'])):

#     x = int(float(data['received_images/testing4.png'][i]['laptop'][0]))
#     y = int(float(data['received_images/testing4.png'][i]['laptop'][1]))
#     w = int(float(data['received_images/testing4.png'][i]['laptop'][2]))
#     h = int(float(data['received_images/testing4.png'][i]['laptop'][3]))

#     image = cv2.rectangle(image, (y,x), ((y+h),(x+w)),(0,255,0),3)
# # x = 34
# y = 0
# w = 167
# h = 196


# print(x,y,w,h)
# start = (58/2,255/1.5)
# end = ((58+361)/2,(255+369)/1.5)

import time

from numpy.core.fromnumeric import argmax
import numpy as np
import cv2
from numpy.lib.type_check import imag
image = cv2.imread("received_images/testing.png")

image = cv2.flip(image,-1)

# "0", "31.599998474121094", "29.999669194221497", "96.78888320922852"
# "92.94487953186035", "2.6499176025390625", "90.12399673461914", "132.11885452270508"

start_point = (93,3)
end_point = ((93+190),(3+200))
height, width = image.shape[:2]
print(height)
print(width)
image = cv2.rectangle(image, (0,0) , (int(width/4), height), (0,255,0), 5)
cv2.imshow("Test",image)
cv2.waitKey(0)
# cv2.imshow("Heelo",image)
# cv2.waitKey(0)

# with open("test_json_files/push.json") as outfile: 
#         fin = json.load(outfile)
# print(fin[list(fin)[-1]])

# with open("test_json_files/push.json") as outfile: 
#     obj = json.load(outfile)
# fin = obj[list(obj)[-1]]


# return_string = '{}:{}:{}'.format(fin[0],fin[1],fin[2])

    
#obj.pop(list(obj)[-1], None)
# dictionary_return = {}

#with open("test_json_files/push.json", "w") as outfile: 
#    json.dump(obj, outfile)

# dictionary_return[list(obj)[-1]]=fin



# print(return_string)

depth_paths = os.listdir("depth_maps")[1:]
# depth_paths = ['Depth-testing5.png', 'Depth-testing7.png', 'Depth-testing6.png', 'Depth-testing2.png', 'Depth-testing3.png', 'Depth-testing1.png', 'Depth-testing0.png', 'Depth-testing10.png', 'Depth-testing11.png', 'Depth-testing15.png', 'Depth-testing8.png', 'Depth-testing9.png']

# image_paths = os.listdir("received_images")[1:]

#print(depth_paths)

# for depth_path in depth_paths:
#     # x = depth_path.split('-')[1]
#     x= time.time()
#     print(x)

# with open("test_json_files/push.json") as outfile: 
#     obj = json.load(outfile)

# times = [values[3] for values in obj.values()]
# #print(argmax(times))
# with open('test_json_files/test.json') as f:
#     data = json.load(f)

# print(obj.values())
# # #valuesss = list(obj.values())
# # print(list(obj.values())[argmax(times)])
# # print(max(obj.values()[3]))
# # fin = list(obj.values())[:][3]
# # print(fin)
# # while True:
# for i in range(len(obj)):
#     if obj[i]["ename"] == "mark":
#         obj.pop(i)
#         break
#     for depth_path in depth_paths:
       
#         x2 = depth_path.split('-')[1]
#         print(bool(data['received_images/'+x2]))
#return_string = '{}:{}:{}'.format(fin[0],fin[1],fin[2])



# print(os.listdir("test_json_files"))

# if 'push_1.json' in os.listdir("test_json_files"):
#     print("OK went in ")
#     with open("test_json_files/push_1.json") as outfile: 
#         obj = json.load(outfile)
#     times = [values[3] for values in obj.values()]
#     fin = list(obj.values())[argmax(times)]

#     return_string = '{}:{}:{}'.format(fin[0],fin[1],fin[2])
#     print(return_string)
#     os.remove("test_json_files/push_1.json")




# if obj != None:
#     times = [values[3] for values in obj.values()]
#     fin = list(obj.values())[argmax(times)]

#     return_string = '{}:{}:{}'.format(fin[0],fin[1],fin[2])
#     print("Went In")

# x2 = 'testing3.png'
# print(x2)
# dodge = cv2.imread("depth_maps/"+depth_path)
# # print(data['received_images/'+x])
# #print(dodge.any())
# try:
#     if bool(data['received_images/'+x2]) and dodge is not None:
#         print("Going in")       
#         height, width = dodge.shape[:2]
#         jojo = 1000000
#         # print(list(data['received_images/'+x][0].keys()))
#         for cls in list(data['received_images/'+x2][0].keys()):
#             x = int(float(data['received_images/'+x2][0][cls][0]))
#             y = int(float(data['received_images/'+x2][0][cls][1]))
#             w = int(float(data['received_images/'+x2][0][cls][2]))
#             h = int(float(data['received_images/'+x2][0][cls][3]))
#             ul = (x, y)
#             lr = (x+w, y+h)
#             if int(x+w/2) in range(0, int(height/4)):
#                 impart = 1
#             elif int(x+w/2) in range(int(height/4), 2*int(height/4)):
#                 impart = 2
#             elif int(x+w/2) in range(2*int(height/4), 3*int(height/4)):
#                 impart =3 
#             elif int(x+w/2) in range(3*int(height/4), 4*int(height/4)):
#                 impart = 4 
#             # elif int(x+w/2) in range(4*int(height/5), 5*int(height/5)):
#             #     impart = 5
#             dodgeno = dodge[ul[0]:lr[0], ul[1]:lr[1]]
#             histogram = dodgeno.ravel()
#             if np.mean(histogram) < jojo:
#                 fclass = cls
#                 jojo = np.mean(histogram)
#                 fimpart = impart
        
#         if jojo <= 120:
#             dodgethis = cv2.bitwise_not(dodgeno)
#             print("Hmmmmmmm")
#             # print("this is it")
#             mappo = 0.02*jojo**2 - 3.55*jojo + 300
#             # whatToPush.append({'testing{}.png'.format(depth_path[-5]): [fimpart, int(mappo), fclass]})
#             # print(time.time())
            
#             whatToPush[x2] = [fimpart, int(mappo), fclass, time.time()]
#             with open("test_json_files/push.json", "w") as outfile: 
#                 json.dump(whatToPush, outfile)
# except Exception as e:
#     print(e)
        


# import cv2
# import numpy as np
# img = cv2.imread("received_images/testing.png")


# cv2.waitKey(0)