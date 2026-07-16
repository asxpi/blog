# Zola publishes no :latest tag; bump the pin manually (flake.nix tracks nixpkgs separately).
FROM ghcr.io/getzola/zola:v0.22.1 AS build

COPY . /project
WORKDIR /project
RUN ["zola", "build"]

FROM nginx:1.28-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /project/public /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO /dev/null http://127.0.0.1/ || exit 1
