$:.unshift("#{File.dirname(__FILE__)}/../lib")
require "pp"
require "agri-controller"
include AgriController

result=[]
test_dir=File.dirname(__FILE__)
Dir.glob(test_dir+"/tc*.rb").each{|file| p file
require(file) if File.file?(file)
}
