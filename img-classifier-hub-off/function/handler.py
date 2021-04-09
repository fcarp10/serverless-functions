from function import classifier


def handle(req):
    buf = ""
    for line in str(req):
        buf = buf + line

    grace_hopper = classifier.preprocess_image(buf)
    return classifier.invoke(grace_hopper)
