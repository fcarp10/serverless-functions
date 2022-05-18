FROM openfaas/of-watchdog:0.8.1 as watchdog
FROM python:3.8-slim-buster

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

COPY index.py .
COPY requirements.txt .

USER root
RUN pip install -r requirements.txt

# Build the function directory and install any user-specified components
USER app

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools

RUN mkdir -p function
WORKDIR /home/app/function/
COPY function/ .

RUN pip install --user -r requirements.txt

### Temporal until arm64 wheels available for tensorflow ####
ARG TENSORFLOW_PACKAGE=tensorflow==2.4.1
RUN pip install --no-deps --user ${TENSORFLOW_PACKAGE}

### Download the model and labels
RUN mkdir -p model
WORKDIR /home/app/function/model
ARG MODEL_URL
ARG IMAGE_LABELS_URL
RUN wget -q ${MODEL_URL} -O - | tar -xz
RUN wget -q ${IMAGE_LABELS_URL} -O image_labels.txt

USER root
RUN chown -R app:app ../
WORKDIR /home/app/

# configure WSGI server and healthcheck
USER app

ENV fprocess="python index.py"

ENV cgi_headers="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:5000"
ENV suppress_lock="true"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
