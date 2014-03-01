#coding:ASCII-8BIT
module AgriController
module TR
module_function
  def parse(str)
    list(str)
  end
  ##
  # *check_sum("\0013\006\f\000\027\000\000\000\000\000\000\000\203\004\372\005")
  #          # =>"\343\001"
  def check_sum(str)
    x=0
    begin
      str.each_byte{|i| x+=i}
      #p x
      to_byte(x)
    rescue
      nil
    end
  end
  ##
  # *check_sum?("\0013\006\f\000\027\000\000\000\000\000\000\000\203\004\372\005\343\001"
  #            # =>true
  # *check_sum?("\0013\006\f\000\027\000\000\000\000\000\000\000\203\004\372\005",
  #             "\343\001") # =>true
  def check_sum?(str1,sum=nil)
    begin
      if sum==nil
        x1=str1.chop.chop
        x2=str1.slice(str1.size-2,2)
      else
        x1=str1
        x2=sum
      end
      #p check_sum(x1)
      #p x2
      return check_sum(x1)==x2
    rescue
      return nil
    end
  end
  
  def toi(num0,num1)
    num1*256+num0
  end
  
  def to_byte(i)
  #  p i
    x2=(i/256).chr
    x1=(i%256).chr
    x1+x2
  end
  
  def to_n(num0,num1)
    begin
      x1=num0
      x2=num1
      unless x2==238#error
        if x2 > 15 
          power=x2.to_s(16).slice(0,1).to_i(16)
          num=x2%16*256+x1
        else
          power=0
          num=x2*256+x1
        end
        res=num*2**power
      else
        res=nil
      end
      res
    rescue
      return nil
    end
  end
  
  ##
  #
  #a=TR::list(TR::sample)
  # =>{:lx=>91.28,
  #    :uv=>0.0,
  #    :lx_sigma=>36.03,
  #    :uv_sigma=>0.0,
  #    :temperature=>11.7,
  #    :humidity=>49.0
  #     }
  def sample
    "\x013\x06\f\x00\xEA(\x00\x00\x13\x0E\x00\x00]\x04\xD2\x05\xB1\x02"
  end
  
  ##
  #"\x1\x33\x0\x0\x0"+"\x34\x0"
  # =>"\x013\x06\f\x00\xEA(\x00\x00\x13\x0E\x00\x00]\x04\xD2\x05\xB1\x02"
  #
  def send_sample
    "\x1\x33\x0\x0"+"\x0\x34\x0"
  end
  ##
  # ==example_data
  #  *a="\0013\006\f\000\027\002\027\002\054\003\072\021\203\004\372\005x\002"
  #  *list(a) # =>{:uv=>0.0, :lx_sigma=>0.0, :uv_sigma=>0.0,
  #               :temperature=>15.5, :lx=>0.23, :humidity=>53.0}
  #  *list("wrong_data")# =>nil
  def list(str)
    a=str
    res={}
    if check_sum?(a)
      a.size==(a[3].ord+a[4].ord*256+7)
      
      #lx
      x1=a[5].ord
      x2=a[6].ord
        #puts "lx"
      lx_=to_n(x1,x2)/100.0
      res[:lx]=lx_
      
      #uv
      x1=a[7].ord
      x2=a[8].ord
        #puts "uv"
      uv_=to_n(x1,x2)/1000.0
      res[:uv]=uv_
      
      #lx_h
      x1=a[9].ord
      x2=a[10].ord
        #puts "lx_accumulated"
      res[:lx_sigma]=to_n(x1,x2)/100.0
      
      #uv_h
      x1=a[11].ord
      x2=a[12].ord
        #puts "uv_accumulated"
      res[:uv_sigma]=to_n(x1,x2)/1000.0
      
      #'C tempereture
      x=a[13].ord+a[14].ord*256-1000
      x1=x/10.0
        #puts "'c"
      res[:temperature]=x1
      
      #% humidity
      x=a[15].ord+a[16].ord*256-1000
      x1=x/10.0
        #puts "humidity"
      res[:humidity]=x1
    else
      res=nil
    end
    res
  end
  
  ##This require "serialport"
  # TR::serial(port) # =>String 
  # Communicate with ESPEC THERMORECORDER(RS-13L:UV,lx,thermo,humidty LOGGER)or T&D TR
  #   **CAUSION** check port permission on Linux.(ls -l <port device>)
  # *USAGE
  # require "rubygems"
  #  require "serialport"
  #  require "timeout"
  #  require "agri-controller"
  #  include AgriController
  # x=TR::read("/dev/ttyUSB0") 
  #     # =>"\0013\006\f\000\f\001\000\000\212(\000\000z\004\232\006#\002"
  #
  # TR::list(x)
  #     # =>{:uv         =>0.0,
  #          :lx_sigma   =>87.44,
  #          :uv_sigma   =>0.0,
  #          :temperature=>14.6,
  #          :lx         =>2.68,
  #          :humidity   =>69.0}
  def read(port="/dev/ttyUSB0")
    require "rubygems"
    require "serialport"
    require "timeout"
    #open
    s=SerialPort.new(port,19200)
    
    #boot up command
    s.write("\x0")
    
    sleep 0.11
    #commnicate command
    s.write("\x1\x33\x0\x0"+"\x0\x34\x0")
     
    #receive
    r=""
    begin
      timeout(2) do
        while c=s.read(1)
          r += c
          break if r.length >= 19
        end
      end
    rescue Timeout::Error
      r=""
    ensure
      s.close #close
    end
    
    return r
  end
end
end
if $0==__FILE__

include AgriController
#include TR
  a=ARGV[0] || ""
p a.force_encoding("ASCII-8BIT") if RUBY_VERSION > "1.9"
#example_data
#a="\0013\006\f\000\027\002\027\002\054\003\072\021\203\004\372\005x\002"
#p check_sum(a.chop.chop)
#p check_sum?(a)
#p check_sum?(a.chop.chop,"\343\001")
#puts
p x=TR::list(a)
if x
  p x[:temperature]
  p x[:humidity]
  p x[:lx]
  p x[:uv]
end
#p TR::sample.encoding if RUBY_VERSION > "1.9"
#p TR::list(TR::sample)
p y=TR::read("/dev/ttyUSB1")
p TR::list(y)
#p TR::list("foo"+a)
#p TR::list("")
end
