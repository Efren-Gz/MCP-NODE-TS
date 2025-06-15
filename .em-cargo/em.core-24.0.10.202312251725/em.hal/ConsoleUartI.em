package em.hal

interface ConsoleUartI 

    host function setBaudH(rate: uint32)
    
    function flush()
    function put(data: uint8)
    
end
