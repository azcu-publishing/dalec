FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/oss/go/microsoft/golang:1.21@sha256:4022b19ac0661d87933b1690385a21154146bb8589b148410b8b114c3f595bb1 AS go

FROM go  AS frontend-build
WORKDIR /build
COPY . .
ENV CGO_ENABLED=0
ARG TARGETARCH TARGETOS GOFLAGS=-trimpath
ENV GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOFLAGS=${GOFLAGS}
RUN \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -o /frontend ./cmd/frontend && \
    go build -o /dalec-redirectio ./cmd/dalec-redirectio

FROM scratch AS frontend
COPY --from=frontend-build /frontend /frontend
COPY --from=frontend-build /dalec-redirectio /dalec-redirectio
LABEL moby.buildkit.frontend.network.none="true"
LABEL moby.buildkit.frontend.caps="moby.buildkit.frontend.inputs,moby.buildkit.frontend.subrequests,moby.buildkit.frontend.contexts"
ENTRYPOINT ["/frontend"]
