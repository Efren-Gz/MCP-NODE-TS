package em.utils

module ListMgr

    type Element: opaque 
        
        function init()
        host function initH()
        
        function isActive(): uarg_t
    end
    
    type List: opaque 
        
        function init()
        host function initH()
        
        function add(elem: Element&)
        function get(): ref_t
        function getAt(index: uint8): ref_t
        function getNext(elem: Element&): ref_t
        function hasElements(): uarg_t
        function print()
        function remove(elem: Element&)
    end

private:

    def opaque Element 
        next: Element& volatile
    end

    def opaque List 
        first: Element& volatile
        last: Element& volatile
    end
end

def Element.init() 
    this.next = null
end

def Element.initH() 
    this.next = null
end

def Element.isActive() 
    return <uarg_t> this.next
end

def List.init() 
    this.first = this.last = <Element&> &this.first
end

def List.initH() 
    this.first = this.last = <Element&> &this.first;
end

def List.add(elem)
    this.last.next = elem
    this.last = elem
    elem.next = <Element&> this
end

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

def List.getNext(elem) 
    return elem == this.last ? null : elem.next
end

def List.hasElements() 
    return (<uarg_t> this.first) ^ <uarg_t> this
end

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
