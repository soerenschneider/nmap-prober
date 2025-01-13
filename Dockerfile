FROM alpine:3.21.2
RUN apk add --no-cache nmap curl
COPY probe.sh /probe.sh
CMD /probe.sh
