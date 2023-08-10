import sys
import json
from textblob import TextBlob

def handle(req):

    buf = ""
    for line in str(req):
        buf = buf + line

    blob = TextBlob(buf)
    res = {
        "polarity": 0,
        "subjectivity": 0
    }

    for sentence in blob.sentences:
        res["subjectivity"] = res["subjectivity"] + sentence.sentiment.subjectivity
        res["polarity"] = res["polarity"] + sentence.sentiment.polarity

    total = len(blob.sentences)

    res["sentence_count"] = total
    res["polarity"] = res["polarity"] / total
    res["subjectivity"] = res["subjectivity"] / total

    return json.dumps(res)
