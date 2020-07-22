# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a CHANGELOG](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

In place of release version numbers, we organize via deploys to Production (by Date/Time).

2020-07-22: Removed ActiveSupport dependency

2020-07-21: Support basic requests:
- Creation Request (POST): requests URL we can upload to
- Current Offset Request (HEAD): requests current offset fo specified file upload url
- Upload Request (PATCH): uploads a chunk of the file
