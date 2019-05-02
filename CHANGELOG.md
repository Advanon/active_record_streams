# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2019-04-19
### Added
- Global hooks for ActiveRecord 4.2.10.
- Overrides to ActiveRecord::Base, ActiveRecord::Relation, ActiveRecord::Persistence to serve callbacks.
- SNS, Kinesis and HTTP stream types.

## [0.1.1] - 2019-04-26
### Added
- Error handlers for streams
- Documentation for error handlers
- Tests for error handlers
- New method to build Message from json

## [0.1.2] - 2019-05-02
### Added
- HTTPS targets support

## [0.1.3] - 2019-05-02
### Changed
- `Content-type` header for the HTTP streams is set as a string to fix doubled content-type issue

## [0.1.4] - 2019-05-02
### Added
- Error-handler switch for `publish` methods

### Changed
- README to reflect the error-handler switch
