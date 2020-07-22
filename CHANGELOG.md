# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a CHANGELOG](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

2020-07-22 v0.1.2 CreationResponse provides #status_code, #body, #raw

2020-07-22 v0.1.0 Removed ActiveSupport dependency

2020-07-21 v0.1.0: Support basic requests:
- Creation Request (POST): requests URL we can upload to
- Current Offset Request (HEAD): requests current offset fo specified file upload url
- Upload Request (PATCH): uploads a chunk of the file
