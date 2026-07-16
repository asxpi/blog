# blog.asxp.io — static blog

Zola static site, built in CI into an nginx container, served behind Traefik on the same prod host as asxp.io. Mirrors the conventions of the sibling `../asxpio` repo (Kaniko build, SSH compose deploy, health-wait); see that repo's CLAUDE.md for the pipeline details.

## Writing a post

Add `content/<slug>.md` with TOML front matter (`title`, `date`, optional `description`), push to `main`. CI rebuilds and deploys. Local preview: `nix develop -c zola serve` → http://127.0.0.1:1111.

## Stack

- **Zola** — version pinned in `Dockerfile` (`ghcr.io/getzola/zola`, no `:latest` tag exists); the `flake.nix` dev shell tracks nixpkgs independently. Bump the Dockerfile pin manually.
- Multi-stage `Dockerfile`: `zola build` → `nginx:alpine` serving the generated `public/`. nginx config in `nginx.conf` (404 page + short static cache).
- `docker-compose.yml`: Traefik labels for `blog.asxp.io`, joins only the external `traefik` network — no storage-stack dependency, fully static, no `.env`.
- Deploy dir on prod: `/opt/blog`. Secrets used (shared with asxpio): `DEPLOY_IP/USER/SSH_KEY`, `FORGEJO_REGISTRY/USER/TOKEN`. Nothing else.
- `templates/` are hand-written Tera (no theme); `static/style.css` reuses the asxp.io dark palette (`#121212` bg, Open Sans + Hack).

## Rules

- Same hard rule as the main site: **never use the words "consulting" or "advisory"** in posts or copy — "services", "engineering", "implementation" instead.
- Blog content is fully public; no entity details beyond what asxp.io already shows (no banking, no registration number).
- Atom feed at `/atom.xml` (`generate_feeds = true` in `config.toml`).
