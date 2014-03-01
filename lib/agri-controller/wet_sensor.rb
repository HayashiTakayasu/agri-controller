#!ruby
#coding:utf-8

module AgriController
  module_function
  ##
  # *Wet sensor.rb
  # *X seconds waits and stops when Sensor sensed. 
  #
  # inbit=Wet_sensor.new(5)     
  # inbit.keeper(bit_bool,sensor_bool)# =>Nil or True or False
  #        <Turns False after 5 seconds when sensor_bool true.> 
  # 
  class Wet_sensor
    def initialize(wait=0)
      @keep=false
      @wait=wait
      @time=Time.now
      @bool=false
    end
    #bitがnil(bitがオンの前)はnil
    #bitがtrue(signalが1回でもtrueなら、以降の結果をwait秒待ってから、false
    #bitがfalse(false)
    #
    def keeper(bit,signal)
     if bit==nil
       @keep=false
       @bool=false
       return nil
     elsif bit==false
       @keep =false
       @bool=false
       return false
     
     elsif bit==true
     
       if signal==true
         p "sensed" if $DEBUG
         if @keep==false
            #set wait_time
            if Time.now >=@time
              p "wait="+@wait.to_s if $DEBUG
              @time=Time.now+@wait
            end
            @keep=true
         end
       end
       if (Time.now >=@time) and (@keep==true)
          @bool=true
       end
       return (!@bool and bit)
     end
    end
  end
end

if $0==__FILE__
include AgriController
p inbit=Wet_sensor.new(0)

p inbit.keeper(nil,false) # =>nil
p inbit.keeper(true,false)# =>true
#p inbit 
p inbit.keeper(true,true)# =>false
#p inbit
p inbit.keeper(true,false)# =>false
p inbit.keeper(true,true)# =>false
p inbit.keeper(true,false)# =>false
#p inbit
p inbit.keeper(false,true)# =>false
p inbit

p inbit=Wet_sensor.new(1)

p inbit.keeper(nil,false) # =>nil
p inbit.keeper(true,false)# =>true
#p inbit 
p inbit.keeper(true,true)# =>true
sleep 0.5
p inbit.keeper(true,false)# =>true
sleep 0.3
p inbit.keeper(true,false)# =>false
sleep 0.5
#p inbit
p inbit.keeper(true,false)# =>false
p inbit.keeper(true,true)# =>false
p inbit.keeper(true,false)# =>false
#p inbit
p inbit.keeper(false,true)# =>false
p inbit
end

