# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a CHANGELOG](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

2020-08-20 v0.7.0: Support OPTIONS request, TusClient.chunk_size=, code coverage metric
- Support OPTIONS request via OptionsRequest/Response classes
- Increase default chunk_size to 10MB
- Can assign uploaded chunk_size via TusClient.chunk_size
- Readme lists "What is supported?"
- Add Coveralls (for [code coverage](https://coveralls.io/r/mattscilipoti/tusc.rb) in Travis CI)
- Add CodeClimate support and badge

2020-08-13 v0.6.3: Fix Travis CI error (local tus server)
- Remove unused 'ougai' gem
- Move dev/test/ci dependencies to Gemfile
- Supports ruby 2.5, 2.6, 2.7
- For Travis CI:
  - Use `rake spec_ci`
  - Specify limited dependencies for travis ci

2020-08-13 v0.6.2: Correct gemspec: allowed_push_host, changelog_uri

2020-08-12 v0.6.1: Prepare for deploy to RubyGems
- Updated docs, using yard.

2020-08-12 v0.6.0: Revert to basic ruby Logger, level=INFO
- switch from Ougai::Logger to Ruby Logger.
  - Now, ruby/rails app can assign, e.g. `TusClient.logger = Rails.logger`
  - Still logs :source
- Logger.level = Logger::INFO (was ERROR)
- Add binstub `bin/rackup` (for testing)

2020-08-06 v0.5.0: Logged 'source' is tus code. Namespace support classes.
- Move Responsorial to TusClient namespace
- Move HttpService to TusClient namespace
- Move HttpService to lib/. lib/tusc/ is reserved for tus code.
- Logged 'source' is code from tusc dir, not support libraries
- Tests use std log (log/tusc.log) vs. log/tusc_test.log

2020-08-05 v0.4.6: FIX CreationResponse#body, HttpService, tweak logs
- FIX CreationResponse#body (for blank body)
- Extract HttpService (head, patch, post)
- CreationRequest logs body (used by some tus servers; e.g. Vimeo)
- Log request/response vs. sending/receiving
- #truncate uses ellipse (vs. 3 periods)

2020-07-28 v0.4.5: FIX: Upload 413 code. Extract UploadRequest (used by Uploader)
- FIX: Upload 413 code ("resource's size exceeded"), by adding ContentType to UploadRequest
- Extract UploadRequest from Uploader.push_chunk.

2020-07-27 v0.4.4: FIX: some tus servers return 200 (vs. 204) for upload request
- added specs to split file into multiple chunks

2020-07-24 v0.4.3: FIX: Can upload video files. Testing via tus-server.
- Added tests against local tus-server
- FIX: Uploader now supports uploading video files (using octet-stream vs. detected content type)
  - removes dependency on MimeMagic
- All *Response objects have basic interface: raw, status_code, success?

2020-07-23 v0.4.2: FIX: Uploader#push_chunk had error logging (truncated) body

2020-07-23 v0.4.1: FIX: Upload#perform seeks correct offset.

2020-07-23 v0.4.0: FIX: OffsetResponse default offset, Uploader#content_type
- FIX: OffsetResponse#offset is 0, if Upload-Offset header is not present
- Uploader#content_type detects or uses default

2020-07-23 v0.3.0: FIX: content_type. Allow setting TusClient.log_level
- debug by setting `TusClient.log_level = Logger::DEBUG`
- reduce log rollover sizes to 1MB (200kB for testing)
- FIX: Get appropriate field from MimeMagic or return default type

2020-07-22 v0.2.0: Uploader & OffsetRequest accept extra_headers
- Uploader passes extra_headers to OffsetRequest

2020-07-22 v0.1.6: FIX Requesting offset
- FIX: Uploader#offset_request(er)
- OffsetRequest: accepts URL or URI

2020-07-22 v0.1.5: FIX Requires, FIX #blank CONST conflicts
- FIX: Uploader requires OffsetRequest
- FIX: #blank no longer creates BLANK_RE const if rails already has (via client)

2020-07-22 v0.1.4: CreationResponse#success?, #blank?
- CreationResponse: body is parsed from JSON
- Copy/paste #blank? from Rails/ActiveSupport
- FIX: Uploader.from_file_path factory method (named args)

2020-07-22 v0.1.3: CreationRequest accepts :body, :extra_headers
- i.e. Vimeo tus server requires info to be included in the request.

2020-07-22 v0.1.2 CreationResponse provides #status_code, #body, #raw

2020-07-22 v0.1.0: Removed ActiveSupport dependency

2020-07-21 v0.1.0: Support basic requests:
- Creation Request (POST): requests URL we can upload to
- Current Offset Request (HEAD): requests current offset fo specified file upload url
- Upload Request (PATCH): uploads a chunk of the file
