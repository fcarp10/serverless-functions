This function trains a fake news detector ML model. The function expects a JSON
with statements and labels. An example of the data structure can be found
[here](fake-news-train/example_data.json).

```shell

foo@bar:~$ curl http://127.0.0.1:8080/function/fake-news-train -d @example_data.json
{"accuracy":0.7809669703566341,"best parameters":{"alpha":0.01,"fit_prior":false}}
```