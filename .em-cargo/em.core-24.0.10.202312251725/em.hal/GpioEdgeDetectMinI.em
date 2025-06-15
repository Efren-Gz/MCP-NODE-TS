package em.hal

import GpioI

interface GpioEdgeDetectMinI: GpioI 
        #   ^| extends the GpioI abstraction with edge-detection features
    type Handler: function ()
        #   ^| signature of an edge-detection function
    host function setDetectHandlerH(h: Handler)
        #   ^| bind a handler to this GPIO at build-time
    function clearDetect()
        #   ^| clear (acknowledge) any edge-detection by this GPIO
    function disableDetect()   
        #   ^| disable edge-detection by this GPIO
    function enableDetect()
        #   ^| enable edge-detection by this GPIO
    function setDetectFallingEdge()
        #   ^| detect high-to-low transitions by this GPIO
    function setDetectRisingEdge()
        #   ^| detect low-to-high transitions by this GPIO
end
