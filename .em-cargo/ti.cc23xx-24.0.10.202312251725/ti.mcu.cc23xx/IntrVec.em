package ti.mcu.cc23xx

from em.hal import IntrVecI

module IntrVec: IntrVecI

    host function addIntrH(name: string)

private:

    const HARD_FAULT: uint32 = 3

    type IsrFxn: function()

    host config nameTab: string[] = [
        "NMI",
        "HardFault",
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        "SVC",
        null,
        null,
        "PendSV",
        "SysTick",
        "CPUIRQ0",
        "CPUIRQ1",
        "CPUIRQ2",
        "CPUIRQ3",
        "CPUIRQ4",
        "GPIO_COMB",     
        "LRFD_IRQ0",     
        "LRFD_IRQ1",     
        "DMA_DONE_COMB",     
        "AES_COMB",      
        "SPI0_COMB",     
        "UART0_COMB",    
        "I2C0_IRQ",     
        "LGPT0_COMB",    
        "LGPT1_COMB",    
        "ADC0_COMB",     
        "CPUIRQ16", 
        "LGPT2_COMB",    
        "LGPT3_COMB",
    ]

    host config usedTab: string[]

    config excHandler: ExceptionHandler

    function nullIsr()

end

def em$generateCode(prefix)
|->>>
typedef void( *intfunc )( void );
typedef union { intfunc fxn; void* ptr; } intvec_elem;

|-<<<
    for n in nameTab
        continue if n == null
        |-> extern void `n`_Handler( void );
        |-> #define `n`_ISR `prefix`::nullIsr
    end    
|->>>

|-<<<
    for u in usedTab
        |-> #undef `u`_ISR
        |-> #define `u`_ISR `u`_Handler
    end    
|->>>

extern em_uint32 __stack_top__;
extern "C" void __em_program_start( void );
extern "C" const intvec_elem  __attribute__((section(".intvec"))) __vector_table[] = {
    { .ptr = (void*)&__stack_top__ },
    { .fxn = __em_program_start },
|-<<<
    for n in nameTab
        if n == null
            |->     0,
        else
            |->     { .fxn = `n`_ISR },
        end
    end    
    |-> };
|->>>

|-<<<
end

def em$startup()
    ^^SCB->VTOR = (uint32_t)(&__vector_table)^^
end

def addIntrH(name)
    usedTab[usedTab.length++] = name
end

def bindExceptionHandlerH(handler)
    excHandler = handler
end

def nullIsr()
    auto vecNum = <uint32>(^^__get_IPSR()^^)
    %%[b:4]
    %%[><uint8>vecNum]
    auto frame = <uint32[]>(^^__get_MSP()^^)
    %%[><uint32>&frame[0]]
    for auto i = 0; i < 8; i++
        %%[b]
        %%[>frame[i]]
    end
    fail
end
