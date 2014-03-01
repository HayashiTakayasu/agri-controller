require "time"
module AgriController
  module_function
  def dt(t1=Time.now,t2=nil)
    begin
      unless t2
        yield if block_given?
        return Time.now-t1
      else
        return t2-t1
      end
    rescue
      return nil
    end
  end
end

