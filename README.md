# ircfiber-common — Shared Library

**D library — inter-service contract for IRC Fiber.** The single source of truth between `site` (gateway) and `engine` (daemon). Portfolio analog for **shared Python packages** in microservices.

![D LDC 1.41](https://img.shields.io/badge/D-LDC%201.41-8B0000)
![Dub](https://img.shields.io/badge/dub-library-8B0000)

## Why this matters for hiring

At **National Services Group** and **Walmart** I owned shared `Python` packages that 6 brands/millions of users depended on. `common` is the same — `RedisKeys`, `NetworkStateSnapshot`, `ServerRegistry` — change it and both services must stay in sync.

* **Contract:** `source/ircfiber/redis/protocol.d` — `RedisKeys`, `IRCCommand`, `ControlMessage`, `NetworkStateSnapshot`, `StateTTL`
* **Models:** `source/ircfiber/models/*` — `IRCEvent`, `Message`, `Network`, `User`, `IRCChannel`
* **Storage:** `source/ircfiber/db/*` (Mongo), `source/ircfiber/storage/*` (Redis buffer/dedup), `source/ircfiber/irc/*` (`ServerRegistry`, `ConnectionServer`, `EngineJanitor`)

Currently **duplicated inline** in `site/common` + `engine/common` (Option A) — simple, no `submodule` ceremony. Drift guard `site/scripts/check-common-drift.sh --fetch` fails CI on drift.

**Scale path:** Publish as versioned `dub` package:
```sdl
dependency "irc-fiber-common" version="~>0.3.0"  # git URL, Tag common-v0.3.x → bump
```
Then `site`/`engine` depend via version, not copy.

Part of [kevinpostal/irc-fiber](https://github.com/kevinpostal/irc-fiber) superproject — `git clone --recursive` gets it.

## Build

```bash
git clone https://github.com/kevinpostal/ircfiber-common.git
cd ircfiber-common
dub --root=. build
dub test
```

## Links

* Site: [kevinpostal/ircfiber-site](https://github.com/kevinpostal/ircfiber-site)
* Engine: [kevinpostal/ircfiber-engine](https://github.com/kevinpostal/ircfiber-engine)

## License

MIT
