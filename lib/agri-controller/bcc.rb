module AgriController
  ##
  #module Bcc is simple bcc check SUM
  #
  #=== example
  #
  # require "rubygems"
  # require "agri-controller"
  # include AgriController
  # 
  # Bcc::bcc(str) # =>Bcc_String
  # Bcc::bcc("%01#RCSX0000")         # => "1d"
  #
  # Bcc::bcc?("%01#RCSX00001d\r")    # => true
  # Bcc::bcc?("%01#RCSX0000FF\r")    # => false
  # Bcc::bcc?("%01#RCSX0000","1d\r") # => true
  # Bcc::bcc?("%01#RCSX0000","1d")   # => true
  # Bcc::bcc?("error_str","error")   # => nil
  module Bcc
  module_function
    #_xor(6,2) # =>4
    def _xor(x,y)
      x.ord ^ y.ord
    end
    
    #xor check SUM
    def bcc(str)
      x=str[0]
      (str.size-1).times do |i|
        x=x.ord ^ str[i+1].ord
      end
      #p x
      res=x.to_s(16).upcase
      res="0"+res if res.size==1
      p res
      return res
    end
    
    ## 
    #Bcc::bcc?
    #
    #=== example
    #
    # require "agri-controller"
    # include AgriController
    #
    #     str1="%01#RCSX0000"+"1d\r"
    #  bad_bcc="%01#RCSX0000"+"00\r"
    #     str2="%01#RCSX0000"
    #  Bcc::bcc?(str1)       # =>true
    #  Bcc::bcc?(bad_bcc)    # =>false
    #  Bcc::bcc?(str2,"1D")  # =>true
    #  Bcc::bcc?(str2,"1d\r")# =>true
    def bcc?(str,bcc_char=nil)
      #on Error returns nil...
      begin
        str2=str.chomp.upcase
        unless bcc_char && str2.size>2
          bcc_char=str2[-2..-1]
          str2=str2[0..-3]
        else
          bcc_char=bcc_char.chomp.upcase
        end
          return bcc_char==bcc(str2)
      rescue
        return nil
      end
    end
  end
end

if $0==__FILE__
require "bit"
require "profile"
str="%01#RCSX0000"
include AgriController
p AgriController::Bcc::bcc(str)
str1="%01#RCSX0000"+"1d\r"
str2="%01#RCSX0000"
p Bcc::bcc?(str1)==true
p Bcc::bcc?(str2,"1D")==true
p Bcc::bcc?(str2,"1d\r")==true
1000.times do
Bcc::_xor(rand(256),rand(256))
end
end
