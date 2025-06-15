package em.utils

template LedT 
    
end

def em$generateUnit(pn, un)
|->>>
	package `pn`
	
	from em.hal import LedI
	from em.hal import GpioI

    from em.mcu import Poller
	
	module `un`: LedI
	    proxy Pin: GpioI
	    config activeLow: bool = false
	end
	
	def em$startup()
	    Pin.makeOutput()
	    if activeLow
	        Pin.set()            
	    else 
	        Pin.clear()                
	    end
	end
	
	def on()
	    if activeLow
	        Pin.clear()            
	    else 
	        Pin.set()                
	    end   
	end
	
	def off()
	    if activeLow
	        Pin.set()            
	    else 
	        Pin.clear()                
	    end   
	end
	
	def toggle()
	    Pin.toggle()
	end
	
	def isOn()
	    return activeLow ? !Pin.get() : Pin.get()
	end

    def wink(msecs)
        on()
        Poller.pause(msecs)
        off()
    end          
|-<<<
end