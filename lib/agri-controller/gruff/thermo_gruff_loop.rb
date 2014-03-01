#!ruby
#coding:utf-8

#require "thermo_gruff"
#require "thermo_gruff_generate"
module AgriController
  module_function
  def thermo_gruff_loop(verbose=false,dir_to="./htdocs/thermo",dir_from="./cgi-bin/log",num=4,size1="480x420",size2="220x250",sec=120)
    
    p "gruf_start:"+Time.now.iso8601 if verbose
    
    p input_csv_data=dir_from+"/thermo_data.csv"#"data.tmp"
    p output_filename=dir_to+"/thermo_data.jpg"
    
    loop do
      
        #bool=File.readable?(input_csv_data)
        #p "thermo_data_readable:"+bool.inspect
        #if bool
          
          #p input_csv_data
          
          thermo_gruff(output_filename,input_csv_data,num,size1)
          thermo_gruff(dir_to+"/thumb/thermo_data.jpg",input_csv_data,num,size2)
          
          Loger::loger(dir_from+"/thermo_graph_loop.txt",Time.now.iso8601,"w")
        #end
        
        #check 1day thermo_data and generate gruff(and small gruff) below
        thermo_gruff_generate("./htdocs/thermo","./cgi-bin/log/thermo",num)
      sleep sec
      p "gruff_loop:"+Time.now.iso8601 if verbose
    end
  end
end
if $0==__FILE__
require "thermo_gruff"
require "thermo_gruff_generate"
include AgriController

thermo_gruff_loop
end
