# ircfiber-common — Shared Library

**D library — inter-service contract for IRC Fiber.** The single source of truth between `site` (gateway) and `engine` (daemon). Portfolio analog for **shared Python packages** in microservices.

![D LDC 1.41](https://img.shields.io/badge/D-LDC%201.41-8B0000)
![Dub](https://img.shields.io/badge/dub-library-8B0000)
[![Hits](https://hits.dwyl.com/kevinpostal/ircfiber-common.svg)](https://hits.dwyl.com/kevinpostal/ircfiber-common)

<p align="center"><a href="https://skillicons.dev"><img src="https://skillicons.dev/icons?i=d,py&perline=4" alt="Skills" /></a></p>

## Why this matters for hiring

At **National Services Group** and **Walmart** I owned shared `Python` packages that 6 brands/millions of users depended on. `common` is the same — `RedisKeys`, `NetworkStateSnapshot`, `ServerRegistry` — change it and both services must stay in sync.

* **Contract:** `source/ircfiber/redis/protocol.d` — `RedisKeys`, `IRCCommand`, `ControlMessage`, `NetworkStateSnapshot`, `StateTTL`
* **Models:** `source/ircfiber/models/*` — `IRCEvent`, `Message`, `Network`, `User`, `IRCChannel`
* **Storage:** `source/ircfiber/db/*` (Mongo), `source/ircfiber/storage/*` (Redis buffer/dedup), `source/ircfiber/irc/*` (`ServerRegistry`, `ConnectionServer`, `EngineJanitor`)
* **Outbound holder client:** `source/ircfiber/holder_client.d` — shared protocol-v1 client for the engine, Support and FiberEye; mirrored byte-for-byte in both consumers. HELLO's build identifier comes from `IRCFIBER_BUILD_SHORT` (default `dev`). The former engine-local module is removed, without a compatibility alias.

Currently **duplicated inline** in `site/common` + `engine/common` (Option A) — simple, no `submodule` ceremony. Mirrors are synced by `site/scripts/sync-common.sh` and policed by `site/scripts/check-common-drift.sh --fetch` (fails CI on drift) plus `site/scripts/check-common-version.sh` (version + dep-string consistency).

**Scale path:** Publish as versioned `dub` package:
```sdl
dependency "irc-fiber-common" version="~>0.3.1"  # git URL, Tag common-v0.3.x → bump
```
Then `site`/`engine` depend via version, not copy.

Part of [kevinpostal/irc-fiber](https://github.com/kevinpostal/irc-fiber) superproject — `git clone --recursive` gets it.

## Reply and reaction history

Redis scrollback retains `rp` (target message), `rx` (reaction add) and `ux` (reaction removal), including the `+draft/` aliases, on both event-write paths. The compact keys match Mongo history so reaction TAGMSGs survive noise filtering and replay; typing TAGMSGs remain excluded.

Deploy the engine containing the updated shared writer. Existing Redis rows written without these fields cannot recover them by themselves; restore missing metadata from matching Mongo rows rather than clearing user history.

## Bouncer history lookup

`MessageRepository.ensureIndexes` provisions the `(networkId, channel, msgid, serverId, eid)` index for replay identity checks and exact history cursors. Bouncer attach resolves previously delivered message IDs before answering later history requests; scanning a network's entire event-ID range here can leave native clients waiting for minutes. Existing deployments can create this index online without deleting messages or restarting the bouncer.

## Bounded runtime and coordinated maintenance

Holder clients discover `inventory_v1` before using bounded, metadata-free
inventory pages. Older holders retain the genuine streaming `LIST` fallback;
only selected restoration entries retain their complete metadata. The pinned
vibe-serialization patch is hash-checked by
`scripts/apply-vibe-serialization-patches.sh` before consumer builds.

`archive_protocol` defines durable archive control shared by the gateway and
engine; buffer and Mongo history paths retain ordered event identity.
Runtime memory/diagnostic helpers expose bounded operational evidence without
requiring full session metadata in periodic scans.

Canonical network changes hold one noncopyable `NetworkWriter` across the whole
logical operation: Mongo updates, assignment/configuration changes, control
queues and their acknowledgements. `runNetworkWrite` accepts the existing
`RedisStorage` or `RedisDatabase`; nested repository/control calls take the same
writer rather than opening another connection or readmitting halfway through.
The collector atomically requires no writers before installing exclusion.

Every Mongo/Redis step must acknowledge completion before the scope can release
its token. A caught lost acknowledgement remains uncertain and has no expiry.
Constructor migrations, IPv6 reservation/index work and archive catalog CAS use
the same gate. Ordinary messages, PONG, matching-owner lease renewal and unchanged
runtime snapshots do not become configuration writes.

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