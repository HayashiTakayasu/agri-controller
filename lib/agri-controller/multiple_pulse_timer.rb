#!ruby
#coding:utf-8
#require "time_module"
#require "time"

##require "bit"

module AgriController
  #module Time_module
    def time?(time)
      
      time <= Time.now
    end
    def timer(_from,_to)#_from="12:00:00",_to="12:00:05"]
      if _from.class==Time
        start=_from
      else
        start=Time.parse(_from)
      end
      if _to.class==Time
        end_time=_to
      else
        end_time=Time.parse(_to)
      end
      
      if time?(start)
        #p "time!"
        if time?(end_time)
          #"on!"
          #yield true if block_given
          #p "over"
          yield false if block_given?
          return false
        else
          #p "time!"
          yield true if block_given?
          return true
        end
      end
      nil
    end
    def timers(array)# timers([["12:00","12:00:10"],["13:00","18:00"]])
      #p array
      bool=false
      array.each do |dat|
        bool=bool | timer(dat[0],dat[1])
      end
      return bool#(true,false,nil)
    end
    ##
    #  pulse_timer(["12:00:00",10]) # =>nil   ,if before
    #  pulse_timer(["12:00:00",10]) # =>true  ,if time
    #  pulse_timer(["12:00:00",10]) # =>false ,if over
    def pulse_timer(time)#time=[start_time,seconds] ex["12:00:00",10]
      if time[0].class==Time
        start=time[0]
      else
        start=Time.parse(time[0])
      end
      end_time=start+time[1]
      if time?(start)
        #p "time!"
        if time?(end_time)
          #"on!"
          #yield true if block_given
          #p "over"
          yield false if block_given?
          return false
        else
          #p "time!"
          yield true if block_given?
          return true
        end
      end
      nil
    end
  #pulse_timers([["6:00",400],["11:00",400],["14:00",400],["17:00",300]])
  def pulse_timers(time_array)#time_array=[["12:52:00",10],["12:52:15",3],["7:57:30",10],["6:00",400],["11:00",400],["14:00",400],["17:00",300]]
    bit=false#return bool
    bool=false
      
    time_array.each do |time|
      #p time#
      a=pulse_timer(time)
      bool ||= a
    end
      
      
    #p bool
    if bool
      if bit==false
        bit=true
      end
    end
    return bit
  end
  
  #next list genarate
  def next_pulse(time,sec)
    Time.parse(time)+sec
  end 

  ##modified 2013.10.17
  #multiple_pulse_timer([[sec1=3,4,5],time=["6:00",5],["11:00"],["14:00"],["17:00"]],next_wait_sec=2)
  #returns 
  def multiple_pulse_timer(time_array,pomp_wait_sec=nil)#time_array=[[1,2],["12:52:00"],["12:53"],["7:57:30"],["6:00"],["11:00"],["14:00"],["17:00"]]
    bit=Bit.new
    #time_array=[[1,2,3],["12:52",10],["12:53"]]
    t0=time_array[0]
    size=t0.size
    
    #time expantion
    result=[]
    
    #each time
    (time_array.size-1).times do |i|
      list=time_array[i+1]
      time_table=[]       
      last_sec=0
      
      #each system,and wait
      size.times do |j|
        time_table[i] =[] unless time_table[i]
        #time_list has palse ["12:52",10]
        if list[1]!=nil
          #p i
          #p time_table[i]
          time_table[i] << [(Time.parse(list[0])+last_sec),list[1]]
          last_sec+=list[1]
        else#["12:52:15"]
          time_table[i] << [(Time.parse(list[0])+last_sec),t0[j]]
          last_sec+=t0[j]
        end
        
        if pomp_wait_sec!=nil
          time_table[i] << [(Time.parse(list[0])+last_sec),pomp_wait_sec]
          last_sec+=pomp_wait_sec
        end
      end
      result << time_table[i]       
    end 
    
    #Array.transpose each system
    result=result.transpose
    result.pop
    p result if $DEBUG
    
    x=0
    result.each do |time|
    
    #p time
      bool=pulse_timers(time)
      bit.boolbit(bool,x)
      x+=1
    end
    #p bit
    return bit
  end
    
    def _24hour
      y=[]
      24.times do |x|
      z=x.to_s
      str=":00",10
      if x<10
      str="0"+z+str
      else
      str=z+str
      end
      y << [str]
      end
      y
    end
  #end
end

if $0==__FILE__
  #require "rubygems"
  require "./bit"
  require "time"
  include AgriController
  #p $DEBUG
  require "pp"
  #require "profile"
  t=Time.now
  #10.times do
    pp multiple_pulse_timer([[1,2],["7:57:30",10],["9:21"]],5)
  #end
  p Time.now-t
end
