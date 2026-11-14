# Runs on any OCI container platform. A platform that builds Next.js itself deploys without it. The platform sets `PORT`.
FROM \
  node:26.13.0-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216 \
  AS prune
WORKDIR /app
COPY . .
RUN npm install --global corepack@0.36.0 \
  && corepack enable \
  && pnpm dlx "turbo@$(node -p "require('./package.json').devDependencies.turbo")" prune "$(node -p "require('./apps/backoffice/package.json').name")" --docker

FROM \
  node:26.13.0-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216 \
  AS build
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /app
COPY --from=prune /app/out/json/ ./
RUN npm install --global corepack@0.36.0 && corepack enable
RUN pnpm install --frozen-lockfile --ignore-scripts
COPY --from=prune /app/out/full/ ./
# `next build` loads the Payload config, which requires these variables. The values are placeholders for the build only.
# The platform sets the real ones at runtime, and the build never connects to the database.
RUN PAYLOAD_SECRET=build-only DATABASE_URL=postgres://build-only@localhost/build-only APP_URL=http://localhost:3001 pnpm --filter ./apps/backoffice build

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
    /opt/yarn-* \
  && install -d -o node -g node apps/backoffice/media
# Next.js writes .next/cache at runtime. Uploads go to the container filesystem, which is lost on redeploy; use a storage adapter or a mounted volume in production.
COPY --from=build --chown=node:node /app/apps/backoffice/.next/standalone ./
COPY --from=build --chown=node:node /app/apps/backoffice/.next/static ./apps/backoffice/.next/static
USER 1000
HEALTHCHECK --interval=30s --timeout=5s CMD ["node", "-e", "fetch('http://127.0.0.1:' + (process.env.PORT || 3000) + '/health').then(response => process.exit(response.ok ? 0 : 1), () => process.exit(1))"]
CMD ["node", "apps/backoffice/server.js"]
