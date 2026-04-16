---
name: snyk-patch
description: Scan for Snyk vulnerabilities, plan patches, verify compatibility, and iterate until all high/critical issues are resolved. Use when asked to patch vulns, fix Snyk issues, or remediate dependencies.
---

# Snyk Vulnerability Patching

Scan, plan, patch, and verify dependency vulnerabilities with minimal disruption.

## Phase 0: Prerequisites
1. Check if Snyk CLI is installed: `which snyk`
2. If not found, install via Homebrew: `brew install snyk`
3. Verify installation: `snyk --version`

## Phase 1: Scan
1. Run `snyk test > vulns.txt 2>&1` to populate the vulnerability report — this file serves as a human-readable reference so the developer can review the raw Snyk output alongside the plan
2. Read `vulns.txt` and categorise issues:
   - **Direct upgrade** — version bump fixes the CVE
   - **No direct upgrade** — requires manual intervention (exclusion + forced import, or skip if Low)
3. Present a summary table: dependency, current version, target version, severity, CVE count, fix method

## Phase 2: Plan (enter plan mode)
For each proposed change:
- **Version bumps**: Verify the target version is compatible with the Spring Boot parent BOM and other dependencies. Check whether the parent already manages a safe version.
- **No direct upgrade (High/Critical)**: Propose the lightest fix — typically exclude the transitive vulnerable dependency and import the patched version directly. Identify which dependency pulls it in.
- **No direct upgrade (Low/Medium only)**: Flag but skip — not worth over-engineering.
- Present the full plan and wait for approval before making changes.

### Compatibility checks
- Confirm target versions are released and available on Maven Central
- Confirm patch-level compatibility (no breaking changes)
- Check if Spring Boot parent already manages the target version (align rather than override)
- Identify any transitive dependency conflicts

## Phase 3: Patch
Apply approved changes to `pom.xml`:
- Bump versions in `<properties>` for direct upgrades
- Add `<exclusion>` + explicit `<dependency>` for manual overrides
- Keep changes minimal — do not refactor or reorganise unrelated dependencies

## Phase 4: Verify Build
1. Run `./mvnw verify` — must compile and all tests must pass
2. If build fails, diagnose and fix (likely a compatibility issue), then re-verify

## Phase 5: Re-scan
1. Run `snyk test > vulns.txt 2>&1`
2. If High/Critical issues remain, return to Phase 2 with the new report
3. Repeat until zero High/Critical vulnerabilities
4. Report any remaining Low/Medium "no direct upgrade" issues for awareness

## Phase 6: Cleanup
1. Delete `vulns.txt` so it is not accidentally committed
2. Confirm only `pom.xml` changes remain in the working tree

## Principles
- **Quickest, cleanest, build-safe** — prefer the smallest version bump that resolves the CVE
- **Don't over-engineer** — skip Lows with no direct path, don't restructure dependency trees unnecessarily
- **Verify everything** — never assume a bump is safe without checking compatibility
- **Iterate** — one scan-patch-verify cycle may not catch everything; loop until clean
