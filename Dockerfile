FROM golang:1.10-alpine AS builder
RUN apk add --no-cache bash make
WORKDIR /go/src/github.com/williamchanrico/helm-charts-golang-sample/
COPY . /go/src/github.com/williamchanrico/helm-charts-golang-sample/
RUN make build

FROM alpine:3.6

EXPOSE 8080
COPY --from=builder /go/src/github.com/williamchanrico/helm-charts-golang-sample/ /usr/local/bin/
RUN chown -R nobody:nogroup /usr/local/bin/items-count-app && chmod +x /usr/local/bin/items-count-app
USER nobody
CMD items-count-app
