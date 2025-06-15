package em.utils

from em.hal import CopierI

module Copier: CopierI

end

def exec(dst, src, cnt)
    ^memcpy(dst, src, cnt)
end
