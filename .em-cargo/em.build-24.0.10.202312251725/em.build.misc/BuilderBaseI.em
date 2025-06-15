package em.build.misc

from em.lang import BuilderI

host interface BuilderBaseI: BuilderI

    config arch: string
    config cpu: string
    config mcu: string

end
