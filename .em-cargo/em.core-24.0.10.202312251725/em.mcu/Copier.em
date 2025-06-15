package em.mcu

from em.hal import CopierI

module Copier: CopierI

    proxy Impl: CopierI

end

def exec(dst, src, cnt)
    Impl.exec(dst, src, cnt)
end
