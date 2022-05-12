from function import function_app
import json

def handle(req):
    req = json.loads(req)
   

    return function_app.execute(req)
