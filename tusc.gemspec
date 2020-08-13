lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tusc/version'

Gem::Specification.new do |spec|
  spec.name          = 'tusc'
  spec.version       = TusClient::VERSION
  spec.authors       = ['Matt Scilipoti']
  spec.email         = ['matt@scilipoti.name']

  spec.summary       = 'Ruby client for [tus](https://tus.io/): open protocol for resumable file uploads'
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/mattscilipoti/tusc.rb'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://github.com/mattscilipoti/tusc.rb'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/mattscilipoti/tusc.rb'
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ougai', '~> 1.8' # for structured logging, child log per file

  spec.add_development_dependency 'amazing_print', '~> 1.2'
  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'tus-server', '~> 2.3'
  spec.add_development_dependency 'webmock', '~> 3.8'
  spec.add_development_dependency 'yard', '~> 0.9'
end
