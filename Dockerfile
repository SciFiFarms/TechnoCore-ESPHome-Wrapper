FROM docker:18.09 AS base

FROM alpine:latest
RUN apk add --no-cache bash 
COPY --from=base / /

# Set up the CMD as well as the pre and post hooks.
COPY go-init/go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY main.sh /usr/bin/main.sh
COPY go-init/exitpoint.sh /usr/bin/exitpoint.sh
ENTRYPOINT ["go-init"]
CMD ["-pre", "entrypoint.sh", \
    "-main", "main.sh", \
    "-post", "exitpoint.sh"]
