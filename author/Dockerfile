FROM golang:1.15-alpine3.13

WORKDIR $GOPATH/src/github.com/zawiszaty/author

COPY . .

RUN go build *.go

EXPOSE 80

ENTRYPOINT ["./main"]