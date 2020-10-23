## Figlet

Deploy and test:

    faas-cli deploy --image fcarp10/figlet --name figlet --fprocess "figlet"
    curl http://127.0.0.1:8080/function/figlet -d "OpenFaaS"