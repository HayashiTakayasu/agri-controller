#coding:utf-8
require 'rubygems'
require 'gruff'
require "date"
require "time"
require "rubygems"
require "agri-controller"
require "agri-controller/gruff"
module AgriController
#thrmo datas to jpg graph
def thermo_gruff2(output_filename="thermo_data.jpg",input_csv_data="thermo_data.csv",range=[1.0,1.0/3,1.0/100],legend=["degree","humidty(1/3)","ppm(1/100)"],view="640x480")
    #data ini
    data=File.read(input_csv_data)
    #delete "#" comments
    res=""
    i=0
    ##
    #day_data
    data.each_line do |str|
      i+=1
      unless (str =~ /\s*#/)==0 
        #p str
        unless str=="\n"
          #p str
          res+=str
        end
      end
    end
    
    #list delete if many
    n2=view.split("x")[0].to_i
    x=i/n2+2
    x=1 if i<n2
    data=res
    thermo_data_hash={}
          
    result=[]
    range.size.times{|i| result[i]=[]}
    
    title_day=""
    line=0
    title=0
    label={}
    hour=0
    day=0
    data.each_line do |str|
      line+=1
      if line%x==0
      dat=str.chomp.split(",")
      #delete if many array
      while dat.size > range.size+1 
         dat.pop
      end
      #p dat[0]
      begin
        
        begin
          time=Time.parse(dat[0]).localtime#DateTime
        rescue
          time=Time.iso8601(dat[0]).localtime#DateTime
        end
        #dat[0].inspect+","+time.to_s
        title=title+1
      rescue
        line=line-1
        next
      end
      
      #title_day
      if title==1
        title_day=time.year.to_s+"/"+time.month.to_s+"/"+time.day.to_s
      end
      
      #line if day change
      time.hour
      if time.day!=day #(day change)
        day=time.day
        label[line]=":"#time.month.to_s+"/"+day.to_s
      elsif time.hour!=hour
           hour=time.hour
           label[title]="|"+hour.to_s
        if time.hour==12
          label[title]="|12"
        end
      else
      end
      p dat
      dat.delete_at(0)
      dat.each_index{|i| 
        begin
          result[i] << dat[i].to_f
        rescue
          result[i] << 0
        end
        } 
      end

    end

    #p label
    result.each_index{|i| result[i]=[ legend[i],result[i].map!{|x|
    # x*range[i]
    begin
      if x > -50 
        x*range[i]
      else
        nil
      end
    rescue
      nil
    end
     } ]}
    
#    result.each_index{|i| result[i]=[ legend[i],result[i].map!{|x| x*range[i] rescue nil} ]}
    #delete no_need data
    legend.each_index do |i|
      unless range[i]
        result.delete_at(i)
        #p "delete #{i}." 
      end
    end
p result    
    #p result[0]
    #p thermo_num
#=begin    
    #p label
        #gruff main
        g = Gruff::Line.new(view)
        g.font = "/usr/share/fonts/vlgothic/VL-Gothic-Regular.ttf"
        g.title="環境データ　"+title_day
        #g.title_font_size =24
        g.theme_37signals
        g.maximum_value = 40
        g.minimum_value = 0
        g.y_axis_increment =2
        
        #g.baseline_value=9
        #g.increment=5
        #dataset
        result.each do |data|
          g.data(*data)
        end
        g.labels =label
        # Default theme
        #p g
        g.write(output_filename)
#=end
  end
end

if $0==__FILE__
#require "profile"
  include AgriController
  #p Dir.pwd
    input_csv_data=ARGV[0] || "./cat.csv"
      #if File.readable?(input_csv_data)
         thermo_gruff2(output_filename="./thermo_data/thermo_data.jpg",input_csv_data, range=[1.0,nil,1.0/100],legend=["温度",nil,"CO2濃度ppm(1/100)"],view="480x480")
        #thermo_gruff2(output_filename="./thermo_data/thermo_data.jpg",input_csv_data,range=[1.0,1.0/3,1.0,nil,1.0,nil,1.0,nil,1.0,nil],legend=["degree","humidty(1/3)","degree","humidty(1/3)","degree","humidty(1/3)","degree","humidty(1/3)","degree","humidty(1/3)"])
        #p Time.now
      #end
end
