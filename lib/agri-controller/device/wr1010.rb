module AgriController
  ##
  #module WR1010
  #  before using,you must check COM_port of WR1010,and set same config.
  #WINDOWS  
  #  How to use
  #    require "agri"
  #    include Agri
  #
  ##########################################################################
  #  
  # Communicate with WR1010(is RS232c Wireless Thermo Recorder,Panasonic.) responce below
  #
  #  WR::help # => Usage string 
  #
  #  WR::send_sample(3) # => "%01#RDD0000000011**r"    #command_sample
  #
  #  res=WR::sample # => "%01$RD0C0129002E000f051301FFFF1E0007040E01FFFF030006023201FFFF020001001A\r" #response sample
  # 
  #  WR::toa(res)#=>[[25.9, 36, 36, "10100001000", 5],
  #                  [26.7, false, 21, "10100001000", 5],
  #                  [26.1, false, 3, "10100001000", 5],
  #                  [26.1, false, 51, "10100001000", 5]
  #                    ]
  #                  DATA meaning:
  #                  [temperature(celsius degrees), humidity(%RH) if defined , past_sec , conditon Flags , Messages and Radio strength]
  #
  module WR1010
    module_function
    ##
    #returns address number of child thermos(5 chars)
    #child_thermo(1)# =>"00003"
    #child_thermo(4)# =>"00015"
    #child_thermo(56)# =>"00223"
    def child_thermo(n)
        if n==0
          y="00000"
        else
          x=n*4-1
          y=x.to_s
          (5-y.size).times{y="0"+y}
        end
      return y
    end
    #thermo_data(recieve_value)# =>["0ff0fffff500ffff","1f00ffffff000000"](ex.)
    def thermo_data(recieve_value)#ex# =>["0ff0fffff500ffff","1f00ffffff000000"]
      begin
        if recieve_value
          str=recieve_value[6..(-4)]
          size=str.size
          if (size)%16 ==0
          array=[]
            (size/16).times do |i|
              array[i]=str.slice!(0..15)
            end
          array
          else
            nil
          end
        else
          nil
        end
      rescue
        return nil
      end
    end

    def thrmo_array(str)
      begin
        result=[]
        str.each do |data|
          #p data ;p data.size
        result_1=[]
          (data.size/4).times do |i| 
            result_1 << data.slice((i*4),4)
          end
          result << anaryze(result_1)
        end
        return result 
      rescue
        return nil
      end
    end
    
    def anaryze(data)#["0201", "2C00", "2400", "0805"]
      result=[]
        #result[0]
                x=thermo_hex_to_i(data[0])
        result << judge(x).to_f/10
        #result[1]
        x2 = thermo_hex_to_i(data[1])
        if x2==65535
          result << false
        elsif x2<=32766
          if x2<=100
            result << x2
          elsif
            result << 100
          end
        else
          #p thermo_hex_to_i(data[1])
          result << false
        end
        #result[2]
        result << thermo_hex_to_i(data[2])
        #result[3]
        result << thermo_hex_to_i(data[3]).to_s(2)
      result
    end
    
    def errors(bit_str)#"10100001000"
      error_list=[]
      #if bit_str
        #p bit_str
        bit=Bit.new(Integer("0b"+bit_str))
        #p bit.bit
        if bit.on?(0)
          error_list << "bit0:causion:battery. "
        end
        
        if bit.on?(1)
          error_list << "bit1:Error:sensor cable. "
        end
        if bit.on?(2)
          error_list << "bit2:causion:Temp is too High or Low. "
        end
        if bit.off?(3)

          error_list << "bit3:Error:FATAL ERROR.child thermo Non-defined. "
        end
        
        #if bit.on?(4)
        #  error_list << "R-on "#"Reray-unit On. "
        #end
        
        #p error_list
        
        #radio power
        size=bit_str.size*-1
        #p bit_str
        #p bit_str.slice((size..-9))
        begin
          radio_power=Integer("0b"+bit_str.slice((size..-9)))
        rescue#if battery empty bit_str="00FFFF0000"
          radio_power=0
        end
        
        if error_list==[]
          begin
            
            return radio_power
          rescue
            return nil
          end
        end
      #else
      #  nil
      #end 
      error_list << radio_power
    end
    
  #+-tempereture judge function
  def judge(x)
    begin 
      bit=Bit.new(x)
      unless bit.on?(15)
        return x
      else
        res= x-65535
        
        #under -100 'c (degrees Celsius)
        #thermo must be error 35536 => "1000101011010000" => -2999.9
        unless res< -1000          
          return res
        else
          return nil
        end
      end
    rescue
      nil
    end
  end
    
    def thermo_hex_to_i(data)
      #hex="f100" # =>241
      x=data.slice(0..1)
      y=data.slice(2..3)
      result=((y+x).to_i(16))
    end
    
    def toa(recieve_value)
      result=[]
      #begin
        if recieve_value
          ret=thermo_data(recieve_value)
          if ret
            x=thrmo_array(ret)
            if x
              x.each do |data|
                ret=errors(data[3])
                data << ret#"10100001000"
                result << data
              end
              return result
            end
          end
        end
      #rescue
        nil
      #end
    end
    
    def parse(recieve_value)
      toa(recieve_value)
    end
    
    def help
 '##
