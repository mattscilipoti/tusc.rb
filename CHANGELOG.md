# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a CHANGELOG](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

Upcoming v0.1.4: CreationResponse#success?, #blank?
- CreationResponse: body is parsed from JSON
- Copy/paste #blank? from Rails/ActiveSupport

2020-07-22 v0.1.3: CreationRequest accepts :body, :extra_headers
- i.e. Vimeo tus server requires info to be included in the request.

2020-07-22 v0.1.2 CreationResponse provides #status_code, #body, #raw

2020-07-22 v0.1.0: Removed ActiveSupport dependency

2020-07-21 v0.1.0: Support basic requests:
- Creation Request (POST): requests URL we can upload to
- Current Offset Request (HEAD): requests current offset fo specified file upload url
- Upload Request (PATCH): uploads a chunk of the file
