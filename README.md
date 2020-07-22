# tusc.rb: Tus Client for Ruby

tusc.rb is a Ruby client for the [tus resumable upload protocol](http://tus.io).

**Supports protocol version:** 1.0.0

<img alt="Tus logo" src="https://github.com/tus/tus.io/blob/master/assets/img/tus1.png?raw=true" width="30%" align="right" />

> **tus** is a protocol based on HTTP for *resumable file uploads*. Resumable
> means that an upload can be interrupted at any moment and can be resumed without
> re-uploading the previous data again. An interruption may happen willingly, if
> the user wants to pause, or by accident in case of an network issue or server
> outage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tusc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tusc


## Usage

- Perform a CreationRequest
- Create an Uploader, passing the:
  - IO object (file)
  - upload creation request, provided by the tus server
- Start the upload
- e.g.
```
creation_request = TusClient::CreationRequest.new(tus_creation_url: 'example.com', file_size: io.size)
uploader = TusClient::Uploader(io, creation_request)
uploader.perform
```

## tus overview

> from https://tus.io/faq.html#how-does-tus-work

A tus upload is broken down into different HTTP requests, where each one has a different purpose:

At first, the client sends a POST request to the server to initiate the upload. This upload creation request tells the server basic information about the upload, such as its size or additional metadata. If the server accepts this upload creation request, it will return a successfully response with the Location header set to the upload URL. The upload URL is used to unique identify and reference the newly created upload resource.

Once the upload has been create, the client can start to transmit the actual upload content by sending a PATCH request to the upload URL, as returned in the previous POST request. Idealy, this PATCH request should contain as much upload content as possible to minimize the upload duration. The PATCH request must also contain the Upload-Offset header which tells the server at which byte-offset the server should write the uploaded data. If the PATCH request successfully transfers the entire upload content, then your upload is done!

If the PATCH request got interrupted or failed for another reason, the client can attempt to resume the upload. In order to resume, the client must know how much data the server has received. This information is obtained by sending a HEAD request to the upload URL and inspecting the returned Upload-Offset header. Once the client knows the upload offset, it can send another PATCH request until the upload is completely down.

Optionally, if the client wants to delete an upload because it won’t be needed anymore, a DELETE request can be sent to the upload URL. After this, the upload can be cleaned up by the server and resuming the upload is not possible anymore.

## TODO:
- [X] Basic upload
- [ ] Can pass tus_server specific/extra headers
- [ ] Can resume failed upload
- [ ] Supports Upload-Metadata
- [ ] Supports Upload-Defer-Length


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattscilipoti/tusc.rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TusClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattscilipoti/tusc.rb/blob/master/CODE_OF_CONDUCT.md).
