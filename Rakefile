require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:spec_ci) do |t|
  t.rspec_opts = '--tag ~requires_tus_server'
end

task :default => :spec
