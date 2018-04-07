# [Caddy](https://caddyserver.com) Docker Container

This container comes with Alpine (to make it small) and the Apache-licensed version from GitHub.

**Installed plugins:** `http.realip`, `http.ipfilter`, `http.cors`, `http.expires`, `http.ratelimit`

**Web root:** `/data/public`  
This is just for a quick start, you'll probably replace the Caddyfile anyways. But to just start a webserver (e.g. on http://127.0.0.1:1234/) that serves the current directory, you can use the following command:
```
docker run --rm -v $PWD:/data/public -p 1234:80 momar/caddy
```

**Caddyfile:** `/data/Caddyfile`  
When using the container for production/deployment, you should use a single volume at `/data` containing both the data and the Caddyfile, with either `internal /Caddyfile` or a subdirectory for publicly available resources.  
The default Caddyfile is just the following:
```
http:// {
    root /data/public
    gzip
}
```

**CADDYPATH:** `/caddy`  
SSL certs are stored here, so if you use SSL you probably want to mount this as a volume.
