require 'rubygems'
require 'gruff'
require "date"
require "time"
module AgriController
#thrmo datas to jpg graph
def thermo_gruff(output_filename="thermo_data.jpg",input_csv_data="thermo_data.csv",thermo_num=3,view="500x420")
    #data ini
    data=File.read(input_csv_data)
    thermo_data_hash={}

    result=[]
    #arrays generate
    (2*thermo_num).times do
      result << []
    end
    result
    title_day=""
    line=0
    label={}
    hour=0
    day=0
    data.each_line do |str|
      line+=1#line+=
      dat=str.chomp.split(",")
      #p dat[0]
      begin
        time=Time.iso8601(dat[0]).localtime#DateTime
        #dat[0].inspect+","+time.to_s
      rescue
        line=line-1
        next
      end
      #title_day
      if line==1
        title_day=time.year.to_s+"/"+time.month.to_s+"/"+time.day.to_s
      end
      #line if day change
      time.hour
      if time.day!=day #(day change)
        day=time.day
        label[line]=":"#time.month.to_s+"/"+day.to_s
      elsif time.hour!=hour
           hour=time.hour
           label[line]="|"+hour.to_s
        if time.hour==12
          label[line]="|12"
        end
      else
      end
      
      #set thermo datas
      thermo_num.times do |n|
        begin
          x=dat[n*2+1].to_f
          if x>-100
          result[n*2] << x
          else
            result[n*2] << nil
          end
        rescue
          result[n*2] << nil
        end
        #Judge nil data
        if dat[n*2+2]!="false"
          result[n*2+1] << dat[n*2+2].to_f/3
        else
          result[n*2+1] << nil
        end
      end
    end
    #p result
    #p label
        #gruff main
        g = Gruff::Line.new(view)
        g.title="Thermo data since "+title_day
        #g.title_font_size =24
        g.theme_37signals
        g.maximum_value = 35
        g.minimum_value = 5
        g.y_axis_increment = 1
        #g.baseline_value=9
        #g.increment=5
        #dataset
        datasets=[]
        thermo_num.times do |i|
          x=i+1
          datasets[i*2  ]=[("'C:"+x.to_s).intern,result[i*2]]
          datasets[i*2+1]=[("%/3:"+x.to_s).intern,result[i*2+1]]
        end
        #% humidity data delete
        [9,7,5,3].each{|i| datasets.delete_at(i)}
        
        #dataset
        datasets.each do |data|
          g.data(*data)
        end
        g.labels =label
        # Default theme
        #p g
        g.write(output_filename)
  end
end

if $0==__FILE__
  p Dir.pwd
    input_csv_data="./thermo_data/2009-11-21_thermo.csv"
      if File.readable?(input_csv_data)
        thermo_gruff(output_filename="../htdocs/thermo/2009-11-21.jpg",input_csv_data,thermo_num=2,"480x420")
        p Time.now
      end
end
