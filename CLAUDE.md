# blog.asxp.io — static blog

Zola static site. `flake.nix` builds it (`packages.default`) and serves it
(`nixosModules.default`, `services.blog`: an nginx virtual host on :8081)
on asxpio-services; Traefik on asxpio-ops routes blog.asxp.io there. The
servers take the site from this flake: a push to `main` is picked up by
Renovate in asxpi/iac (flake input `blog`) within about 15 minutes and
deployed by comin, no deploy job here.


## Writing a post

Add `content/<slug>.md` with TOML front matter (`title`, `date`, optional `description`), push to `main`. It is live within about 15 minutes. Local preview: `nix develop -c zola serve` → http://127.0.0.1:1111.

## Stack

- **Zola** from the flake's nixpkgs (`flake.lock`); CI builds
  `nix build .#default`, so a change that breaks the build never reaches
  `main`. `zola` needs `SSL_CERT_FILE` at build time even though the site
  fetches nothing (set in the package).
- nginx settings (404 page, 1-hour cache for css/png/svg/xml/ico) are in
  the module in `flake.nix`.
- `templates/` are hand-written Tera (no theme); `static/style.css` reuses the asxp.io dark palette (`#121212` bg, Open Sans + Hack).

## Rules

- Same hard rule as the main site: **never use the words "consulting" or "advisory"** in posts or copy — "services", "engineering", "implementation" instead.
- Blog content is fully public; no entity details beyond what asxp.io already shows (no banking, no registration number).
- Atom feed at `/atom.xml` (`generate_feeds = true` in `config.toml`).
