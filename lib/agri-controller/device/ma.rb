module AgriController
module MA
module_function
  #"\u0002P02EB3D\r\u0002B120C60\r\u0002n4E530F\r\n"
  def sample
    samples[0]
  end

  #5 samples in Array
  def samples
    ["\u0002P02EB3D\r\u0002B120C60\r\u0002n4E530F\r\n",
     "\u0002n4E5915\r\u0002P02E83A\r\u0002B120B5F\r\n",
     "\u0002n4E4C08\r\u0002P02F042\r\u0002B12075B\r",
     "nonono!\rbadchar!",
     nil]
    #ppms=[747,744,752]
  end

  #check_sum("\u0002P02EB3D") # =>"3D"
  #check_sum("\u0002P02EB") # =>"3D"
  def check_sum(str)
      x=str.chomp
      #sum=x[-2..-1]
      #p str[1]
      int1=str[1].ord
      int2=str[2..3].to_i(16)
      int3=str[4..5].to_i(16)
      check_sum=(int1+int2+int3).to_s(16)
      
      if check_sum.size<=1
        check_sum="0"+check_sum
      elsif  check_sum.size>2
        check_sum=check_sum.slice(-2,2)
      end
      #p check_sum.upcase
      return check_sum.upcase
  end
  
  #check_sum?("\u0002P02EB3D")    # =>true
  #check_sum?("\u0002P02EB","3D") # =>true
  #check_sum?("\u0002P02EB","0F") # =>false
  #check_sum?("bad")              # =>nil
  def check_sum?(str,sum=str[-2..-1])
    begin
      res        =check_sum(str)
      return res== sum
    rescue
      return nil
    end
  end

  #parce("\x02P02EB3D\r\x02B120C60\r\x02n4E530F\r\n") # =>{"ppm"=>747, "Celsius Degree"=>15.600000000000023}
  def parse(str)

    hash={}
    
    begin
      list=str.chomp.split("\r")
      list.each do |x|
        if check_sum?(x)
          if x[1]=="P"
            a=x.slice(2,4).to_i(16)
              hash["ppm"]=a
              
          elsif x[1]=="B"
             a=x.slice(2,4).to_i(16)
             hash["Celsius Degree"]=a/16.0-273.15
              
          elsif x[1]=="A"
             a=x.slice(2,4).to_i(16)/100.0
              hash["humidity"]=a
          end
        else
          return nil
        end
      end
    rescue
      return nil
    end
    return hash
  end
end
end
if $0==__FILE__
include AgriController::MA
  p sample
  samples.each do |str|
    p  res=parse(str)
  end
  p a=File.read("ma.txt")
  p parse(a)
end
