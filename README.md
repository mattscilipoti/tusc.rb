# tusc.rb: Tus Client for Ruby

tusc.rb is a (tested) Ruby client for the [tus resumable upload protocol](http://tus.io), for Tus-Resumable v1.0.0. Supporting the Core Protocol and some Extentions (see [What is Supported?](#what-is-supported))

> **tus** is a protocol based on HTTP for *resumable file uploads*. Resumable
> means that an upload can be interrupted at any moment and can be resumed without
> re-uploading the previous data again. An interruption may happen willingly, if
> the user wants to pause, or by accident in case of an network issue or server
> outage.

[![Gem](https://img.shields.io/gem/v/tusc)](https://github.com/mattscilipoti.tusc.rb)
[![Build Status](https://travis-ci.com/mattscilipoti/tusc.rb.svg?branch=master&logo=travis)](https://travis-ci.com/mattscilipoti/tusc.rb)
[![Maintainability](https://api.codeclimate.com/v1/badges/93198b592f31d691658d/maintainability)](https://codeclimate.com/github/mattscilipoti/tusc.rb/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/93198b592f31d691658d/test_coverage)](https://codeclimate.com/github/mattscilipoti/tusc.rb/test_coverage)
[![Test Coverage](https://coveralls.io/repos/mattscilipoti/tusc.rb/badge.svg?branch=master)](https://coveralls.io/r/mattscilipoti/tusc.rb)

![Ruby 2.7.x](https://img.shields.io/badge/ruby-2.7-blue)
![Ruby 2.6.x](https://img.shields.io/badge/ruby-2.6-blue)
![Ruby 2.5.x](https://img.shields.io/badge/ruby-2.5-blue)
![GitHub](https://img.shields.io/github/license/mattscilipoti/tusc.rb)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tusc'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tusc

## Usage

- Perform a CreationRequest
- Create an Uploader, passing the:
  - IO object (file)
  - Upload URL (provided by the CreationReponse)
- Start the upload

> We recommend reviewing the specs in `spec/against_tus_server_spec.rb`. There are examples of uploading files (e.g. text, video).

> Each request type has a corresponding response type, which surfaces important information.

> To be uploaded, files are broken into "chunks". You can assign a different chunk size, in bytes,
> via `TusClient.chunk_size=`.
> Note: chunk_size is often bigger than the file size (thus creating one chunk).

> You can pass extra information via :extra_headers and/or :body params. This is helpful for special headers (e.g. Upload-Defer-Length) and tus servers that that need extra information.

### Example

```
require 'tusc'

File.open('path/to/file') do |file|
  creation_request = TusClient::CreationRequest.new(
    tus_creation_url: 'https://example.com',
    file_size: file.size
  )
  creation_response = creation_request.perform
  uploader = TusClient::Uploader.new(
    io: file,
    upload_url: creation_response.upload_url.to_s
  )
  uploader.perform
end
```

## Logging

We log to `log/tusc.log`.

- You can adjust verbosity by setting `TusClient.log_level`
- It defaults to `Logger::INFO`

> Tip: Can combine with Rails logs using `TusClient.logger = Rails.logger`

> Tip: "bunyan" is good tool for viewing "pretty" formatted logs. Note: we're recommend [the CLI](https://github.com/trentm/node-bunyan#installation), not the nodejs library.

## tus overview

> from https://tus.io/faq.html#how-does-tus-work

A tus upload is broken down into different HTTP requests, where each one has a different purpose:

At first, the client sends a POST request to the server to initiate the upload. This upload creation request tells the server basic information about the upload, such as its size or additional metadata. If the server accepts this upload creation request, it will return a successfully response with the Location header set to the upload URL. The upload URL is used to unique identify and reference the newly created upload resource.

Once the upload has been create, the client can start to transmit the actual upload content by sending a PATCH request to the upload URL, as returned in the previous POST request. Idealy, this PATCH request should contain as much upload content as possible to minimize the upload duration. The PATCH request must also contain the Upload-Offset header which tells the server at which byte-offset the server should write the uploaded data. If the PATCH request successfully transfers the entire upload content, then your upload is done!

If the PATCH request got interrupted or failed for another reason, the client can attempt to resume the upload. In order to resume, the client must know how much data the server has received. This information is obtained by sending a HEAD request to the upload URL and inspecting the returned Upload-Offset header. Once the client knows the upload offset, it can send another PATCH request until the upload is completely down.

Optionally, if the client wants to delete an upload because it won’t be needed anymore, a DELETE request can be sent to the upload URL. After this, the upload can be cleaned up by the server and resuming the upload is not possible anymore.

## What is supported?

Core Protocol:

- [X] [HEAD](https://tus.io/protocols/resumable-upload.html#head) (via OffsetRequest/Response)
- [X] [PATCH](https://tus.io/protocols/resumable-upload.html#patch) (via UploadRequest/Response)
- [X] [OPTIONS](https://tus.io/protocols/resumable-upload.html#options) (via OptionsRequest/Response)

Protocol Extensions:

- [X] [Creation](https://tus.io/protocols/resumable-upload.html#creation) (via CreationRequest/Response)
- [ ] [Creation With Upload](https://tus.io/protocols/resumable-upload.html#creation-with-upload)
- [ ] [Checksum](https://tus.io/protocols/resumable-upload.html#checksum)
- [ ] [Termination](https://tus.io/protocols/resumable-upload.html#termination)
- [ ] [Concatenation](https://tus.io/protocols/resumable-upload.html#concatenation)


## TODO:
- [X] Basic upload (via creation request and upload)
- [X] Can pass tus_server specific/extra headers (like Vimeo requires)
- [ ] TusMaxSize (from OptionsRequest) informs max_chunk_size of UploadRequest
- [ ] Can resume failed upload
- [x] Supports "Upload-Metadata" header for POST (via extra_headers of CreationRequest)
- [ ] Supports Upload-Defer-Length

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

- We use rspec, so everything is under `spec/` directory.
- Run via `bin/rspec` or `rake` (the default rake task is :spec)
- Fixture files used for testing are in `spec/fixtures`.
- To test against an actual tus server, run one via `bin/rackup`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattscilipoti/tusc.rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TusClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattscilipoti/tusc.rb/blob/master/CODE_OF_CONDUCT.md).
