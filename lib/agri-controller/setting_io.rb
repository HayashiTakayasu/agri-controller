#!ruby
#coding:utf-8
require "yaml"
require "yaml/store"

module AgriController
  module_function
    module_function
    def yaml_db(name,value,file=name)#"db.yaml")
      #p name
      db=YAML::Store.new(file)
      db.transaction do
        db[name.to_s]=value
      end
    end
    
    def yaml_dbr(name,file=name)#"db.yaml")
      #p file
      db=YAML::Store.new(file)
      db.transaction(:read_only) do
        db[name.to_s]
      end
    end
    def yaml_key(file)
      db=YAML::Store.new(file)
      db.transaction(:read_only) do
        db.roots.sort
      end
    end

    def yaml_dump(data,filename="setting_io.yml")
      yaml_db(name=filename,value=data,"db.yaml")
    end
    
    def yaml_load(filename="setting_io.yml")
      res=yaml_dbr(name=filename)#,"db.yaml")
      if res == nil
        if File.exist?(filename)
          a=File.read(filename)
          if a
            x=YAML.load(a)
            yaml_db(name=filename,x,name)
          end
          
          return x
        else
          return nil
        end
      else
        return res
      end
    end
end
