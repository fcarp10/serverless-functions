import sys
import inception

def handle(req):

    buf = ""
    for line in str(req):
        buf = buf + line

    res = inception.invoke(buf)

    return res