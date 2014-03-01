#!ruby
#coding:utf-8

module AgriController
  class Value_controller
    attr_accessor:steps,:now_step,:up_sec,:down_sec,:acting
    attr_accessor:set_value,:controll_bool,:reset_time,:emergency
    
  def initialize(steps=5,up_sec=60,down_sec=open_sec,sensitivity=1,set_value=20,dead_time=2,verbose=false)
      @bit=0

      @steps            =steps            #多段制御>=1
      @up_sec=up_sec
      @down_sec=down_sec          #閉時動作時間（秒）
      @sensitivity      =sensitivity      #感度
      @set_value        =set_value        #設定値
      @dead_time        =dead_time        #不感時間
      @dead_bool        =false
      @now_step=@steps          #現在の段(2010.5.23変更)

      @controll_bool=false #割り込みswitch(0n,0ff)
      @time=Time.now
      @acting=false
      @bool=false         #true(on)  false(off)方向
      @verbose=verbose
      @reset_time=Time.now+@up_sec*@steps+3
      @emergency=false
      p "Value_controller initialized at #{@reset_time}" if @verbose
    end
    
    def switch
      if @now_step==0 or @now_step==@steps or  @emergency==true
        return true
      else
        return @controll_bool
      end
    end
    
    def switch_on
      @controll_bool = true
    end
    
    def switch_off
      @controll_bool = false
    end
    
    def before_value_controll(now_value)
      if now_value > @set_value+@sensitivity*@steps+1
        #too high
        p "too high!" if $DEBUG
        
        @emergency=true
        return true
      
      elsif now_value < @set_value-1
        #too low
        p "too low!" if $DEBUG
        
        @emergency=true
        return false
      
      elsif Time.now < @reset_time
        return true#open first signal(close:false)
      
      else#normaly
        @emergency=false
        return @bool
      end
    end
    
    def value_controll(now_value)
      if @acting==false
        #now_value:nil or tempareture
        if now_value != nil
          high=(now_value <=> @set_value+@sensitivity*(@now_step+1))
          low =(now_value <=> (@set_value+@sensitivity*(@now_step))-2)
        else
          high=1#温度を下げる方向へセット
          low=0 #そのまま
          p Time.now.inspect+" :"+now_value.inspect
          raise "value_controller.rb:60 error!!"
        end
        
        #もし動作中なら、そのときの温度に関係なく動作続行（下記の判定は読みとばす）
        #動作してなくて、且つステップの範囲内でstep_up , step_downさせる
        if @dead_bool==false  
          if high==1 && @now_step<@steps
            #且つ、スイッチがオフ
            if  @controll_bool == false
              #時間
              @time=Time.now
              switch_on#スイッチオン
              @bool=true#return true
              #タイマー時間設定
              step_up 
            end
          elsif low==-1 && @now_step>0
            #且つ、スイッチがオフ
            if  @controll_bool == false
              #時間
              @time=Time.now
              switch_on#スイッチオン
              @bool=false#return true
              #タイマー時間設定
              step_down 
            end
          elsif high==1 && @now_step==@steps
            @bool=true
          elsif low==-1 && @now_step==0
            @bool=false
          else
            #
          end
        end
      end
        
        ##
        #時刻設定
        #スイッチがオン
        #時間までタイマーオン
        #時間になったらスイッチオフ
        #デッドタイム処理
        #スイッチオフ
        #value_controllもnil
        if @bool==true
          x=pulse_timer([@time,@up_sec])
          y=pulse_timer([@time,@up_sec+@dead_time])
        else #@bool==false
          x=pulse_timer([@time,@down_sec])
          y=pulse_timer([@time,@down_sec+@dead_time])
        end
        if y==true
          @acting=true
        else
          @acting=false
        end
        
        if x==true
        elsif x==false && y==true
          switch_off
          @dead_bool = true
        else
          @dead_bool = false
        end
      before_value_controll(now_value)#return
      
=begin
      if now_value > @set_value+@sensitivity*@steps+1
        #too high
        p "too high!" if $DEBUG
        @emergency=true
        return true
      elsif now_value < @set_value-1
        p "too low!" if $DEBUG
        #too low
        @emergency=true
        return false
      else#normaly
        @emergency=false
        return @bool
      end
=end
    end
    
    def step_up
      @now_step+=1 if @now_step < @steps
      return @now_step
    end
    
    def step_down
      @now_step=now_step-1 if @now_step > 0
      return @now_step
    end
  end
end

if $0==__FILE__
  require "multiple_pulse_timer"
  require "setting_io"
  require "n_dan_thermo"
  include AgriController
  p a=Value_controller.new(
    steps=2,
    open_sec=1,
    down_sec=1,
    sensitivity=1,
    set_value=2,
    dead_time=1)
  require "setting_io"
  require "n_dan_thermo"
  house1=N_dan_thermo.new([["17:00",2]],diff=4,5)
  p house1.set_now
  p a.set_value
  p a.value_controll(house1.set_now)
  p a.switch
  
  30.times do |x|
    sleep 0.3
    
    a.set_value=house1.set_now
    p a if x%5==0
      if x>10
        a.set_value=22
      end
    p a.value_controll(x).to_s+","+a.switch.to_s+","+
           a.now_step.to_s+",set:"+a.set_value.to_s+","+
           x.to_s+",e:"+a.emergency.to_s
  end
end
