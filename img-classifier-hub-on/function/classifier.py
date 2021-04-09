########################################################################
#
# Image classifier function for OpenFaaS using TensorFlow Hub.
#
# https://github.com/fcarp10/openfaas-functions
#
# Published under the MIT License. See the file LICENSE for details.
#
# Copyright 2020 by Francisco Carpio
#
########################################################################
import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
from PIL import Image
from io import BytesIO
import base64

MODEL_URL = "https://tfhub.dev/google/imagenet/inception_v3/classification/4"
IMAGE_LABELS_URL = (
    "https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt"
)
IMAGE_SHAPE = (224, 224)

classifier = tf.keras.Sequential(
    [hub.KerasLayer(MODEL_URL, input_shape=IMAGE_SHAPE + (3,))]
)
labels_path = tf.keras.utils.get_file("image_labels.txt", IMAGE_LABELS_URL)


def preprocess_image(body):
    img_path = ""
    if body.startswith("https://") or body.startswith("http://"):
        # download image
        filename = body.split("/")[-1]
        img_path = tf.keras.utils.get_file(filename, body)
    else:
        # Decode the image
        im_bytes = base64.b64decode(body)  # im_bytes is a binary image
        img_path = BytesIO(im_bytes)  # convert image to file-like object
    grace_hopper = Image.open(img_path).resize(IMAGE_SHAPE)
    grace_hopper = np.array(grace_hopper) / 255.0
    return grace_hopper


def invoke(grace_hopper):
    result = classifier.predict(grace_hopper[np.newaxis, ...])
    predicted_class = np.argmax(result[0], axis=-1)
    imagenet_labels = np.array(open(labels_path).read().splitlines())
    predicted_class_name = imagenet_labels[predicted_class]
    return predicted_class_name


if __name__ == "__main__":
    grace_hopper = preprocess_image(
        "https://www.pixelstalk.net/wp-content/uploads/2016/03/Animal-wallpapers-HD-desktop.jpg"
    )
    print(invoke(grace_hopper))