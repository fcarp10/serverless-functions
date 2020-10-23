FROM openfaas/of-watchdog:0.8.1 as watchdog
FROM alpine:3.12.1

RUN mkdir -p /home/app

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

RUN apk --no-cache add openssl-dev figlet

# Add non root user
RUN addgroup -S app && adduser app -S -G app
RUN chown app /home/app

USER app
WORKDIR /home/app
# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="figlet"

# Set to true to see request in function logs
ENV write_debug="false"
EXPOSE 8080
ENV upstream_url="http://127.0.0.1:5000"
ENV mode="http"

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]