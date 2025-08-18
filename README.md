# Czkawka Flatpak

[Upstream](https://github.com/qarmin/czkawka)

[Flathub](https://flathub.org/apps/com.github.qarmin.czkawka)


# Building from Source
1. Install [`org.flatpak.Builder`](https://github.com/flathub/org.flatpak.Builder) from Flathub
2. Clone `https://github.com/flathub/com.github.qarmin.czkawka` (or your fork)
3. Run `flatpak run org.flatpak.Builder --install --install-deps-from=flathub --force-clean build --user com.github.qarmin.czkawka.yaml`
4. Run `flatpak run com.github.qarmin.czkawka//master`

# Maintenance

Run `./update-deps.sh` to bump the dependencies in `cargo-sources.json`
Install Podman beforehand.

## Linting Manifest

```
flatpak install flathub org.flatpak.Builder
flatpak install flathub org.flathub.flatpak-external-data-checker

flatpak run org.flathub.flatpak-external-data-checker com.github.qarmin.czkawka.yaml

flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest com.github.qarmin.czkawka.yaml
```
