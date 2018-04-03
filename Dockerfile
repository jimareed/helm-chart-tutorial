FROM golang:1.10-alpine AS builder
RUN apk add --no-cache bash make
WORKDIR /go/src/github.com/jimareed/helm-chart-tutorial/
COPY . /go/src/github.com/jimareed/helm-chart-tutorial/
RUN make build

FROM alpine:3.6

ARG CREATED
ARG VERSION
ARG REVISION

LABEL org.opencontainers.image.created=$CREATED
LABEL org.opencontainers.image.url="helm-chart-tutorial"
LABEL org.opencontainers.image.source="https://github.com/jimareed/helm-chart-tutorial"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$REVISION

EXPOSE 8080
COPY --from=builder /go/src/github.com/jimareed/helm-chart-tutorial/helm-chart-tutorial /usr/local/bin/
RUN chown -R nobody:nogroup /usr/local/bin/helm-chart-tutorial && chmod +x /usr/local/bin/helm-chart-tutorial
USER nobody
CMD helm-chart-tutorial
