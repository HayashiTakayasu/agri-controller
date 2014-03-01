#!ruby
#coding:utf-8
$KCODE="s" if RUBY_VERSION < "1.9.0"
require "thread"
module AgriController
  module_function
  def thermo_read(ref="http://maru.selfip.com/cgi-bin/thermo.rb")
    begin
      uri=URI(ref)
      dat=uri.read("Accept-Language" => "ja")
    rescue
      nil
    end
  end
  
  #main_for_proto_house
  def main_new(log="./cgi-bin/log",config="./cgi-bin/config",docs="./htdocs/thermo",kr_port=5)
    log_time=Time.now
    Thread.abort_on_exception=true
    
    #KR port
        kr_response=""
    
    #KR Queue
    q=Queue.new
    queue=Thread.start(q,log,config,kr_port) do |que,lo,co,kr|
      while str=que.pop
        #p str
        res=""
        
        #OUTPUT DATA
        res=KR::export(str,kr).to_s
        
        #LOG
        dat=Time.now.to_s+","+str.chomp+","+res.chomp#+"<br/>"
        Loger::loger(lo+"/kr_command_log.txt",dat)
        if res.include?("R") or str.include?("R")
          #p str+","+res
         
          #response signal
          begin
            
            if res.size>8
              #res="%01$RC0100**\r" (**:BCC)
              p input_num=res.slice(7,1).to_i(16)# =>0..15
              
              b=Bit.new(input_num)
             
              #bit save
              (0..1).each do |x|
                if b.on?(x)
                  yaml_db("wet_sensor",true,co+"/wet#{x}")
                  yaml_db("wet_read",false,co+"/wet#{x}")
                else
                  yaml_db("wet_sensor",false,co+"/wet#{x}")
                  yaml_db("wet_read",false,co+"/wet#{x}")
                end
              end
            else
              #send data lost
              #retry signal
              (0..1).each do |x|
                 yaml_db("wet_sensor",false,co+"/wet#{x}")
                 yaml_db("wet_read",false,co+"/wet#{x}")
              end
              
              ##
              Loger::loger(co+"/wet_input.txt",dat,"w")
            end
          rescue
            sleep 0.1
          #do nothing...
          end
        end
        sleep 0.1
        
        if res.include?("!") or      #include char
           res.include?("$")!=true or#not $
           res=="" or
           res=="false" or
           res.size < 8 or
           (res.size > 9 and res.include?("%01$RC")!=true)
        then
           Loger::loger(lo+"/errors.txt","KR:"+dat+"<br/>")
           Loger::loger(lo+"/errors_.txt","KR:"+dat+"<br/>")
        end
      end
    end
        #thermo_thread starts
        yaml_file="last_thermo_data"
        
        thermo_port=8#6
        thermo_N=4
        th="thermo_define.yml"
        yaml_db(th,[thermo_port,thermo_N],config+"/"+th)
        
        #thermo_loop_thread(yaml_file,thermo_port,thermo_N,sec=30)
        thermo_loop_thread(yaml_file,thermo_port,thermo_N,sec=30,"./cgi-bin/config")
        
        #thermo_logger_thread starts
        thermo_data_logger_thread(thermo_N,"./cgi-bin/config","./cgi-bin/log")
    
    #reset manual bool
    yaml_db("manual_bool01.txt",nil,config+"/manual_bool01.txt")
    yaml_db("manual_bool02.txt",nil,config+"/manual_bool02.txt")
    sleep 0.1
    
    loop do
      catch :reset_signal do
        sleep 0.2
        ##
        #Initialize basic DATA
        
        #THERMO port
          #wr1010 thrmo request
          thermo=yaml_dbr("last_thermo_data",config+"/last_thermo_data")#WR1010::list(thermo_port,thermo_N)      
          
          #if thermo.class==Array and thermo.size==thermo_N
          #  yaml_db("last_thermo_data",thermo,config+"/last_thermo_data")
          #else
          #  p thermo
          #end

        #BIT SETTING
             kr01=Bit.new #KR#01
             kr02=Bit.new #KR#02
          in_bits=Bit.new ##import signal(#KR#01)
            
          change1=false #KR#01
          change2=false #KR#02
          p house1_set=yaml_dbr("house1",config+"/house1")
          house2_set=yaml_dbr("house2",config+"/house2")
           house1=N_dan_thermo.new(house1_set,diff=1,1)
           house2=N_dan_thermo.new(house2_set,diff=1,1)
                
                a=Value_controller.new(steps=4,open_sec=5,#55
                down_sec=3,#35,
                  sensitivity=2,set_value=20,dead_time=15)
                p "house1 Starts at #{(a.up_sec*a.steps).to_s} sec later."
                
                b=Value_controller.new(steps=4,open_sec=5,#55
                  down_sec=3,#35,
                  sensitivity=2,set_value=20,dead_time=15)
                #p "house2 Starts at #{b.reset_time.to_s}(#{(b.up_sec*b.steps).to_s} sec later)."
      
      #wet_sensor SETTING
        delay0=yaml_dbr("wet0_drain",config+"/wet0_drain") || 1
        delay1=yaml_dbr("wet1_drain",config+"/wet1_drain") || 1
        wet0=WetSensor.new(delay0,config+"/wet0")
        wet1=WetSensor.new(delay1,config+"/wet1")
        
      
      #illigate Time DEFINE
        time_array3=yaml_dbr("time_array",config+"/time_array")
        puts "watering set:#{time_array3.inspect}"
        wait_time=yaml_dbr("wait_time",config+"/wait_time")
      
      #start
        start=Time.now
        
        #start time logging
        dat="Start,"+Time.now.to_s
        Loger::loger(config+"/last_bit.txt",dat+"<br/>","w")#Start,#{Time.now}<br/>
        Loger::loger(log+"/log.txt",dat)
        
        #value_controller step change initialize
        change_step=[false,false]
        
        ##
        #MAIN LOOP (break if in_bit(22)==off)
        run_save_flag=nil
        
        loop do
            t=Time.now
            time=t.to_s
              if t.min!=run_save_flag
                run_save_flag=t.min
                #save_run_check_time
                begin 
                  yaml_db("run_check",t,config+"/run_check")
                #retry if error.
                rescue
                  sleep 0.1
                  yaml_db("run_check",t,config+"/run_check")
                end
              end
              if yaml_dbr("reload_flag",config+"/reload_flag")==true
                yaml_db("reload_flag",false,config+"/reload_flag")
                p dat="reload signal:"
                Loger::loger(log+"/log.txt",dat)
                
                sleep 0.1
                throw :reset_signal
              end
                
              #thermo DEFINE
                thermo=nil
                thermo=yaml_dbr("last_thermo_data",config+"/last_thermo_data")
                #last_thermo_time
              
              #illigate Timer
              x=multiple_pulse_timer(time_array3,wait_time)
                #x.bit =>Integer
              
              #wet sensor work
              wet0.commander{ 
                #p "time 0"
                q.push("%01#RCCX00000000**\r")#read request when its time
              }
              
              wet1.commander{
                #p "time 1"
                q.push("%01#RCCX00000000**\r")#read request when its time
              }
              
              
              #illigating check
              kr01.boolbit(wet1.run(x.on?(2)),0)#signal switch
              
              kr01.boolbit(wet0.run(x.on?(0)),1)#illigate line1
              
              kr01.boolbit(wet1.run(x.on?(2)),2)#illigate line2          ##
              
              pomp = wet0.run(x.on?(0)) | wet1.run(x.on?(2))
              kr01.boolbit(pomp,3)#pomp signal
              
              
              #motor bit
              step_str=""
              if thermo.class==Array && thermo.size==thermo_N
                
                #set_temp from N_dan_thermo
                a.set_value=house1.set_now
                b.set_value=house2.set_now
                
                ##
                #Controll
                bit1=a.value_controll(thermo[0][0]) if thermo[0][0] != nil
                bit2=!a.switch
                bit3=b.value_controll(thermo[1][0]) if thermo[1][0] != nil
                bit4=!b.switch
                check_step=[a.now_step,b.now_step]
                
                if check_step != change_step
                  string=[a.set_value,b.set_value].inspect#+check_step.inspect
                  #p [bit1,bit2,bit3,bit4]
                  #p thermo
                  
                  step_str=",step:"+a.now_step.to_s+","+"step:"+b.now_step.to_s+","+string
                  yaml_db("change_step",check_step,config+"/change_step")
                  
                  change_step=check_step.dup
                end
              else
                #2010.4.28 changed 
                
                ##
                #commonly open if thrmo error.
                #house1
                bit1=true #open signal
                bit2=false#motor_off_trap
                
                ##
                #commonly open if thrmo error.
                #house2
                bit3=true #open signal
                bit4=false#motor_off_trap
                
                #dat=Time.now.to_s+":thermo_error!! open full time."+thermo.inspect
              end
              #house1 motor
              kr02.boolbit(bit1,0)
              kr02.boolbit(bit2,1)
              #house2 motor
              kr02.boolbit(bit3,2)
              kr02.boolbit(bit4,3)
              
              ##
              #RESULT BIT OUTPUT IF CHANGED
              #sum bits and check changes
          #KR01 auto
          #p change1
          
          #p config+"/manual_bool01.txt"
          #p yaml_dbr("manual_bool01.txt",config+"/manual_bool01.txt")
          if yaml_dbr("manual_bool01.txt",config+"/manual_bool01.txt")==nil
              if change1 != kr01.bit
                change1=kr01.bit
                
                str=kr01.tos(4,2)
                if thermo!=nil
                  p data="KR01:"+str+","+time+","+
                thermo[0][0].to_s+","+thermo[0][1].to_s+","+thermo[1][0].to_s+","+thermo[2][0].to_s
                else
                  p data="KR01:"+str+"   "+time
                end
                #logging thread
                #Thread.start(data){|dat|
                  
                  Loger::loger(config+"/last_bit.txt",data+"<br/>","w")
                  Loger::loger(log+"/log.txt",data)
                #}
               #str=bits.tos(24,2)
               #str_size=str.size
              
              ##
              #command output
               hex0=str
               hex=Bit.new(hex0.to_i(2)).tos(1,16)
                command="%01#WCCY000000000#{hex}00**\r"
                q.push(command)
              end
            #KR01 manual
            else
              if yaml_dbr("kr01_readable.txt",config+"/kr01_readable.txt")=="OK"
                p "manual KR01"
                #kr1
                hex=yaml_dbr("kr1_bit.txt",config+"/kr1_bit.txt").upcase
                command="%01#WCCY000000000#{hex}00**\r"
                q.push(command)
                
                p data="KR01_manual:"+hex+","+time
                #logging thread
                #Thread.start(data) do |dat|
                  Loger::loger(config+"/last_bit.txt",data+"<br/>","w")
                  Loger::loger(log+"/log.txt",data)
                #end
                yaml_db("kr01_readable.txt",nil,config+"/kr01_readable.txt")
              end
            end
          #KR02 auto
          if yaml_dbr("manual_bool02.txt",config+"/manual_bool02.txt")==nil
            if change2 != kr02.bit
               change2=kr02.bit
              
               str=kr02.tos(8,2)
               if thermo!=nil
           p data="KR02:"+str+","+time+","+thermo[0][0].to_s+","+thermo[0][1].to_s+","+thermo[1][0].to_s+","+thermo[2][0].to_s+step_str
               else
                 p data="KR02:"+str+"   "+time
               end
               #logging thread
               #Thread.start(data){|dat|
                 Loger::loger(config+"/last_bit.txt",data+"<br/>","w")
                 Loger::loger(log+"/log.txt",data)
               #}
               #str=bits.tos(24,2)
               #str_size=str.size
               
               hex1=str.slice(4,4)
               str
               hex2=str.slice(0,4)
               hex_w=Bit.new((hex2+hex1).to_i(2)).tos(2,16)
                command="%02#WCCY00000000#{hex_w}00**\r"
                q.push(command)
            end
          #manual
          else
            if yaml_dbr("kr02_readable.txt",config+"/kr02_readable.txt")=="OK"
              p "manual KR02"
              
              #kr2
              hex_w=yaml_dbr("kr2_bit.txt",config+"/kr2_bit.txt").upcase
              
              if hex_w.size==1
                hex_w="0"+hex_w
              end
              
              command="%02#WCCY00000000#{hex_w}00**\r"
              q.push(command)
              
              p data="KR02_manual:"+hex_w+","+time
              #logging thread
              #Thread.start(data) do |dat|
                Loger::loger(config+"/last_bit.txt",data+"<br/>","w")
                Loger::loger(log+"/log.txt",data)
              #end
              
              yaml_db("kr02_readable.txt",nil,config+"/kr02_readable.txt")
            end
            
          end
          if log_time.hour != t.hour
            log_time=t.dup
            p "watchdog:"+Time.now.to_s
          end
          #p Time.now-t
          
          sleep 0.3
          
          #p Thread.list
          #raise
        end #main_loop
      end   #catch reset_signal
    
    end     #reset_loop
    q.push nil
    queue.join
  end
end
#AgriController::main_new
