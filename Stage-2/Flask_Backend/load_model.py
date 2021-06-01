
import os

import cv2

from my_utils import load_cv

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '10'
from keras.models import load_model
from layers import BilinearUpSampling2D
from utils import predict, display_images

def load_model_depth():

    custom_objects = {'BilinearUpSampling2D': BilinearUpSampling2D, 'depth_loss_function': None}

    print('Loading model...')

    model = load_model("nyu.h5", custom_objects=custom_objects, compile=False)

    print('\nModel loaded (nyu.h5).')

    return model