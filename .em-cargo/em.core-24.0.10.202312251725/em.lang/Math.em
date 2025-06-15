package em.lang

#! This module is only available for use on the host.
#! It contains some standard math functions.

host module Math

    config PI: num_t

    #! Returns the absolute value of x
    function abs(x: num_t): num_t
    
    #! Returns the smallest integer greater than or equal to x
    function ceil(x: num_t): num_t

    #! Returns the cos of x
    function cos(x: num_t): num_t
    
    #! Returns the largest integer less than or equal to x
    function floor(x: num_t): num_t
    
    #! Returns the logarithm (base 10) of x
    function log2(x: num_t): num_t
    
    #! Returns the logarithm (base 10) of x
    function log10(x: num_t): num_t
    
    #! Returns the value of x to the y power
    function pow(x: num_t, y: num_t): num_t
    
    #! Returns the rounded value of x
    function round(x: num_t): num_t

    #! Returns the sin of x
    function sin(x: num_t): num_t

end

def em$configure()
    PI ?= ^^global.Math.PI^^
end

def abs(x)
    return ^^global.Math.abs(x)^^
end

# If x = 19.1 this function will return 20
def ceil(x)
    return ^^global.Math.ceil(x)^^
end

def cos(x)
    return ^^global.Math.cos(x)^^
end

# If x = 19.6 this function will return 19
def floor(x)
    return ^^global.Math.floor(x)^^
end

def log2(x)
    return ^^global.Math.log2(x)^^
end

def log10(x)
    return ^^global.Math.LOG10E * global.Math.log(x)^^
end

def pow(x, y)
    return ^^global.Math.pow(x, y)^^
end

def round(x)
    return ^^global.Math.round(x)^^
end

def sin(x)
    return ^^global.Math.sin(x)^^
end