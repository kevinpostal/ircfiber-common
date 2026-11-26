# Canonical common contract for work4c014513

Date: 2026-11-26. Branch: `release/arch-common-4c014513`.

## Lineage and scope

The release starts at `e2a7dc079ed6a56f8d92f1380cc471477d1bd88c`, the pre-Nord `7baeceb` lineage plus the upload-library modules from original architecture commit `0fab552`. The unrelated Nord capacity/protocol commit `218f075` is not an ancestor. Canonical main and all site, engine, and infra checkouts remain untouched. No push, deployment, VM launch, or evidence cleanup is part of this lane.

There are **no production behavior changes from e2a7dc0**. Added suppression fixture state and its read branch exist only under `CommonIntegrationTest`. New source tests are unittest-only. The one demonstrated compatibility fix changes only an existing upload-category Mongo parity test: explicitly pass `AggregateOptions.init` to the pinned vibe-d 0.10.3 cursor overload. Its previous `aggregate!Bson(pipeline)` invocation did not compile with that driver. Normal upload queries and deployed upload modules are retained.

## Six deployed-engine deltas retained, not overwritten

Comparison source: engine checkout `/Users/zodiac/LocalWork/ircfiber/ircfiber-infra/engine`, immutable commit `7c8f6e3c`, `common/source/ircfiber/`.

| Module | Canonical contract and consumer action |
| --- | --- |
| `async.d` | `safeFiberRun` and `watchedRunTask` retain their signatures and Task return. Catch recoverable `Exception`, not all `Throwable`. Non-interruption exceptions are reported at static owner labels. Real D Errors must not be silently swallowed. |
| `db/history_suppression.d` | Request marks only for a base's own scope and incoming rename ancestors. Do not form a same-network sibling cross product. Preserve rename/clear barriers, bounded evidence validation, and no-body-replay behavior. Public repository signature is unchanged. |
| `errors.d` | Strict atomic `configureErrorReporting(bool enabled, string dsn, string service, string version, string environment)` replaces legacy configure-then-enable. No `setErrorReportingEnabled`. `captureException!(staticComponent, staticOperation)(Throwable)` returns an `ErrorReport`. Terminal owners may `waitErrorReport(report)`. Do not restore runtime context/extras, raw exception text, stack text, hostnames, stale credentials, redirects, proxy inheritance, or unbounded caller-thread I/O. Explicit DSN files are authoritative and fail closed. Engine startup code must migrate to this API. |
| `holder_client.d` | Startup rejection/timeout throws `HolderStartupException` with immutable `exitCode` 78/75 rather than terminating inside the library. The process owner must report once, wait when appropriate, then preserve that exit status. Transient control errors remain `HolderUnavailableException`. Control-loss reporting is taken once after unlocking the control mutex. No protocol, claim, DIAL, ATTACH, replay, or inventory semantics are changed. |
| `irc/engine_janitor.d` | `runOnce()` still returns `long`. The scheduled loop owns a local `FailureEpisode`, only a completed healthy round rearms it, and admin/manual passes do not share episode outcomes. Interruption remains cancellation. No Redis behavior was changed by this integration. |
| `logging.d` | `logException` remains the local/OTLP diagnostic path. It must not implicitly forward arbitrary log context or extras to Bugsink. Reporting belongs to an explicit static-label failure owner. Public logging signature is unchanged. |

## Native checks

Run from this common checkout with the existing local Dub cache:

```sh
/opt/homebrew/bin/dub build --compiler=/opt/homebrew/bin/ldc2 --config=contract-test --skip-registry=all
/opt/homebrew/bin/dub run --compiler=/opt/homebrew/bin/ldc2 --config=integration-contract-test --build=unittest --skip-registry=all
git diff --check
```

`contract-test` compiles the common library without the Linux host diagnostic endpoint. The integration target compiles common source unittests but installs an explicit runtime allowlist: only `ircfiber.errors`, `ircfiber.holder_client`, and `ircfiber.db.history_suppression` execute. A missing selected module fails, and compilation without `--build=unittest` is rejected. This safety check was run explicitly: `dub build --config=integration-contract-test --compiler=/opt/homebrew/bin/ldc2 --skip-registry=all` failed at the intended `use --build=unittest for integration contracts` static assertion. It never invokes the default broad unittest runner.

Coverage:

- Existing strict DSN/configuration, bounded private JSON projection, BNC allowlist, disabled capture, and completed/expired wait-token tests.
- New authoritative-file tests: missing path, directory, LF/CRLF, empty, extra newline, leading whitespace, NUL, lone CR, and oversized content. Fixtures use a unique temporary directory and remove only their own files.
- Per-instance failure episode latching and healthy recovery with reporting disabled, without network activity.
- Holder address/status parsing and typed startup status 75/78, distinct from transient unavailability.
- Real `suppressedRows` algorithm with an explicitly test-only read-only BSON boundary: sibling mark isolation, incoming rename suppression, retired-old-channel reuse, corrupt-evidence rejection, and 101 independent scopes needing 101 marks rather than 10,201. No database connection is opened.
- Compile-time positive strict reporting and async/janitor/logging API checks, plus negative legacy reporter API checks.
- Runtime recoverable exceptions through both async wrappers, with reporting disabled.
- Deployed upload categorization/name APIs and ownerless library rejection before database access.

The upload parity test first failed compilation at `upload_category.d` on the missing aggregate overload. After its explicit-options fix, the integration target compiled and ran successfully. The real Mongo parity test itself is **not executed** by this target.

Regression sensitivity was also checked by temporarily restoring the deployed engine's old same-network cross-product key-selection loop. The target compiled, then failed specifically at `same-network siblings must not request each other's marks`. Restoring the exact canonical lineage loop returned the target to green. The stale loop is not included in any commit.

## Limits

These are native macOS/aarch64 checks, not Linux application acceptance. No real Redis/Mongo tests, full engine/site build matrix, terminal process-owner exit scenarios, external Bugsink transport, cancellation/Error subprocess crash behavior, holder wire fixtures, VM tests, or deployment were run in this lane. Root owns those integration/release checks. Existing toolchain warnings include a missing LLVM clang resource search directory, Dub's existing services-protocol build-option warning, and existing qualified-import deprecations in `storage/buffer.d` and `db/messages.d`. They do not fail these builds and were not broadened into unrelated changes.
