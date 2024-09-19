# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project conforms to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2024-09-19

### Added

- Added option to send performance monitoring KPI alert messages to a Microsoft Teams channel.
- Added context to the user task documentation.

### Changed

- Breaking: SAS Model Manager model assessment criteria no longer are honored. Specify KPI alert rules instead.
- Project review initially occurs before the timer delay, not after it.

### Fixed

- Fixed check that the project champion model has been published.
- Fixed problem causing champion model selection to be skipped.
- Fixed unhandled 409 (conflict) HTTP error in performance monitoring.
- Fixed problem in which the workflow inadequately validates calculated KPIs.

### Removed

- Removed or merged some user tasks.

## [v1.1.0-beta] - 2024-04-12

### Added

- Added more user tasks to the _Trustworthy AI Life Cycle Workflow Documentation Template_, and added context to the user task documentation.

### Changed

- Model performance monitoring initially occurs before the timer delay, not after it.

### Fixed

- Removed invalid Test Model action.
- Fixed mismatched parentheses in Monitor Model service task URL.

### Removed

- Removed or merged some user tasks.

## [v1.0.0-beta] - 2024-01-19

Initial release