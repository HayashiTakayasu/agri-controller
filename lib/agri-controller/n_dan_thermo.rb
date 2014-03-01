#!ruby
#coding:utf-8
require "time"
module AgriController
  ##
  #class N_dan_thermo
  #  How to setting
  #  Time_list=[["time",set_value], ...]
  #            [["5:00",13],["8:29:30",20],["14:00",30],["17:00",10],["18:00",5]]
  #  
  #            Time_list must be order time(don't reverse).[time < time < time]
  #SAMPLE
  #  green_house=N_dan_thermo.new([["5:00",15],["20:00",5]],diff=1)
  #  #   Time.now    # =>6:00
  #  #   now_tempereture=10.0
  #    gerre_house.now_set                   # =>15.0
  #
  #    green_house.cooling?(now_tempereture) # =>false
  #    green_house.hot?(now_tempereture)     # =>false
  #    green_house.heat?(now_tempereture)    # =>false
  #
  #    green_house.warming?(now_tempereture)# =>true
  #    green_house.cool?(now_tempereture)   # =>true
  #    green_house.cold?(now_tempereture)   # =>true
  #    green_house.heating?(now_tempereture)# =>true
  #    
  class N_dan_thermo
    attr_accessor :def,:n,:list,:bool,:dead_value
    attr_accessor :changed_time,:dead_time
    def initialize(list=[["0:00",20]],diff=4,dead_time=5,changed_time=Time.now)
      if list.class==Array
        if list.size==0
          list=[["0:00",15]]
        end
      else
        list=[["0:00",15]]
      end
      @list=list #|| [["0:00",20]]
      @n=list.size
      @diff=diff
      @bool=false
      @changed_time=changed_time
      @dead_time=dead_time
    end
    def save(file,dat=@list)
      Loger::logger(file,Time.now.to_s+","+dat.inspect)
    end
    def boolean(input,set)# =>@bool==true or false
      high=(input>=(set+@diff))
      low=(input<=set)
      change=@bool
      #judge @bool high low
      #if true(high value)
      if @bool==true and low
        @bool=false
      #if false(low value)
      elsif @bool==false and high
        @bool=true
      else
        #nothing change
      end
      if @bool !=change
        @changed_time=Time.now
      end
      return @bool
    end
    
    def dead_time?
      Time.now <= (@changed_time+@dead_time)
    end
    def move?
      !dead_time?
    end
    def set_now(now=Time.now)#(true or false)
      set=@list.last[1]#first_set should be last setting
      @list.reverse.each do |array|
        if now>=Time.parse(array[0])
          #p array
          set=array[1]
          break
        end
      end
      return set
    end
    
    def cooling?(input)
      boolean(input,set_now)
    end
    
    def warming?(input)
      !cooling?(input)
    end
    alias hot? cooling?
    alias cool? warming?
    alias heating? warming?
    alias heat? cooling?
    alias cold? warming?
    
  end
end

if $0==__FILE__
  include AgriController
  x=N_dan_thermo.new(["0:00",20])
  
  x.list=[["0:00",8]]
  x.list=[["5:00",13],["8:30",20],["14:00",30],["18:00",5]]
  #x.list=[["5:00",8],["20:30",20]]
  
  print "x.boolean(value,set)=true or false\n"
  [4,5,9,10,12,9,5.1,5,4].each do|i|
    print "x.boolean(#{i},5)="+x.boolean(i,5).to_s+"\n"
  end
  
  p x
  #p x.boolean(10,5)
  #Array[["time",value(integer)],,,]
  #x.set_now(Time.parse("23:59"))
  #i=x.set_now(Time.parse("14:01"))
  #x.set_now(Time.parse("3:59"))
  #x.boolean(10,i)
  p x.set_now#=5
  p x.warming?(0)
  p x.warming?(5)
  p x.warming?(7)
  p x.warming?(9)
  p x.warming?(11)
  p x.warming?(7)
  p x.warming?(5)
  p x.warming?(3)
  p x.warming?(0)
  p x.set_now#=5
  p x.cooling?(5)
  p x.cooling?(6)
  p x.cooling?(10)
  p x.cooling?(8)
  p x.cooling?(6)
  p x.cooling?(4)
puts
a=N_dan_thermo.new(list=[["0:00",20]],diff=4,dead_time=2)
p a.set_now
p a.cool?(10);sleep 1
#p a
p a.dead_time?

p a.boolean(10,5);sleep 1
#p a
p a.dead_time?

p a.boolean(5,5);sleep 1
#p a
p a.dead_time?
p a.move?
p Time.now
  
end
