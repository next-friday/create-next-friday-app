# Runs on any OCI container platform. A platform that builds Next.js itself deploys without it. The platform sets `PORT`.
FROM \
  node:26.13.0-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216 \
  AS prune
WORKDIR /app
COPY . .
RUN corepack enable \
  && pnpm dlx "turbo@$(node -p "require('./package.json').devDependencies.turbo")" prune "$(node -p "require('./apps/app/package.json').name")" --docker

FROM \
  node:26.13.0-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216 \
  AS build
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /app
COPY --from=prune /app/out/json/ ./
RUN corepack enable
RUN pnpm install --frozen-lockfile --ignore-scripts
COPY --from=prune /app/out/full/ ./
RUN pnpm --filter ./apps/app build

FROM \
  node:26.13.0-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 HOSTNAME=0.0.0.0
WORKDIR /app
# Apply Alpine security fixes released after the base image, and drop npm, corepack, and yarn: the app never runs them, and their bundled dependencies carry their own CVEs.
RUN apk upgrade --no-cache \
  && rm -rf \
    /usr/local/lib/node_modules \
    /usr/local/bin/npm \
    /usr/local/bin/npx \
    /usr/local/bin/corepack \
    /usr/local/bin/yarn \
    /usr/local/bin/yarnpkg \
    /opt/yarn-*
# Next.js writes .next/cache at runtime. Add `COPY --from=build --chown=node:node /app/apps/app/public ./apps/app/public` when the app has a public/ folder.
COPY --from=build --chown=node:node /app/apps/app/.next/standalone ./
COPY --from=build --chown=node:node /app/apps/app/.next/static ./apps/app/.next/static
USER 1000
HEALTHCHECK --interval=30s --timeout=5s CMD ["node", "-e", "fetch('http://127.0.0.1:' + (process.env.PORT || 3000) + '/health').then(response => process.exit(response.ok ? 0 : 1), () => process.exit(1))"]
CMD ["node", "apps/app/server.js"]
