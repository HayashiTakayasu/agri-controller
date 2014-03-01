#!ruby
#coding:utf-8
$KCODE="u" if RUBY_VERSION < "1.9.0"

Dir.glob(File.dirname(__FILE__)+"/gruff/*.rb").each do |file|
    require file 
end
