# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a CHANGELOG](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

Upcoming v0.5.0: Log source is tus code
- move Responsorial to TusClient namespace
- move HttpService to lib/, tusc/ contains tus code.
- tests use std log (log/tusc.log) vs. log/tusc_test.log

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
