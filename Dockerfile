# 编译
FROM golang:alpine AS builder

# 切换模块源为中国Go模块代理服务器
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# 拉取代码
RUN go install tailscale.com/cmd/derper@latest

# 去除域名验证（删除cmd/derper/cert.go文件的91~93行）
RUN find /go/pkg/mod/tailscale.com@*/cmd/derper/cert.go -type f -exec sed -i '91,93d' {} +

# 编译
RUN derper_dir=$(find /go/pkg/mod/tailscale.com@*/cmd/derper -type d) && \
        cd $derper_dir && \
    go build -o /etc/derp/derper

# 生成最终镜像
FROM alpine:latest

WORKDIR /apps

COPY --from=builder /etc/derp/derper .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

ENV LANG=C.UTF-8

# 创建软链接 解决二进制无法执行问题 Amd架构必须执行，Arm不需要执行
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# 添加源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 安装openssl
RUN apk add openssl && mkdir /ssl

# 生成自签10年证书
RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /ssl/www.baidu.com.key -out /ssl/www.baidu.com.crt -subj "/CN=www.baidu.com" -addext "subjectAltName=DNS:www.baidu.com"


#CMD ./derper --hostname=www.baidu.com --a=36666 --certmode=manual --certdir=/ssl

ENV DERP_DOMAIN=www.baidu.com
ENV DERP_CERT_MODE=manual
ENV DERP_CERT_DIR=/ssl
ENV DERP_ADDR=:443
ENV DERP_STUN=true
ENV DERP_STUN_PORT=3478
ENV DERP_HTTP_PORT=80
ENV DERP_VERIFY_CLIENTS=false
ENV DERP_VERIFY_CLIENT_URL=""

CMD ./derper --hostname=$DERP_DOMAIN \
    --certmode=$DERP_CERT_MODE \
    --certdir=$DERP_CERT_DIR \
    --a=$DERP_ADDR \
    --stun=$DERP_STUN  \
    --stun-port=$DERP_STUN_PORT \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS \
    --verify-client-url=$DERP_VERIFY_CLIENT_URL
