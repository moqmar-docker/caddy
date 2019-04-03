# The smallest possible [Caddy](https://caddyserver.com) image

This is a from scratch container with the Apache-licensed version of the [Caddy](https://caddyserver.com) web server from the latest GitHub tag.

By default, it uses the UID `1000`, so everything must be readable by that user. When using TLS with ACME, `/data/caddy` must also be writable by that user.

**Web root:** `/data/public`  
To just start a webserver (e.g. on http://127.0.0.1:1234/) that serves the current directory, you can use the following command:
```bash
docker run --rm -v "$PWD:/data/public:ro" -p 1234:80 momar/caddy
```

**Caddyfile:** `/data/Caddyfile`  
The default Caddyfile contains just the following:
```
http:// {
    root /data/public
    gzip
}
```

If you want to use a custom Caddyfile, you should mount it directly as a file:
```bash
docker run --rm -v "$PWD/public:/data/public:ro" -v "$PWD/Caddyfile:/data/Caddyfile:ro" -p 80:80 momar/caddy
```

**CADDYPATH:** `/data/caddy`  
SSL certs are stored here, so if you use SSL you probably want to mount this as a volume, too:
```bash
docker run --rm -v "$PWD/public:/data/public:ro" -v "$PWD/Caddyfile:/data/Caddyfile:ro" -v "$PWD/caddy:/data/caddy" -p 80:80 -p 443:443 momar/caddy
```

## Using custom plugins
The default image from the Docker Hub comes without any plugins. To add plugins (in this example, `http.expires` and `http.ratelimit`), you need to build your own version of this image:
```bash
git clone github.com/moqmar-docker/caddy && cd caddy
CADDY_PLUGINS=""
CADDY_PLUGINS="$PLUGINS github.com/epicagency/caddy-expires"
CADDY_PLUGINS="$PLUGINS github.com/xuqingfeng/caddy-rate-limit"
docker build -t momar/caddy:custom
docker run --rm -v "/var/www:/data/public:ro" -p 1234:80 momar/caddy:custom
```

To get the import paths of the plugins listed on the [Caddy website](https://caddyserver.com/download), you can use [`jq`](https://stedolan.github.io/jq/):
```bash
curl https://caddyserver.com/api/download-page | jq -c '.plugins[] | { name: .Name, import: .ImportPath }'
```
