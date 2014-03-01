#!ruby
#coding:utf-8
#$KCODE="u" if RUBY_VERSION < "1.9.0"
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
  def main_linux(log="./cgi-bin/log",config="./cgi-bin/config",docs="./htdocs/thermo",dacs_port="/dev/ttyUSB0")
    log_time=Time.now
    Thread.abort_on_exception=true
        #dacs port
          dacs_port="/dev/ttyUSB1"
        
        #WR1010
        #thermo_thread starts
        yaml_file="last_thermo_data"
        wr_port="/dev/ttyUSB0"
        thermo_port=wr_port#8#6
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
        manual_config =Bit.new(0)#15 & 9 => 9 (AND)
        manual_bit=Bit.new(0)#15 | 9 => 15 (OR)
        
        dacs=Serial.new("W0000000\r",dacs_port)
        dacs.time_out=2
        dacs.set
        res=dacs.serial
        unless res
          res=dacs.serial
        end
        res_i=Dacs::toi(res)
        
        wr=Serial.new(WR1010::send_sample,wr_port,9600,5)
        wr.set
        #thermo=toa(wr.serial)
        #THERMO port
          #wr1010 thrmo request
          thermo=yaml_dbr("last_thermo_data",config+"/last_thermo_data")#WR1010::list(thermo_port,thermo_N)      
          
        #BIT SETTING
             
          dacs_bit=Bit.new        
          in_bits=Bit.new(res_i) ##import signal(dacs)      
          change1=false 
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
        line1=Wet_sensor.new
      
      #illigate Time DEFINE[[10,7,6,3],["17:42"],["17:43"],["18:00"]]
        time_array3=yaml_dbr("time_array",config+"/time_array")
        puts "watering set:#{time_array3.inspect}"
        wait_time=yaml_dbr("wait_time",config+"/wait_time")
      
      #start
        start=Time.now
        
        #start time logging
        dat="Start,"+Time.now.iso8601
        Loger::loger(config+"/last_bit.txt",dat+"<br/>","w")#Start,#{Time.now}<br/>
        Loger::loger(log+"/log.txt",dat)
        
        #value_controller step change initialize
        change_step=[false,false]
        
        ##
        #MAIN LOOP (break if in_bit(22)==off)
        run_save_flag=nil
        
        loop do
            t=Time.now
            time=t.iso8601
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
              #p x
              #x.bit =>Integer
              
              #wet sensor work
              
              #illigating check
              dacs_bit.boolbit(x.on?(2),0)#signal switch
              
              dacs_bit.boolbit(x.on?(0),1)#illigate line1
              
              dacs_bit.boolbit(x.on?(2),2)#illigate line2          ##
              dacs_bit.boolbit(x.on?(4),3)#illigate line3
              
              dacs_bit.boolbit(x.on?(6),4)#illigate line4          ##
              
              pomp =  (x.on?(0)) | (x.on?(2)) | x.on?(4) | x.on?(6)#x.on?(0) | x.on?(2)
              dacs_bit.boolbit(pomp,5)#pomp signal
              
              
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
              dacs_bit.boolbit(bit1,19)
              dacs_bit.boolbit(bit2,20)
              #house2 motor
              dacs_bit.boolbit(bit3,21)
              dacs_bit.boolbit(bit4,22)
              
              ##
              #RESULT BIT OUTPUT IF CHANGED
              #sum bits and check changes
          #dacs_bit auto
          #p change1
          
          #p config+"/manual_bool01.txt"
          #p yaml_dbr("manual_bool01.txt",config+"/manual_bool01.txt")
          if yaml_dbr("manual_bool01.txt",config+"/manual_bool01.txt")==nil
              
              (0..23).each do |x|
                dacs_bit.bool_bit(manual_bit.on?,x) if manual_config.on?(x)
              end             
              
              if change1 != dacs_bit.bit
                change1=dacs_bit.bit
                #p time
                str=dacs_bit.tos(24,2)
                if thermo!=nil
                  p data=str+","+time+","+
                thermo[0][0].to_s+","+thermo[0][1].to_s+","+thermo[1][0].to_s+","+thermo[2][0].to_s
                else
                  p data=str+"   "+time
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
               hex=Bit.new(hex0.to_i(2)).tos(6,16)

                command="W0"+hex+"\r"
                dacs.command = (command)

                res=nil
                xx=0
                10.times do
                  res=dacs.serial
                  break if res
                  if xx==9
                    raise "main_linux.rb __Dacs Fatal error__"
                  end
                  xx+=1
                end
                #p res
              end
            end
          if log_time.hour != t.hour
            log_time=t.dup
            p "watchdog:"+time
          end
          
          sleep 0.8
          #p Time.now-t
          
          #p Thread.list
          #raise
        end #main_loop
      end   #catch reset_signal
    
    end     #reset_loop
    #q.push nil
    #queue.join
  end
end
#AgriController::main_new
