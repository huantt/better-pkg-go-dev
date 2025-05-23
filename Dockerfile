FROM nginx:stable as builder

WORKDIR /tmp
RUN export nginx_version=$(nginx -v 2>&1 | awk '{split($0, a); print a[3]}' | awk '{split($0, a, "/"); print a[2]}') && \
    apt-get update && \
        apt-get install -y curl gnupg2 ca-certificates lsb-release git gcc libpcre3 libpcre3-dev zlib1g zlib1g-dev build-essential && \
    echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
    curl https://nginx.org/download/nginx-$nginx_version.tar.gz -o nginx.tar.gz && \
    echo https://nginx.org/download/nginx-$nginx_version.tar.gz && \
        tar -xzvf nginx.tar.gz && \
    cd nginx-$nginx_version && ./configure --with-compat --add-dynamic-module=../ngx_http_substitutions_filter_module && make modules && \
    cp /tmp/nginx-$nginx_version/objs/ngx_http_subs_filter_module.so /tmp/ngx_http_subs_filter_module.so

FROM nginx:stable-alpine as runner
ENV DOMAIN="pkgo.dev"
ENV SIGNATURE="Gopher 🇻🇳"
ENV THEME="atom-one-light"
ENV OLD_GTM_ID="GTM-W8MVQXG"
ENV NEW_GTM_ID="GTM-PKWLDZH2"
COPY --from=builder /tmp/ngx_http_subs_filter_module.so /etc/nginx/modules/
COPY nginx.conf.template /etc/nginx/templates/
COPY static /www/static-files