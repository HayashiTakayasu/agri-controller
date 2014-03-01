require "fileutils"
module AgriController
module_function
def rename_csv(dist,dist_dir,deli=".csv.")
    if ARGV[0]=="-h"
       raise 
    end
    unless File.exist?(dist_dir)
      Dir.mkdir(dist_dir)
    end

    list=Dir.glob(dist+"/*#{deli}*")
    #p list
    list.each do |file|
      basename=File.basename(file)
      dir=File.dirname(file)
      name=basename.split(".")
      if name.last.to_i!=0
        new_name=name[0]+"."+name[2]+"."+name[1]
        #p file
        new_full_name=dist_dir+"/"+new_name
        FileUtils.cp(file,new_full_name)
      end
    end
end
end

if $0==__FILE__
include AgriController
#FileUtils.cp("from","to")
#FileUtils.cp(["list",],"dir")
#Dir.mkdir("dir")
dist=ARGV[0]
dist_dir=ARGV[1]
  begin
    rename_csv(dist,dist_dir)
  rescue
    puts 'Usage::
    
    sample $> ruby rename_csv.rb "." "csv_dir"
  
    ruby rename_csv.rb "from_dir" "to_dir"
  
      Rename and copy
        "from_dir/*.csv.{logger_day_number}" to
          "to_dir/*.{logger_day_number}.csv" 
  
      Ruby Dir::mkdir("to_dir") if not exist.'
  end
end
