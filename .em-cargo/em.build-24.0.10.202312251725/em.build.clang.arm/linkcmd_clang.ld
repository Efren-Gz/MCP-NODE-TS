IMAGE 0x00000000 {

    FLASH 0x00000000 0x5000 {
        *.obj (.intvec, +FIRST)
        .ANY (+RO)
    }
  
    SRAM 0x20000008 0x07EF  {
        .ANY (+RW +ZI)
    }
}
