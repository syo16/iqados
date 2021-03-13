OBJS_BOOTPACK = bootpack.o graphic.o dsctbl.o naskfunc.o hankaku.o mysprintf.o int.o fifo.o keyboard.o mouse.o memory.o sheet.o timer.o mtask.o myfunction.o window.o console.o file.o

#OBJS_API = a_nask.o
OBJS_API = api001.o api002.o api003.o api004.o api005.o api006.o api007.o api008.o api009.o api010.o api011.o api012.o api013.o api014.o api015.o api016.o api017.o api018.o api019.o api020.o

IMG_REQUISITE = ipl10.bin haribote.sys a.hrb hello3.hrb hello4.hrb hello5.hrb winhelo.hrb winhelo2.hrb winhelo3.hrb star1.hrb stars.hrb stars2.hrb lines.hrb walk.hrb noodle.hrb beepdown.hrb color.hrb color2.hrb
IMG_COPY = haribote.sys ipl10.nas make.bat a.hrb hello3.hrb hello4.hrb hello5.hrb winhelo.hrb winhelo2.hrb winhelo3.hrb star1.hrb stars.hrb stars2.hrb lines.hrb walk.hrb noodle.hrb beepdown.hrb color.hrb color2.hrb

MAKE     = make -r
DEL      = rm -f

CC = i386-elf-gcc
CFLAGS = -m32 -fno-builtin
COPTION = -march=i486 -nostdlib
COSLD = -T hrb.ld
CAPPLD = -T app.ld
CAPPLD2 = -T app2.ld
CC_WITH_OPTION = i386-elf-gcc -m32 -march=i486 -nostdlib

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則
ipl10.bin : ipl10.nas Makefile
	nasm $< -o $@ -l ipl10.lst

asmhead.bin : asmhead.nas Makefile
	nasm $< -o $@ -l asmhead.lst

# convHankakuTxt.c は標準ライブラリが必要なので、macOS標準のgccを使う
convHankakuTxt : convHankakuTxt.c
	gcc $< -o $@

hankaku.c : hankaku.txt convHankakuTxt
	./convHankakuTxt

# https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
bootpack.hrb : $(OBJS_BOOTPACK) hrb.ld Makefile   # 自作のmysprintf.c の sprintfでは警告が出るので、-fno-builtinオプションを追加
	$(CC) $(CFLAGS) $(COPTION) -T hrb.ld -Xlinker -Map=bootpack.map -g $(OBJS_BOOTPACK) -o $@

haribote.sys : asmhead.bin bootpack.hrb Makefile
	cat asmhead.bin bootpack.hrb > haribote.sys

libapi.a : $(OBJS_API)
	i386-elf-ar rcs $@ $^

hello5.hrb : hello5.o app.ld
	$(CC_WITH_OPTION) $(CAPPLD) -o $@ $<

noodle.hrb : noodle.o mysprintf.o libapi.a app2.ld 
	$(CC_WITH_OPTION) $(CAPPLD2) -o $@ $< mysprintf.o libapi.a

haribote.img : $(IMG_REQUISITE) Makefile
	mformat -f 1440 -C -B ipl10.bin -i haribote.img ::
	mcopy -i haribote.img $(IMG_COPY) ::

# 一般規則

%.o : %.c
	$(CC) $(CFLAGS) -c $*.c -o $*.o

%.o : %.nas
	nasm -g -f elf $*.nas -o $*.o -l $*.lst

%.hrb : %.o libapi.a app.ld
	$(CC_WITH_OPTION) $(CAPPLD) -o $@ $< libapi.a

# コマンド

img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	qemu-system-i386 -drive file=haribote.img,format=raw,if=floppy -boot a

clean :
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.o
	-$(DEL) *.sys
	-$(DEL) *.hrb
	-$(DEL) *.map
	-$(DEL) hankaku.c
	-$(DEL) convHankakuTxt

src_only :
	$(MAKE) clean
	-$(DEL) haribote.img
