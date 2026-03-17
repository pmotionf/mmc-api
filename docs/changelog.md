# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-03-16

### Added
- API documentation
- New error codes
- Carrier validation
- Ability to retrieve all track information without specifying a Line ID

### Changed
- **BREAKING:** Unit change for `velocity` and `acceleration` (`dm/s` to `m/s` and `dm/s^2` to `m/s^2`)
- **BREAKING:** Type change for `velocity` and `acceleration` (`uint32` to `float`)
- **BREAKING:** Error enum definitions updated 
- **BREAKING:** Updates to messages related to track and command handling.
- **BREAKING:** Pull command target behavior 
- Release pipeline and artifacts updated
- API version handling merged into server message structure


### Removed
- Unused protobuf enum values
- Documentation component `stabledocs`

### Fixed
- Documentation build issues

## [1.2.1] - 2026-01-21 
- Changelog starting point

[Unreleased]: https://github.com/pmotionf/mmc-api/compare/2.0.0...HEAD
[2.0.0]: https://github.com/pmotionf/mmc-api/compare/protobuf-api-1.2.0...protobuf-api-2.0.0
[1.2.1]: https://github.com/pmotionf/mmc-api/releases/tag/protobuf-api-1.2.0
