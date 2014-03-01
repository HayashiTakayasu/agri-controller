require "time"
module AgriController
  def thermo_data_each_day(file)
    if File.exist?(file)
      dat=File.read(file)
    else
      dat=file
    end
    x=[]
    y=[]
    line=0
    file_num=0
    last_day_data=0
    change=nil
    date=Time.now
    begin 
      dat.each_line do |str|
        line+=1
        #split day data
        #p str
        if str!=""
          data=str.chomp.split(",")
          date=Time.parse(data[0])
          last_day_data=date.day
          change=date if change==nil
        end
        #not change
        if change.day==last_day_data
        #day change
        elsif change.day!=last_day_data
          y[file_num] = change
          change=date
          file_num+=1
        else
          p "??"
        end
          x[file_num]="" if x[file_num]==nil
          x[file_num]+=str
        
        #normal end
        
      end
      y[file_num]=date
    end
    #return split array
    ret=[x,y]
    return ret
  end
  def save_each_day(file="_thermo_data.csv")
    p result=thermo_data_each_day(file)
    x=0
    result[1].each do |date|
      i=date.year.to_s
      j=date.month.to_s
      k=date.day.to_s
      #save_each_day
      filename="./thermo_data/"+i+"-"+j+"-"+k+"_thermo.csv"
      open(filename,"w"){|io| io.print result[0][x]}
      
      x+=1
    end
  end
end

if $0==__FILE__
  save_each_day(file="_thermo_data.csv")
end
