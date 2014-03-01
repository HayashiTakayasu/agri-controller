require 'rubygems'
require './lib/agri-controller/version'
require './license'

  spec = Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    s.summary = "AgriController easily controls the greenhouse with a Personal Computer.(win,linux RS232)"
    s.author="Takayasu Hayashi"
    s.email="joe.ko9ji@gmail.com"
    #s.homepage="http://maru.selfip.com/mygem/"
    s.name = "agri-controller"
    s.version = AgriController::VERSION
    
    #s.requirements << 'rmagick'
    #s.requirements << 'gruff'
    #s.add_dependency('serialport','>= 1.0.4')
    s.require_path = 'lib'
    s.has_rdoc=true
    s.test_files=["test/ts_agri-controller.rb"]
    
    #s.files = Dir.glob("{test,lib}/**/*.rb") 
    s.files = Dir.glob("{lib}/**/*.rb")+
              Dir.glob("test/{ts,tc}*.rb")+
              #Dir.glob("bin/**/*")-
              #Dir.glob("bin/**/thermo_data/*")-
              #Dir.glob("bin/**/options/*")-
              #Dir.glob("bin/**/*.{jpg,*~}")+
              ["agri-controller.gemspec","ChangeLog.txt","LICENSE.txt","gpl-2.0.txt"]
    s.description = <<EOF
    A few graphic scripts can load below.
      No need "gruff".
      You can use "gnuplot","R",or some useful graphic aplications.)
    
    require "agri-controller/gruff"
EOF
  end

