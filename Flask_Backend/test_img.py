# from go import Counter1
# import os
# import glob
# import argparse
# from typing import Counter
# import matplotlib
# import cv2

# from my_utils import load_cv

# os.environ['TF_CPP_MIN_LOG_LEVEL'] = '10'
# from keras.models import load_model
# from layers import BilinearUpSampling2D
# from utils import predict, display_images


# Counter12 = 0

# def detect(img):
#     global Counter12
#     print("Goinf in")


#     # img = cv2.imread(file_path)
#     inputs = load_cv(img)
#     outputs = predict(model, inputs)
#     print("Visualising")
#     viz = display_images(outputs.copy(), inputs.copy())
#     print(viz)
#     # cv2.imshow('ss',viz)
#     # cv2.waitKey(0)
#     Counter12+=1
#     cv2.imwrite("depth_maps/Depth{}.jpg".format(Counter12),viz)

