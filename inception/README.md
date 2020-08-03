# inception-function

This is a forked version of the work by [Alexellis](https://github.com/faas-and-furious/inception-function). It has been extended by adding the possibility of sending images directly encoded with Basae64 instead of downloading them. It has also been added dockerfile to be built for armv7 devices. 

To build the function, copy the `Dockerfile` and `requirements.txt` from either `armv7` or `x86_64` folders into the `function` folder. Modify `image` tag from `stack.yml` and run:

    faas-cli up -f stack.yml


Deploy on [OpenFaaS](https://www.openfaas.com):

```
$ faas-cli deploy --image alexellis/inception --name inception --fprocess "python3 index.py"
```

Invoke via `curl` or `faas-cli invoke`:

```sh
export URL=https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg
echo -n $URL | faas-cli invoke inception

[{"name": "great white shark", "score": 0.5343291759490967}, {"name": "tiger shark", "score": 0.09276486188173294}, {"name": "grey whale", "score": 0.05899052694439888}, {"name": "sea lion", "score": 0.05105864629149437}, {"name": "hammerhead", "score": 0.019910583272576332}, {"name": "sturgeon", "score": 0.013177040033042431}, {"name": "stingray", "score": 0.00763126602396369}, {"name": "electric ray", "score": 0.006749240681529045}, {"name": "killer whale", "score": 0.005086909048259258}, {"name": "ice bear", "score": 0.003828041721135378}]
```
