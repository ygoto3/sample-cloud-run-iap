FROM golang:1.20.7-bookworm as build

WORKDIR /go/src/app
ADD . /go/src/app

RUN CGO_ENABLED=0 go build -o /go/bin/app

FROM gcr.io/distroless/base-debian11

COPY --from=build /go/bin/app /

EXPOSE 8080

CMD [ "/app" ]
