FROM node:22-alpine AS builder
WORKDIR /app

# enable Corepack and pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# install dependencies (copy lock and manifest first for better caching)
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install

# copy source and build
COPY . .
RUN pnpm run build

# stage: runtime
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
EXPOSE 3000

# copy built output and node_modules (if server runtime needs them)
COPY --from=builder /app/.output ./.output
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# start Nitro server
CMD ["node", ".output/server/index.mjs"]