OBJS_API = api001.o api002.o api003.o api004.o api005.o api006.o api007.o api008.o api009.o api010.o api011.o api012.o api013.o api014.o api015.o api016.o api017.o api018.o api019.o api020.o

MAKE = make -r
DEL = rm -f

default :
	$(MAKE) libapi.a

libapi.a : $(OBJS_API)
	i386-elf-ar rcs $@ $^

%.o : %.nas
	nasm -g -f elf $*.nas -o $*.o

clean :
	-$(DEL) *.lst
	-$(DEL) *.o

src_only:
	$(MAKE) clean
	-$(DEL) libapi.a
