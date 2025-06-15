package em.build.clang.arm

host module Target

    template genMake()

end

def genMake()
    var cincs: string[] = ^^em$props.get('em.build.CompileIncludes').split(';').concat(em$paths)^^
    var copts: string[] = ^^em$props.get('em.build.CompileOptions').split(';')^^
    var echo: string = ^^em$props.get('em.build.CommandEcho') == 'true' ? '' : '@'^^ 
    var cpu: string = ^^em$props.get('em.build.Cpu')^^
    var gdir: string = ^^em$props.get('em.build.GitBashDir')^^
    var tdir: string = ^^em$props.get('em.build.CompilerDir')^^
|->>>
BIN = `gdir`/usr/bin
TOOLS = `tdir`

CC = $(TOOLS)/bin/armclang
LD = $(TOOLS)/bin/armlink


DIR = .

CFLAGS = \\
    -mthumb \\
    -mcpu=cortex-m0plus \\
    -w \\
    -ffunction-sections \\
    -fdata-sections \\
    -fomit-frame-pointer \\
    -fno-exceptions \\
    -nostdlib \\
    --target=arm-arm-none-eabi \

|-<<<
    |->CINCS = \\
    for p in cincs
        p = ^^p.trim()^^
        continue if !p
    |->    -I`p` \\
    end
    |->
    |->COPTS = \\
    for o in copts
        o = ^^o.trim()^^
        continue if !o
    |->    `o` \\
    end
    |->
|->>>
LFLAGS = \\
    --datacompressor=off \\
    --entry=__em_program_start \\
    --info=sizes,totals \\
    --no_merge \\
    --no_merge_litpools \
    --scatter=linkcmd_clang.ld \\

clean:
	@$(BIN)/rm -f $(DIR)/*.{hex,lst,map,obj,out}

main.out:
	@echo building main.out ...
	`echo`$(CC) -c $(CFLAGS) $(CINCS) $(COPTS) -o $(DIR)/main.obj $(DIR)/main.cpp
	`echo`$(LD) $(LFLAGS) --map --list=main.map -o $(DIR)/main.out $(DIR)/main.obj
	`echo`$(TOOLS)/bin/fromelf --i32 --output=main.out.hex main.out
|-<<<
end
