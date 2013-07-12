# encoding: UTF-8

namespace :build do
	desc 'Build all gems'
	task :all do
		gem_specs = []
		Dir.glob('**/*.gemspec').each do |s|
			gem_specs << "#{File.dirname(__FILE__)}/#{s}"
		end

		if not Dir.exists?("all_gems")
			Dir.mkdir( "all_gems" )
		end

		Dir.chdir( "all_gems")

		gem_specs.each do |gem_spec|
			puts "Building #{gem_spec}"
			# We need load .gemspec file
			s = Gem::Specification.load(gem_spec)
			# Now, we create a Gem::Builder object
			g = Gem::Builder.new(s)
			# And then, we build the gem 
			g.build
		end
	end
end

task default: :spec

Dir.glob('rake/lib/tasks/**/*.rake').each { |r| import r }
require 'ci/reporter/rake/rspec'     # use this if you're using RSpec
