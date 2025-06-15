package em.hal

interface SpiMasterI

    function activate()
    function deactivate()
    function flush()
    function get(): uint8
    function put(data: uint8)
    
end
