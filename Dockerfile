FROM node:18-alpine

ENV NODE_ENV=production
EXPOSE 8080/tcp

LABEL maintainer="Mercury Workshop"
LABEL summary="Scramjet Proxy"
LABEL description="Service-worker based web proxy for JS-heavy sites"

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@10 --activate
RUN apk add --upgrade --no-cache python3 make g++

COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --prod

COPY . .

ENTRYPOINT [ "node" ]
CMD ["src/index.js"]
