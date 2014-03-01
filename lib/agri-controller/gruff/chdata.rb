require "date"
#require "pp"

module AgriController
module_function
#配列をcsvにする
#ary2dat([["2012-12-03 07:02:00", 9.0, 27.9, 436.0, "9.0", 0.0, 0.0]]) # =>
#          "2012-12-03 07:02:00,9.0,27.9,436.0,9.0,0.0,0.0\n"
def ary2dat(res)
  str=""
  res.each do |ary|
    ary.each do |dat|
      str=str+dat.to_s+","
    end
    str=str.chop+"\n"
  end
  str
end

#csv文字列を第２リストによって整える
#  ("time"であれば、時間としてパースし、Rなどで使いやすい時間文字列に変換)
#  (同時表示しやすいように､変換｡ falseなどは0になる)
#chdat("2012/12/03 07:02:00,9.0,83.7,436,9.0,83.7,436\n",["time",1.0,1.0/3,1.0,false])
#[["2012-12-03 07:02:00", 9.0, 27.9, 436.0, "9.0", 0.0, 0.0]]
def chdat(str,list)
  str

  res=[]
  str.each_line do |line|
    dat=line.chomp.split(",")
    i=0
    kekka=[]
    dat.each do |datum|
      list[i]
      datum
      if (list[i]!=false) and (list[i]!="time")
        list[i].to_f
        datum.to_f
        kekka << list[i].to_f*datum.to_f
      elsif (list[i]=="time")
        kekka << DateTime.parse(datum).strftime("%Y-%m-%d %H:%M:%S")
      else
        kekka << datum
      end
      i+=1
      
    end
    res << kekka
  end
  res
end  
  
end

if $0==__FILE__
include AgriController
  list=["time",1.0,1.0/3,1.0,false]
  file= ARGV[0] || "2012/12/03 07:02:00,9.0,83.7,436,9.0,83.7,436\n"
  ls=eval(ARGV[1].to_s) || list
  
  p str=chdat(file,list)
  print ary2dat(str)
  
end
