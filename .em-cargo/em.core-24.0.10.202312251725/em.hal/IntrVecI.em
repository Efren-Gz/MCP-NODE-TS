package em.hal

interface IntrVecI

    type ExceptionHandler: function(vecNum: uint32, retAddr: addr_t)

    host function bindExceptionHandlerH(handler: ExceptionHandler)

end
