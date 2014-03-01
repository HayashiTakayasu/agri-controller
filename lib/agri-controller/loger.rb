require "logger"
#!ruby -Ku
#coding:utf-8
module AgriController
  module Loger
  module_function
  def loger(log_file,data,mode="a",file_size=50000,log_dir2="./cgi-bin/log/old_log")
    #add data to log_file
    logger=Logger.new(log_file,'daily')
    logger.formatter=proc{|severity,datetime,progname,msg| "#{msg}\n"}
    begin
#      x=open(log_file,mode) do |io|
#        io.puts data
#      end
      logger.info(data)
      #rename log_file if size too big
#      if File.size?(log_file)>=file_size
#        i=1
#        bool=true
    rescue => ex
      str=ex.inspect
      str2=$@.inspect
      p "loger:error,#{str}"
      #open(log_dir2+"/log_error.txt","a"){|io|
      logger.error(Time.now.to_s+"|"+
      log_file.to_s+"|"+
      data.to_s+"|"+
      mode.to_s+"|"+
      file_size.to_s+"|"+
       str+str2+"\n"
      )
      #}
      false
      return 
    end
    nil
  end
#  alias logger loger
  end
end
=begin
module AgriController
  module Loger
  module_function
  def loger(log_file,data,mode="a",file_size=50000,log_dir2="./cgi-bin/log/old_log")
    #add data to log_file
    old_log_dir="/old_log"
    dir = File.dirname(log_file)+old_log_dir
    Dir.mkdir(dir) unless File.exist?(dir)
    begin
      x=open(log_file,mode) do |io|
        io.puts data
      end
      
      #rename log_file if size too big
      if File.size?(log_file)>=file_size
        i=1
        bool=true
        while bool
          dir=File.dirname(log_file)
          name=File.basename(log_file,".*")
          ext=File.extname(log_file)
          new_name=dir+old_log_dir+"/"+name+i.to_s+ext
          unless File.exist?(new_name)
            File.rename(log_file,new_name)
            bool=false
          end
          i+=1
        end
      end
    rescue => ex
      str=ex.inspect
      str2=$@.inspect
      p "loger:error,#{str}"
      open(log_dir2+"/log_error.txt","a"){|io|
      io.print Time.now.to_s+"|"
      io.print log_file.to_s+"|"
      io.print data.to_s+"|"
      io.print mode.to_s+"|"
      io.print file_size.to_s+"|"
      io.print str+str2+"\n"
      }
      false
      return 
    end
    nil
  end
#  alias logger loger
  end
end
=end
