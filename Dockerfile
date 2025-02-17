FROM alpine:3.21.3
RUN apk add --no-cache nmap curl
COPY probe.sh /probe.sh
CMD /probe.sh
