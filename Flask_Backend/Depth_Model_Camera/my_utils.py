import cv2
import numpy as np
from PIL import Image
import os



def load_cv(image):
    loaded_images = []
    
    # x = cv2.imread(image_dir)/255.
    x = image/255.
    loaded_images.append(x)
    return np.stack(loaded_images, axis=0)


# if __name__ == "__main__":
#     # try:
#     test = []
#     image_files = os.listdir("examples")

#     for image in image_files:
#         image = "examples/{}".format(image)
#         # print(image)
#         test.append(image)


#     print(test[1])
#     x = load_images([test[1]])
#     print("First is")
#     print(x)



#     y = load_cv([test[1]])
#     print("First111 is")
#     print(y)
#     # pass


#     if x.all()==y.all():
#         print("OK")