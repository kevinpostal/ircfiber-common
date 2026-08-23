# ircfiber-common — Shared Library

D shared library for IRC Fiber. Inter-service contract, models, storage. Used by `ircfiber-site` and `ircfiber-engine` (currently duplicated inline, future versioned dub package).

![D LDC 1.41](https://img.shields.io/badge/D-LDC%201.41-8B0000)

## What this is

- `source/ircfiber/redis/protocol.d` — `RedisKeys`, `IRCCommand`, `NetworkStateSnapshot`, TTLs
- `source/ircfiber/models/*` — `IRCEvent`, `Message`, `Network`, `User`, `IRCChannel`
- `source/ircfiber/db/*` — Mongo models
- `source/ircfiber/storage/*` — Redis buffer + dedup
- `source/ircfiber/irc/*` — `ServerRegistry`, `ConnectionServer`, `EngineJanitor`

## Usage

Currently duplicated in `site/common` + `engine/common` (Option A). Drift guard `site/scripts/check-common-drift.sh --fetch`.

Future (recommended for scale):
```sdl
// site/backend/dub.sdl + engine/dub.sdl
dependency "irc-fiber-common" version="~>0.3.0"
```
Tag `common-v0.3.x` → bump version.

## Build

```bash
dub --root=. build
dub test
```

## License

MIT
