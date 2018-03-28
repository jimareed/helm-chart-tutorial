FROM golang:1.10-alpine AS builder
RUN apk add --no-cache bash make
WORKDIR /go/src/github.com/jimareed/basic-service/
COPY . /go/src/github.com/jimareed/basic-service/
RUN make build

FROM alpine:3.6

ARG CREATED
ARG VERSION
ARG REVISION

LABEL org.opencontainers.image.created=$CREATED
LABEL org.opencontainers.image.url="https://hub.docker.com/r/jimareed/basic-service"
LABEL org.opencontainers.image.source="https://github.com/jimareed/basic-service"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$REVISION

EXPOSE 8080
COPY --from=builder /go/src/github.com/jimareed/basic-service/basic-service /usr/local/bin/
RUN chown -R nobody:nogroup /usr/local/bin/basic-service && chmod +x /usr/local/bin/basic-service
USER nobody
CMD basic-service
