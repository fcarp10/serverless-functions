from function import app
def handle(req):
    return app.predict(req)

