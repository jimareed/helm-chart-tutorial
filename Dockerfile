FROM golang:1.10-alpine AS builder
RUN apk add --no-cache bash make
WORKDIR /go/src/github.com/jimareed/collection-counter/
COPY . /go/src/github.com/jimareed/collection-counter/
RUN make build

FROM alpine:3.6

ARG CREATED
ARG VERSION
ARG REVISION

LABEL org.opencontainers.image.created=$CREATED
LABEL org.opencontainers.image.url="https://hub.docker.com/r/jimareed/collection-counter"
LABEL org.opencontainers.image.source="https://github.com/jimareed/collection-counter"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$REVISION

EXPOSE 8080
COPY --from=builder /go/src/github.com/jimareed/collection-counter/collection-counter /usr/local/bin/
RUN chown -R nobody:nogroup /usr/local/bin/collection-counter && chmod +x /usr/local/bin/collection-counter
USER nobody
CMD collection-counter
