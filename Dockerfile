# Keep in step with the zola in flake.nix (tests, local serve): bump this
# pin together with nixpkgs in flake.lock.
FROM ghcr.io/getzola/zola:v0.23.6 AS build

COPY . /project
WORKDIR /project
# zola is /zola in the image since 0.23, not on PATH
RUN ["/zola", "build"]

FROM nginx:1.30.6-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /project/public /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO /dev/null http://127.0.0.1/ || exit 1
