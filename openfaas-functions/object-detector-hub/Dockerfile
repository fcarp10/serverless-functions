FROM --platform=${TARGETPLATFORM:-linux/amd64} ghcr.io/openfaas/of-watchdog:0.9.10 as watchdog
FROM --platform=${TARGETPLATFORM:-linux/amd64} python:3.8-slim-buster as build

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

ARG ADDITIONAL_PACKAGE
RUN apt-get -qy update && apt-get -qy install gcc make ${ADDITIONAL_PACKAGE}

# Add non root user
RUN addgroup --system app && adduser app --system --ingroup app
RUN chown app /home/app

USER app

ENV PATH=$PATH:/home/app/.local/bin

WORKDIR /home/app/

COPY --chown=app:app index.py           .
COPY --chown=app:app requirements.txt   .

USER root
RUN pip install --no-cache-dir -r requirements.txt

# Build the function directory and install any user-specified components
USER app

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools

RUN mkdir -p function
RUN touch ./function/__init__.py
WORKDIR /home/app/function/
COPY --chown=app:app function/requirements.txt	.

RUN pip install --no-cache-dir --user -r requirements.txt

### Temporal until arm64 wheels available for tensorflow ####
ARG EXTRA_ARG
RUN pip install --no-deps --user ${EXTRA_ARG}

### Download the model
RUN mkdir -p model
WORKDIR /home/app/function/model
ARG MODEL_URL="https://tfhub.dev/google/faster_rcnn/openimages_v4/inception_resnet_v2/1?tf-hub-format=compressed"
RUN wget -q ${MODEL_URL} -O - | tar -xz

WORKDIR /home/app/function
#install function code
USER root

COPY --chown=app:app function/   .

FROM build as ship
WORKDIR /home/app/

#configure WSGI server and healthcheck
USER app

ENV fprocess="python index.py"

ENV cgi_headers="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:5000"
ENV exec_timeout=900s
ENV write_timeout=900s
ENV read_timeout=900s

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1


CMD ["fwatchdog"]