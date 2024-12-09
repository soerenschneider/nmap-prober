FROM alpine:3.21.0
RUN apk add --no-cache nmap curl
COPY probe.sh /probe.sh
CMD /probe.sh
