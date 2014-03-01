#!ruby
#coding:utf-8
require "open-uri"
module AgriController
  module_function
  #ネット上のデータをサーモデータとして利用する
  def thermo_read(ref="http://maru.selfip.com/cgi-bin/thermo.rb")
    begin
      uri=URI(ref)
      dat=uri.read("Accept-Language" => "ja")
      return dat
    rescue
      nil
    end
  end
  
  #WRの温度データを、logdirにyaml形式でN_secごとに記録する
  def thermo_loop_thread(yaml_file,thermo_port,thermo_N,sec=3,logdir="./cgi-bin/config",baud=57600)
    Thread.start(yaml_file,thermo_port,thermo_N,sec,logdir,baud) do |name,port,n,s,lo,bau|
      #p "start N:"+n.to_s
      unless RUBY_PLATFORM.include?("mswin")
        wr=Serial.new(WR1010::send_sample(n),port,bau,5)
        wr.set
      end
      
      
      loop do
        thermo=nil
        #load thermo DATA par :sec
        x=0
        
        9.times do |x|
          #p x
          begin
            #res=thermo_read()
            #thermo=eval(res) if res!=nil
            if RUBY_PLATFORM.include?("mswin")
              thermo=WR1010::list(port,n,0.3+x*0.1)#import WR1010 data
            else#linux
              res=wr.serial
              thermo=WR1010::toa(res)
            end
          rescue
            thermo=nil
          end
          Loger::loger(lo+"/../log/errors_.txt",Time.now.inspect+res.inspect+","+x.inspect) if x>2
          break if (thermo.class==Array && thermo.size==n)
          sleep 6
        end
        
        #read error
        #if thermo.class==Array && thermo.size>n
        #  thermo=thermo[0..n-1]
        #end
        
          yaml_db(name,thermo,lo+"/"+name)#save last data
        
        #judge right thermo data
        if thermo.class==Array && thermo.size==n
          #p thermo
          yaml_db("last_thermo_time",Time.now,lo+"/last_thermo_time")
        else
          #p "else"
          
          #error save and next_try after sleep
          dat=Time.now.iso8601+" |thermo_thread| "+thermo.inspect+"<br/>"
          #Loger::loger(lo+"/../log/errors.txt",dat)
          Loger::loger(lo+"/../log/errors_.txt",dat)
          #sleep 600
        end
        sleep s
      end
    end
  end
  require "time"
  def thermo_data_logger_thread(thermo_N=3,config="./cgi-bin/config",log="./cgi-bin/log")
    
    Thread.start(thermo_N,config,log) do |n,c,l|
      #thermo number DEFINE
      
      #begin
        #mainloop
        before=nil
        day_before=Time.now.day
        loop do
          t=Time.now
          min=t.min
          if min!=before
            before=min
            
            t2=t.to_a
            t2[0]=0
            tt=Time.parse(t2[2].to_s+":"+t2[1].to_s+":"+t2[0].to_s)
            #p tt
            ##
            #save DATA LOGGER(default,each o'clock)
            thermo=yaml_dbr("last_thermo_data",c+"/last_thermo_data")
            word=tt.iso8601+","
            
            if thermo.class==Array && thermo.size >= n
              n.times do |a|
                word=word+thermo[a][0].to_s+","+thermo[a][1].to_s+","
              end
              
            else
              #nil data define ['c,%]=[0,false]
              n.times do |a|
                word=word+"0"+","+"false"+","
              end
            end
              #seve data each minute.
              str=word.chop+"\n"
              Loger::loger(l+"/thermo_data.csv",str,"a",150000)
              #thermo_gruff
              #yesterday = (Date.today-1).to_s
              #load yesterday_data
              #filename=l+"/"+yesterday+"_thermo.csv"
              #  if File.exist?(filename)
              #    yesterday_data=File.read(filename)
              #  else
              #    yesterday_data=""
              #  end
                #load today_data
             #   filename=l+"/thermo_data.csv"
             #   if File.exist?(filename)
             #     today_data=File.read(filename)
             #   else
             #     today_data=""
             #   end
              
             # dat=yesterday_data+today_data
             # open(l+"/data.tmp","w"){|io| io.print dat}
          end
          
          sleep 0.3
          day=t.day
          if day_before!=day
            day_before=day
            sleep 5
            Thread.start(l) do |ll|
              last_day=(Date.today-1).to_s
              #thermo_gruff(g+'/'+today+'.jpg',l+"/thermo_data.csv",n,"480x420")
              #p l+'/thermo/'+last_day+"_thermo.csv"
              
              #save data every day if needed.
              #__HERE!!__
              
              #
              File.rename(ll+"/thermo_data.csv",ll+'/thermo/'+last_day+"_thermo.csv")
              open(ll+"/thermo_data.csv","w"){|io| io.print("")}
            end
            sleep 1
          end
          #p Time.now
        end
        sleep 10
    end
  end
end

if $0==__FILE__
require "wr1010"
require "serial"
require "setting_io"
require "loger"
require "bit"
include AgriController
  Dir_cgi         ="./cgi-bin"
  Dir_ht          ="./htdocs"
  
  Dir_log         =Dir_cgi+"/log"
  Dir_config      =Dir_cgi+"/config"
  Dir_thermo_data =Dir_cgi+"/thermo_data"
  
  Dir_gruff       =Dir_ht+"/thermo"
  Dir_gruff_small =Dir_gruff+"/thumb"
  t1=thermo_loop_thread(yaml_file="last_thermo_data",thermo_port=8,thermo_N=4,sec=3)
  t2=thermo_data_logger_thread
t1.join
t2.join
end
