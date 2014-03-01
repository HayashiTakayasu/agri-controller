#!ruby
#coding:utf-8
module AgriController
  ##
  #=use block when functions must be caption if encountered error.
  # record error(file)
  # *error_caption(file="error_ex"){/RubyScripts/}
  #
  #and retry function.
  #=infinite loop
  #*loop{error_caption(file){/RubyScripts/}}
  def error_caption(file="error_ex")
    begin
      #p "initialize"
      
      #main program
          yield 
    rescue => ex
      #Error handling
      x0=ex.class.to_s
      x1=ex.message
      x2=ex.backtrace.to_s
      
      p x="MAIN :"+Time.now.to_s+","+x0+x1+x2
      Loger::loger(file+".txt",x+"<br/>")
      Loger::loger(file+"_.txt",x+"<br/>")
      sleep 5
      #retry
    #ensure
    end
  end
  
  def error_catch(file="error_log.txt", sleep_sec=5 , cr_code= '</br>')
    begin
          yield 
    rescue => ex
      #Error handling
      x0=ex.class.to_s
      x1=ex.message
      x2=ex.backtrace.to_s
      
      p x="MAIN :"+Time.now.to_s+","+x0+x1+x2
      file.each do |f|
        Loger::loger(f,x+cr_code)
      end
      sleep sleep_sec
      #retry
    #ensure
    end
  end
end
##
#本体のメモ
#データベースを利用する
#ｎ段サーモにおける
#段階の表示

if $0==__FILE__
#使い方
require "./error_caption"
include AgriController
  #p "error_caption"
  error_caption("error"){
      p "foo"#require "main"
  }
end

