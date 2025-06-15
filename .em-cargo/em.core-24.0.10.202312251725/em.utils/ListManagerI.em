package em.utils

#! Implemented by a List Manager module
#! Element and List declarations.

interface ListManagerI 

    type Element: opaque 
        
        #! Target and Host function to initialize an Element
        function init()
        host function initH()
        
        #! Returns non-null if the Element is currently a member of a List
        function isActive(): uarg_t
    end
    
    type List: opaque 
        
        #! Target and Host function to initialize a List
        function init()
        host function initH()
        
        #! Adds an element to the List as defined by the List Manager
        function add(elem: Element&)
        
        #! Returns a reference to an Element and removes it from the List
        function get(): ref_t
        
        #! Returns a reference to the Element at the specified index
        function getAt(index: uint8): ref_t
        
        #! Returns a reference to the next Element from the specified Element
        function getNext(elem: Element&): ref_t
        
        #! Returns a non-zero value if the List is not empty
        function hasElements(): uarg_t
        
        #! Displays information about the List
        function print()
        
        #! Removes the specified Element from the List
        function remove(elem: Element&)
    end
end