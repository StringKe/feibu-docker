# 基础编译环境
FROM node:18-slim AS builder

WORKDIR /app

RUN apt update && apt install -y git curl wget tar

COPY ./install.sh /app/install.sh

RUN cd /app

RUN bash install.sh sample -t fireboomio/fb-init-simple


# 运行镜像
FROM node:18-slim AS runner

WORKDIR /app

VOLUME ["/app/custom-go","/app/custom-ts","/app/store","/app/log","/app/template/node-server"]

COPY --from=builder /app/sample /app

COPY ./entrypoint.sh /app/entrypoint.sh

EXPOSE 9123 9991 9992

ENTRYPOINT ["bash","/app/entrypoint.sh"]