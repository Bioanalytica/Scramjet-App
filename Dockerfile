# Node 18 came from upstream Scramjet-App and went EOL in April 2025; fastify 5
# and @fastify/static 10 need Node 20+. Pin the digest; bump deliberately.
FROM node:24.22.1-alpine3.24@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53

ENV NODE_ENV=production
EXPOSE 8080/tcp

LABEL maintainer="Mercury Workshop"
LABEL summary="Scramjet Proxy"
LABEL description="Service-worker based web proxy for JS-heavy sites"

WORKDIR /app

# corepack installs the pnpm version pinned in package.json#packageManager
RUN corepack enable
RUN apk add --upgrade --no-cache python3 make g++

COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./
# Scramjet 2.0.0-alpha, packed from the image that was running on 2026-10-25:
# upstream's releases/download/latest URL now 404s, and the lock never had an
# integrity hash for it.
COPY vendor ./vendor
RUN pnpm install --frozen-lockfile --prod

COPY . .

ENTRYPOINT [ "node" ]
CMD ["src/index.js"]
