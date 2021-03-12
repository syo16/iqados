OBJS_BOOTPACK = bootpack.o graphic.o dsctbl.o naskfunc.o hankaku.o mysprintf.o int.o fifo.o keyboard.o mouse.o memory.o sheet.o timer.o mtask.o myfunction.o window.o console.o file.o

IMG_REQUISITE = ipl10.bin haribote.sys hello.hrb hello2.hrb a.hrb hello3.hrb hello4.hrb hello5.hrb winhelo.hrb winhelo2.hrb winhelo3.hrb star1.hrb stars.hrb stars2.hrb lines.hrb bug1.hrb bug2.hrb bug3.hrb
IMG_COPY = haribote.sys ipl10.nas make.bat hello.hrb hello2.hrb a.hrb hello3.hrb hello4.hrb hello5.hrb winhelo.hrb winhelo2.hrb winhelo3.hrb star1.hrb stars.hrb stars2.hrb lines.hrb bug1.hrb bug2.hrb bug3.hrb

MAKE     = make -r
DEL      = rm -f

CC = i386-elf-gcc
CFLAGS = -m32 -fno-builtin
COPTION = -march=i486 -nostdlib
COSLD = -T hrb.ld
CAPPLD = -T app.ld

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則
#
# convHankakuTxt.c は標準ライブラリが必要なので、macOS標準のgccを使う
convHankakuTxt : convHankakuTxt.c
	gcc $< -o $@

hankaku.c : hankaku.txt convHankakuTxt
	./convHankakuTxt


ipl10.bin : ipl10.nas Makefile
	nasm $< -o $@ -l ipl10.lst

asmhead.bin : asmhead.nas Makefile
	nasm $< -o $@ -l asmhead.lst

naskfunc.o : naskfunc.nas Makefile          # naskfunc.nasのバイナリファイル作成
	nasm -g -f elf $< -o $@ -l naskfunc.lst

# https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
bootpack.hrb : $(OBJS_BOOTPACK) hrb.ld Makefile   # 自作のmysprintf.c の sprintfでは警告が出るので、-fno-builtinオプションを追加
	$(CC) $(CFLAGS) $(COPTION) -T hrb.ld -Xlinker -Map=bootpack.map -g $(OBJS_BOOTPACK) -o $@

hello.hrb : hello.nas Makefile
	nasm $< -o $@ -l hello.lst

hello2.hrb : hello2.nas Makefile
	nasm $< -o $@ -l hello2.lst

a.hrb : a.o a_nask.o app.ld Makefile
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g a.o a_nask.o -o $@

hello3.hrb : hello3.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g hello3.o a_nask.o -o $@

hello4.hrb : hello4.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g hello4.o a_nask.o -o $@

hello5.hrb : hello5.o app.ld
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g hello5.o -o $@

winhelo.hrb : winhelo.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g winhelo.o a_nask.o -o $@

winhelo2.hrb : winhelo2.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g winhelo2.o a_nask.o -o $@

winhelo3.hrb : winhelo3.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g winhelo3.o a_nask.o -o $@

star1.hrb : star1.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g star1.o a_nask.o -o $@

stars.hrb : stars.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g stars.o a_nask.o -o $@

stars2.hrb : stars2.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g stars2.o a_nask.o -o $@

lines.hrb : lines.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g lines.o a_nask.o -o $@

bug1.hrb : bug1.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g bug1.o a_nask.o -o $@

bug2.hrb : bug2.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g bug2.o a_nask.o -o $@

bug3.hrb : bug3.o a_nask.o app.ld 
	$(CC) $(CFLAGS) $(COPTION) $(CAPPLD) -g bug3.o a_nask.o -o $@

haribote.sys : asmhead.bin bootpack.hrb Makefile
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img : $(IMG_REQUISITE) Makefile
	mformat -f 1440 -C -B ipl10.bin -i haribote.img ::
	mcopy -i haribote.img $(IMG_COPY) ::

# 一般規則

%.o : %.c
	$(CC) $(CFLAGS) -c $*.c -o $*.o

%.o : %.nas
	nasm -g -f elf $*.nas -o $*.o -l $*.lst

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
