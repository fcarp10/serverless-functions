FROM ghcr.io/openfaas/of-watchdog:0.8.4 as watchdog

FROM alpine:3.13 as build

FROM nginx:alpine

ARG ADDITIONAL_PKG=""

RUN apk add --no-cache ${ADDITIONAL_PKG}

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog


COPY ./index.html /usr/share/nginx/html/index.html


ENV fprocess="nginx"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:80"
ENV prefix_logs="false"

CMD ["fwatchdog"]

