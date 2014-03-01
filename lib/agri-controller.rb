#!ruby
#coding:utf-8
$KCODE="u" if RUBY_VERSION < "1.9.0"

Dir.glob(File.dirname(__FILE__)+"/agri-controller/*.rb").each do |file|
  p file if $DEBUG
  unless file.include?("gruff")
    require file 
  end
end