# ++module WR1010
# +Communicate with WR1010(is RS232c Wireless Thermo Recorder,Panasonic.) responce below
#  before using,you must check port of WR1010,and set same config.
#  
# +How to use
#   require "agri"
#   include Agri
#  
#   WR::help # => Usage string 
#
#   WR::send_sample(3) # => "%01#RDD0000000011**r"    #command_sample
#
#   res=WR::sample # => "%01$RD0C0129002E000f051301FFFF1E0007040E01FFFF030006023201FFFF020001001A\r" #response sample
# 
#   WR::toa(res)#=>[[25.9, 36, 36, "10100001000", 5],
#                   [26.7, false, 21, "10100001000", 5],
#                   [26.1, false, 3, "10100001000", 5],
#                   [26.1, false, 51, "10100001000", 5]
#                     ]
#                   DATA meaning:
#                   [temperature(celsius degrees), humidity(%RH) if defined , past_sec , conditon Flags , Messages and Radio strength]
#'
    end

    def sample
      "%01$RD0C0129002E000f051301FFFF1E0007040E01FFFF030006023201FFFF020001001A\r"
    end
    
    def send_sample(n=4)
      #child_thermo(1)# =>"00003"
      channel="01"
      "%"+channel+"#RDD00000"+child_thermo(n)+"**\r"
    end
    
    def send_from_to(a,b)
      channel="01"
      "%"+channel+"#RDD"+child_thermo(a)+child_thermo(b)+"**\r"
    end
    ##This require "serialport"
    #WR1010::read(port="/dev/ttyUSB0",speed=57600,_to=3,from=0)
    #            [_to,from]:[1,0] means 1st thermo only,[3,1] means 2nd 3rd thermo
    # *usualy
    #  WR1010::read(port,speed,thermo_num)
    #
    # *often
    #  WR1010::read(port="/dev/ttyUSB0",speed=57600,_to_addreess=3,from_address=0)
    def read(port="/dev/ttyUSB0",speed=57600,_to__address=1,from_address=0)
      require "rubygems"
      require "serialport"
      #require "timeout"
      command=send_from_to(from_address,_to__address)
      begin
        #timeout(1.5) do
          sp=SerialPort.new(port,speed,8,1,0)#port,baud,byte,stopbit,parityNONE 
          sp.write(command)
          res=sp.gets
        
        #end
      rescue Timeout::Error
        res=nil
      rescue
        res=false
      ensure
        sp.close if sp
      end
      return res
    end
    
  end
end

if $0==__FILE__
require "./bit"
include AgriController
#$:.unshift("../lib")

require 'test/unit'

#require "agri-controller"

class TC_Agri< Test::Unit::TestCase
  include AgriController
  def setup
    @res=WR1010::sample
  end
  
  def test_WR1010
    p WR1010::send_sample(3) # =>
    p WR1010::sample # =>
    p WR1010::toa(WR1010::sample) #=>
    p x=WR1010::read("/dev/ttyUSB0",speed=57600,_to_address=3,from_adress=0)#[1,0] means 1st thermoonly,[3,1] means 2nd 3rd thermo
    p WR1010::parse(x)
  end
end

end
