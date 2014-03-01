module AgriController
module_function
  ##
  #++ watching ttyUSB* allow
  #
  # AgriController::ttyUSB_watchdog()  # =>`chmod 777 /dev/ttyUSB*`
  def ttyUSB_watchdog
    ##
    #watching ttyUSB* allow
    str=`ls -l /dev/ttyUSB*`
    print str if $DEBUG

    flag=false
    str.each_line do |line|
      if line.include?("crwxrwxrwx")
        #OK. Nothing to do
      else
        #puts line
        #puts "ttyUSB ERROR"
        flag=true
      end
    end
    
    #/dev/ttyUSB* allow again
    `sudo chmod 777 /dev/ttyUSB*` if flag
  end
  #++ ttyUSB_watchdog_loop(sec=30)
  #   run each 30 seconds(default)
  #   AgriController::ttyUSB_watchdog
  def ttyUSB_watchdog_loop(sec=30)
    loop do
      print "." if $DEBUG
      ttyUSB_watchdog
      sleep sec
    end
  end
end

if $0==__FILE__
  include AgriController
  ttyUSB_watchdog_loop(30)
end

