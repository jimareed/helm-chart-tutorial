FROM golang:1.10-alpine AS builder
RUN apk add --no-cache bash make
WORKDIR /go/src/github.com/jimareed/collection-count/
COPY . /go/src/github.com/jimareed/collection-count/
RUN make build

FROM alpine:3.6

ARG CREATED
ARG VERSION
ARG REVISION

LABEL org.opencontainers.image.created=$CREATED
LABEL org.opencontainers.image.url="https://hub.docker.com/r/jimareed/collection-count"
LABEL org.opencontainers.image.source="https://github.com/jimareed/collection-count"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$REVISION

EXPOSE 8080
COPY --from=builder /go/src/github.com/jimareed/collection-count/collection-count /usr/local/bin/
RUN chown -R nobody:nogroup /usr/local/bin/collection-count && chmod +x /usr/local/bin/collection-count
USER nobody
CMD collection-count
