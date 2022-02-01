# # Support setting various labels on the final image
# ARG COMMIT=""
# ARG VERSION=""
# ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.18-alpine as builder

RUN apk add --no-cache gcc=10.3.1_git20211027-r0 musl-dev=1.2.2-r7 linux-headers=5.10.41-r0 git=2.34.1-r0

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum
RUN cd /go-ethereum && go run build/ci.go install ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:3.15.0

RUN apk add --no-cache ca-certificates=20211220-r0

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
