require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "miso-java"
    gem.summary = %Q{A library for generating Miso Java web applications.}
    gem.description = %q{Miso is a lightweight MVC Java web framework. This gem is a code generator for building Miso apps.}
    gem.email = "scott@phoreo.com"
    gem.homepage = "http://github.com/cscotta/miso"
    gem.authors = ["C. Scott Andreas"]
    gem.post_install_message = %q{Hello Miso! Type "miso-java-configure" to finish setting up Miso.}
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :default => :rdoc

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "miso-java #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
