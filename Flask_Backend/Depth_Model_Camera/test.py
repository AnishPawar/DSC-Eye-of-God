import os
import glob
import argparse
import matplotlib
import cv2

from my_utils import load_cv

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '10'
from keras.models import load_model
from layers import BilinearUpSampling2D
from utils import predict, display_images



custom_objects = {'BilinearUpSampling2D': BilinearUpSampling2D, 'depth_loss_function': None}

print('Loading model...')

model = load_model("nyu.h5", custom_objects=custom_objects, compile=False)

print('\nModel loaded (nyu.h5).')


cap = cv2.VideoCapture(0)
while(True):
    ret, frame = cap.read()

    inputs = load_cv(frame)

    outputs = predict(model, inputs)

    viz = display_images(outputs.copy(), inputs.copy())
    cv2.imshow('ss',viz)

    if cv2.waitKey(40) & 0xFF == ord('q'):
        break
