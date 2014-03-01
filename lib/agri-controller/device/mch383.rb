#require "rubygems"
#require "serialport"

module AgriController

##
# MCH383(MCH-383,MCH-383SD) is Tenperature,Humidity,CO2-ppm recorder
#===Usage
# include AgriController::MCH383
# * res=read("COM2")        # =>"\00241040100000643\r\00242010100000310\r\00243190000000612\r"
# * res=read("/dev/ttyUSB0")# =>"\00241040100000643\r\00242010100000310\r\00243190000000612\r"
# 
# * parse(res)              # =>[{"1"=>[64.3, "%"]}, {"2"=>[31.0, "C"]}, {"3"=>[612, "ppm"]}]
#
module MCH383
module_function
  ##
  #This require "serialport" #RUBYGEMS
  def read(port)
    require "rubygems" if RUBY_VERSION < "1.9.0"
    require "serialport"

    #t=Time.now
    res=nil
    begin

     # SerialPort.open(port,9600,8,1,SerialPort::NONE){|sp| sp.read_timeout=100
     # while res=sp.read(1)
     #   if res=="\r"
     #     break
     #   end
     # end
      #}
      #
     #read data
     #SerialPort.open(port,9600,8,1,SerialPort::NONE){|sp| sp.read_timeout=500; res=sp.read(48)}

    sp=SerialPort.new(port,9600,8,1,SerialPort::NONE)
    sp.read_timeout=500
    while res=sp.read(1)
      if res=="\002"
        res=res+sp.read(47)
        break
      end
    end
    sp.close
      #p Time.now-t
      return res # =>"\00241040100000643\r\00242010100000310\r\00243190000000612\r"
    rescue
      return nil
    end
    
  end
  
  def sample
    "\00241040100000643\r\00242010100000310\r\00243190000000612\r"
  end
  
  def data_hash(num)
    case num
    when "01"
      #"Celsius"
      "C"
    when "02"
      #"Fahrenheit"
      "F"
    when "04"
      #"Humidity"
      "%"
    when "19"
      #"CO2 of ppm"
      "ppm"
    else
      nil
    end
  end
  
  def of_10(of_ten)
    case of_ten
    when "0"
      1
    when "1"
      0.1
    when "2"
      0.01
    when "3"
      0.001
    else
      nil
    end
  end

  def value(num,of_ten,positive)
    result=num.to_i * of_10(of_ten)
    if positive=="0"#plus +
      return result
    else#minus -
      return result*(-1)
    end
  end
  
  def to_f(x)
    #x="\00243190000000612\r"
    result={}
    
    if x.chomp.size==15
      begin 
        #first_num=x.slice(1,1)#always "4"
        data_number=x.slice(2,1)
        unit_sign  =x.slice(3,2)
        positive   =x.slice(5,1)
        of_ten     =x.slice(6,1)
        num        =x.slice(7,8)
        
        val=value(num,of_ten,positive)
        
        result[data_number]=[val,data_hash(unit_sign)]
        result
      rescue
        return nil
      end
    else
      nil
    end
  end
  
  def parse(code)
    result={}
    #begin
    data=code.split("\r")
    data.each{|str| x=to_f(str);result[x.keys.first]=x[x.keys.first]}
      #if data[0].size>1
      #  x=to_f(data.last+data[0])
      #  result << x if x
      #end
    #rescue
    #  return nil
    #end
    return result
  end
  
  def list(code) 
    parse(code)
  end
  
  def samples
    ["\00241040100000643\r\00242010100000310\r\00243190000000612\r",
    "\00242010100000311\r\00243190000000612\r\00241040100000643\r",
    "\00243190000000612\r\00241040100000643\r\00242010100000312\r",
    "\r\00243190000000590\r\00241040100000639\r\00242010100000309",
    
    "\00243190000000612\r",
    "not_data",
    nil]
  end
end
end

if $0==__FILE__
require "rubygems"
require "serialport"
#require "agri-controller"
require "yaml"
include AgriController
  if RUBY_PLATFORM =~ (/mswin(?!ce)|mingw|cygwin|bccwin/)
    port="COM2"
  else
    port="/dev/ttyUSB0"
  end
  AgriController::dt{
    1.times do
      res=MCH383::read(port)
      MCH383::parse(res)
      print MCH383::parse(res).to_yaml
    end
  }
end

