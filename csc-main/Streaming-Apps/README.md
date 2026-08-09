# Streaming Apps

Independent Linux desktop applications for streaming services. Every platform has its own Flatpak application with isolated authentication data, service-specific URL policies, matching launcher metadata, and a repository logo.

## Applications

- [Netflix](Netflix/README.md)
- [Prime Video](PrimeVideo/README.md)
- [JioHotstar](JioHotstar/README.md)
- [Apple TV](AppleTV/README.md)
- [Crunchyroll](Crunchyroll/README.md)
- [MX Player](MXPlayer/README.md)

New streaming applications should use the same layout as the developer apps:

```text
Streaming-Apps/PlatformName/
  flatpak/
  icon/
  resources/
  src/
  install.sh
  uninstall.sh
  manifest.yaml
  package.json
  README.md
```