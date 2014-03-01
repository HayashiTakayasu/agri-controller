##
#class Bit
#          is simple bit culcurater.
#  if on or off
#        on(bit) # => on bit
#        on(1)   # =>2 (if @bit==0)
#        on(1)   # =>3 (if @bit==1)
#        on(1)   # =>7 (if @bit==5)
#    bit_on(bit) # => on bit
#
#        off(1)  # =>0 (if @bit==2)
#        off(1)  # =>1 (if @bit==3)
#        off(1)  # =>5 (if @bit==7)
#    bit_off(bit)# => off bit
#
#  if check_bit
#     on?(bit)# =>true or false
#    off?(bit)# =>true or false
#
#  boolbit(true,bit) # ==on(bit)
#  boolbit(false,bit)# ==off(bit)
#
#  blink(bit) #=> !bit   (change true<=>false)
module AgriController
  class Bit
  attr_accessor:bit
    def initialize(bit=0)
      @bit=bit
    end
    
    def boolbit(bool,bit)
      if bool
        bit_on(bit)
      else
        bit_off(bit)
      end
    end
    
    def blink(i)
      boolbit(!on?(i),i)
    end
    
    def bit_on(bit)
      unless on?(bit)
        @bit+= 2**bit
      end
      @bit
    end
    
    def tos(int=6,bit_num=16)
      x=@bit.to_s(bit_num)
      
      # 17.tos(1,16) # => "1"
      # 17.tos(2,16) # => "11"
      (int-x.size).times do
        x="0"+x
      end
      
      if x.size > int
        x=x.slice(x.size-int,int)
      end
      
      return x.upcase
    end
    
    def bit_off(bit)
      if on?(bit)
        @bit=@bit - 2**bit
      end
      @bit
    end
    
    def on?(bit)
      str=tos(24,2)
        case str.slice(-1-bit,1)
        when "1"
          true
        when "0"
          false
        else
          nil
        end
    end
    def off?(bit)
      not(on?(bit))
    end
    def help
  "##
  #class Bit
  #          is simple bit culcurater.
  #  if on or off
  #        on(bit) # => on bit
  #        on(1)   # =>2 (if @bit==0)
  #        on(1)   # =>3 (if @bit==1)
  #        on(1)   # =>7 (if @bit==5)
  #    bit_on(bit) # => on bit
  #
  #        off(1)  # =>0 (if @bit==2)
  #        off(1)  # =>1 (if @bit==3)
  #        off(1)  # =>5 (if @bit==7)
  #    bit_off(bit)# => off bit
  #
  #  if check_bit
  #     on?(bit)# =>true or false
  #    off?(bit)# =>true or false
  #
  #  boolbit(true,bit) # ==on(bit)
  #  boolbit(false,bit)# ==off(bit)
  #
  "
   end
   alias on bit_on
   alias off bit_off
  end
end
if $0==__FILE__
#require "profile"
#Test of class Bit
a=AgriController::Bit.new
p a
a.bit_on(1)
a.bit_on(0)
a.bit_on(23)

1000.times do
a.bit_on(1)
end
a.bit_on(3)
a.bit_off(1)
a.bit_off(1)
p x=a.bit
p x.to_s(16)
a.bit_off(4)
p x.to_s(2)
p a.off?(3)
p a.off?(2)
p a.off?(1)
p a.off?(0)
p a.on?(3)
p a.on?(2)
p a.on?(1)
p a.on?(0)
p a
p b=AgriController::Bit.new(11)
p b.bit.to_s(2)
print b.help
c=AgriController::Bit.new(8388621)
p c
p c.tos
p c.boolbit(true,4)
p c.tos
p c.boolbit(false,4)
p c.tos
p c.on(4)
p c.bit
p c.blink(24)
p c.blink(24)
end
