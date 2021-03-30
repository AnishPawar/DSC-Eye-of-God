import cv2
import numpy as np
from PIL import Image
import os



def load_cv(path):
    loaded_images = []
    
    x = cv2.imread(path)
    if x is not None:

        x = cv2.resize(x,(640,480))
        x = cv2.flip(x,-1)
    
        x = x/255.
        loaded_images.append(x)
        return np.stack(loaded_images, axis=0)
    else:
        return None


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