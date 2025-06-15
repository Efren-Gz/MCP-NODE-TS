package em.utils

import ListManagerI

#! This module implements ListManagerI.
#! It contains all the functions necessary to maintain a list of objects.

module BasicListManager: ListManagerI

private:

    # Representation of Element
    def opaque Element 
        next: Element& volatile
    end

    # Representation of List
    def opaque List 
        first: Element& volatile
        last: Element& volatile
    end
end

# Initially an Element is not a member of a List
def Element.init() 
    this.next = null
end

# Initially an Element is not a member of a List
def Element.initH() 
    this.next = null
end

def Element.isActive() 
    return <uarg_t> this.next
end

# Creates a head and tail pointer
def List.init() 
    this.first = this.last = <Element&> &this.first
end

# Creates a head and tail pointer
def List.initH() 
    this.first = this.last = <Element&> &this.first;
end

# The very first Element is pointed to by this.first and this.last.
# Subsequent Elements are added to the end of the list by setting the
# next pointer of the current last Element to the added Element then moving
# the last pointer.    
def List.add(elem)
    this.last.next = elem
    this.last = elem
    elem.next = <Element&> this
end

# Elements are removed from the front of the list by
# setting a pointer equal to the this.first pointer,
# then moving the this.first pointer to the next Element.
# If the pointer then points to the List then that was the last
# Element and reinitialize the list for adding Elements.
# Otherwise just remove the Element.    
def List.get() 
    auto elem = this.first
    this.last = <Element&>this if (this.first = elem.next) == <Element&>this
    elem.next = null
    return elem
end

def List.getAt(index)
    auto elem = this.first
    auto i = 0
    if this.hasElements()
        for ;;
            break if i++ == index                
            elem = elem.next                
            break if elem == <Element&> this
        end
        elem = null if elem == <Element&> this
    else 
        elem = null
    end
    return elem
end

# This function returns the Element after the given Element
# in the List, but does not remove it from the List.
def List.getNext(elem) 
    return elem == this.last ? null : elem.next
end

def List.hasElements() 
    return (<uarg_t> this.first) ^ <uarg_t> this
end

# This function prints the index and address of each Element in the List
def List.print() 
    auto elem = this.first
    auto i = 0
    if this.hasElements()
        for ;;
            printf "elem%d %p\n", i++, elem
            elem = elem.next
            break if elem == <Element&> this
        end
    else 
        printf "list empty\n"
    end
    printf "\n" 
end

# Performs a linear search through the list to find the Element
# then removes it, updating the appropriate pointers.
def List.remove(elem)
    auto e = this.first
    if this.hasElements()
        if elem == this.first
            this.first = this.first.next
        else 
            for ;; 
                if e.next == elem
                    e.next = elem.next                    
                    break    
                end 
                break if e == <Element&> this
            end
        end
    end
end
