from function import detector 


def handle(req):
    buf = ""
    for line in str(req):
        buf = buf + line
    image_path = detector.download_and_resize_image(buf, 1280, 856)
    return detector.run_detector(image_path)