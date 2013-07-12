# encoding: UTF-8

namespace :build do
	desc 'Build all gems'
	task :all do
		gem_specs = []
		Dir.glob('**/*.gemspec').each do |s|
			gem_specs << "#{s}"
		end

		if not Dir.exists?("gems_store")
			Dir.mkdir( "gems_store" )
		end

		base_dir = Dir.getwd

		gem_specs.each do |gem_spec|
			puts "Building #{gem_spec}"
			dir, file = gem_spec.split('/')
			# Change directory
			Dir.chdir(dir)
			# We need load .gemspec file
			s = Gem::Specification.load(file)
			# Now, we create a Gem::Builder object
			g = Gem::Builder.new(s)
			# Finaly, we build the gem and move it to our gems store
			gem_file = g.build
			FileUtils.mv( gem_file, "#{base_dir}/gems_store/#{gem_file}" )
			# Return to base dir
			Dir.chdir(base_dir)
		end

	end
end

task default: :spec

Dir.glob('rake/lib/tasks/**/*.rake').each { |r| import r }
require 'ci/reporter/rake/rspec'     # use this if you're using RSpec
