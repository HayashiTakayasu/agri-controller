#require "serial"
#require "Win32API" #for windows.

module AgriController
  module_function
  ##
  #use Dacs_32bit_I/O_photoMOS_reray on usb_serial_port (win,linux compatible)
  #*Usage
  #  requrie "agri-controll"
  #  include AgriController
  #  include Dacs # also use Dacs::
  #
  #==Windows
  #export is a simple IO_command send(set),and recieve(import)
  #search com_port(3-19) and communicate
  #export("ffffff")# =>"R0FFFFFF&"
  #
  #com_port number recommended
  #com_port=6                   #(see system infomation)
  #  export("ffffff",com_port,0)#return =>"R0FFFFFF&"
  #  export("000000",com_port,0)#return =>"R0FFFFFF&"
  #  export("R",com_port,1)     #return =>"R883DFFF&"
  #  export("R",com_port)       #return =>"R0FFFFFF&"
  #
  #hex_6
  #ex.          # =>"FBD017","ffffff"
  #recieve only.# =>"R"
  #
  ############################################################
  #==Linux
  #  include dacs
  #  export("W0FFFFFF\r","ttyUsb0") 
  #  import("R0R\r")
  #
  module Dacs
    module_function

    if RUBY_PLATFORM.include?("mswin")
      def export(hex_6,com_port=port?,io_port=0,dip=0)
        #hex_6
        #ex.          # =>"FBD017","ffffff"
        #recieve only.# =>"R"

        case io_port
        #io_port must be io_port*8+dip_switch(on board)
        when 1
          io_port=8*io_port+dip#2nd word
        else#io_port should be 0
          io_port=dip#2nd word
        end
        a=Serial.new
          #search COM port 3-9
          if a.open(com_port,0,57600,8,0,0,4096,4096)!=-1
            command="W#{(io_port).to_s}#{hex_6}\r"
            
            yield command if block_given?
            #p command
            a.send(command)
            sleep 0.04
            receive=a.receive
            a.close
            return receive
          else
            return false
          end
        nil
      end
        
      ##
      #search ports COM3-19
      #if sucsess return int(port number)
      #else return nil.
      def port?(x=3)
        a=Serial.new
          #search COM port 3-19
          bool=false#serch flag
          
          while bool==false
            x+=1
            if x > 20
              return nil
            end

            if a.open(x,0,57600,8,0,0,108,324) == -1
              if x > 20
                return nil
              end
            else
              a.send("W0R\r")
              sleep 0.1
              receive=a.receive#should_be "R0xxxxxx\r",x=hex
              #p receive.split(//).last
              #p x
              #p receive
              if receive
                if receive.split(//).last=="\r"
                  if receive.split(//).first=="R"
                    bool=true
                  end
                end
              end
              a.close
            end
          end

        return x
      end
      
      def import(com_port=port?,io_port=0,dip=0)
        export("R",com_port,io_port,dip)
      end
      
      def import_bit(com_port=port?,io_port=0,dip=0)
        
        port_bit=import(com_port=port?,io_port,dip)
        if port_bit
          import_bits=port_bit.slice(2,6).to_i(16)
        else
          import_bits=0
        end
        return import_bits
      end
    else#should be Linux
      def export(command,device) 
      end
    end
    
    def toi(res)
      begin
        bit=res.slice(2,6).to_i(16)
        return bit
      rescue
        nil
      end
    end
    
    def sample
      "W0FFFFFF\r"
    end
  end
end

if $0==__FILE__
  include AgriController::Dacs
  p port?
p x=export("FFFFFF",5)
#p x.to_s(16)
end
