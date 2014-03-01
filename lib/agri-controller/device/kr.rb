#!ruby
#coding:utf-8
#require "serial"
#require "bcc"
module AgriController
  module KR
    module_function
    def sample
      "%01#RCCX00000000**\r"
    end
    def send_sample 
      "%01$RC0100**\r"#(**:BCC) 
    end
  end
end

if $0==__FILE__
  if RUBY_PLATFORM.include?("mswin")
  p AgriController::KR::export("%01#RCCX00000000**\r",5)# => "%01$RC020013\r"
  else
    AgriController::KR::export("%01#RCCX00000000**\r","/dev/ttyUSB1") # => "%01$RC020013\r"
  end
end
