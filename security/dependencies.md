# Dependencies

Every dependency is a long-term maintenance commitment and a potential attack surface. Package installation executes arbitrary code on your machine; abandoned packages decay; excessive dependencies bloat the project.

## When to add vs avoid

- **Add a dependency when** the alternative is maintaining non-trivial domain logic (e.g., cryptography, audio processing) that well-tested libraries already solve.
- **Avoid a dependency when** the functionality is straightforward to implement and maintain in-house.

## Rules

- **Confirm before adding.** Propose the exact package name, source (registry/URL), version, reason, and alternatives considered. Wait for approval.
- **Vet the source.** Check for typosquatting (exact-name match), publisher/maintainer identity, release recency, and activity. Prefer packages that are popular, recent, and actively maintained.
- **Pin the version** via the project's lockfile. No unpinned or latest-tag installs.
- **Install locally, not globally.** Project-level installs only. If the destination is unclear, ask.
- **Consider transitive impact.** A single top-level dep may pull in dozens of transitive deps. Check the impact on bundle size, install time, and surface area before committing.
