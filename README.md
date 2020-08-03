## Repository of OpenFaas functions

### Build functions

Example of how to build a function for `arm`:

    cd inception/
    docker build -f Dockerfile.armhf -t fcarp10/inception:armhf .

### Deploy functions:

Example of how to deploy a function using docker hub:3

    faas-cli deploy --image fcarp10/inception:armhf --name inception --fprocess "python3 index.py"