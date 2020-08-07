FROM openfaas/classic-watchdog:0.18.8 as watchdog
FROM python:3.7-slim

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

RUN mkdir -p /home/app
WORKDIR /home/app

COPY requirements.txt ./

RUN pip3 install -r requirements.txt 

RUN pip3 install textblob && \
    python3 -m textblob.download_corpora

RUN python3 -m textblob.download_corpora

COPY index.py .

# ENV write_debug="true"
HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
ENV fprocess="python3 index.py"

CMD ["fwatchdog"]

