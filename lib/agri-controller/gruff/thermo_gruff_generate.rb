#!ruby
#coding:utf-8
module AgriController

  def thermo_gruff_generate(dir_to="./htdocs/thermo",dir_from="./cgi-bin/log/thermo",num=5)
    dir=dir_from+"/*_thermo.csv"
    list=Dir.glob(dir)
    
    list.each do |file|
      #p file
      name=File.basename(file).split(/_/)[0]
      new_name=dir_to+"/"+name+".jpg"
      
      #p name
      #p new_name
      
      unless File.exist?(new_name)
            thermo_gruff(new_name,file,thermo_num=num,"480x420")
      end
      
      new_name=dir_to+"/thumb/"+name+"_s.jpg"
      unless File.exist?(new_name)
            thermo_gruff(new_name,file,thermo_num=num,"240x320")
      end
      #p Time.now
    end
  end
end
