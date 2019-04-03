FROM golang:1-alpine AS build


# Step 1: Checkout
RUN apk add --no-cache git tzdata zip ca-certificates libcap && go get github.com/mholt/caddy/caddy
WORKDIR /go/src/github.com/mholt/caddy/caddy
RUN tag=$(git describe --abbrev=0 --tags) && echo -e "Latest tagged version: $tag" && git -c advice.detachedHead=false checkout "$tag"


# Step 2: Disable Telemetry (the telemetry server somehow always replies 403, so this removes some annoying log messages)
RUN sed -i 's|var EnableTelemetry = true|var EnableTelemetry = false|' caddymain/run.go


# Step 2: Add plugins
RUN for plugin in ${CADDY_PLUGINS}; do sed -i 's|// This is where other plugins get plugged in (imported)|\0\n\t_ "'"$plugin"'"|' caddymain/run.go; done
RUN go get github.com/mholt/caddy/caddy/caddymain


# Step 3: Build
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static" -s -w' -o /go/bin/caddy github.com/mholt/caddy/caddy


# Step 4: Create file structure for empty container
ADD data /build/data
RUN mkdir -p /build/bin /build/etc/ssl/certs /build/lib &&\
    cp /go/bin/caddy /usr/sbin/setcap /bin/busybox /build/bin/ &&\
    cp /lib/ld-musl-x86_64.so.1 /usr/lib/libcap.so.2 /build/lib/ &&\
    cp /etc/ssl/certs/ca-certificates.crt /build/etc/ssl/certs/ &&\
    cd /usr/share/zoneinfo && zip -q -r -0 /build/etc/zoneinfo.zip .


# Step 5: Create an empty container
FROM scratch

COPY --from=build /build /
RUN ["/bin/busybox", "chown", "-R", "1000:1000", "/data"]
RUN ["/bin/setcap", "cap_net_bind_service=ep", "/bin/caddy"]
RUN ["/bin/busybox", "rm", "-rf", "/data/caddy/.gitkeep", "/bin/setcap", "/bin/busybox", "/lib"]

WORKDIR /data
USER 1000
ENV ZONEINFO=/etc/zoneinfo.zip PATH=/bin CADDYPATH=/data/caddy
EXPOSE 80
EXPOSE 443

CMD ["/bin/caddy", "-agree=true", "-conf=/data/Caddyfile", "-log=stdout", "-email=", "-grace=2s"]
