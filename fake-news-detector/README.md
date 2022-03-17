## fake-news-detector

This function classifies input strings as fake or real.  

### Deploy and test:

```shell
faas deploy --image "$USER_REGISTRY"/fake-news-detector --name fake-news-detector
curl http://127.0.0.1:8080/function/fake-news-detector -d "hello"
```