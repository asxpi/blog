# Renovate bumps the zola pin; flake.nix (used by the tests) tracks nixpkgs.
FROM ghcr.io/getzola/zola:v0.23.6 AS build

COPY . /project
WORKDIR /project
# The image has no zola on PATH since 0.23 (/bin/zola moved to /zola)
RUN ["/zola", "build"]

FROM nginx:1.28-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /project/public /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO /dev/null http://127.0.0.1/ || exit 1
