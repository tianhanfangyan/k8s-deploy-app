FROM golang:1.12.3-alpine AS builder

WORKDIR /job

ENV CGO_ENABLED=0

# add current files into docker container
ADD . .

RUN export PROJECT=$(head -n1 go.mod | awk '{ print $2 }') && \
    go build -mod=vendor -ldflags "-s -w"  -o /job/app .


FROM alpine:3.7

LABEL maintainer="dystargate@gmail.com"

# install tzdata
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk update && apk add --no-cache tzdata ca-certificates && rm -rf /var/cache/apk/*

COPY --from=builder /job/app /bin/app

EXPOSE 8000

ENTRYPOINT ["app"]
