SHELL := bash

all: \
	test-euler1 \
	test-euler23 \
	test-hello

.PHONY: test-%
test-%: bin/%
		./$< | tee >(sha1sum | diff -u $(notdir $<).txt -)

.PRECIOUS: bin/%
bin/%: obj/%.o
		mkdir -p bin
		ld -o $@ -macosx_version_min 10.13 $< -lc

.PRECIOUS: obj/%.o
obj/%.o: asm/%.s
		mkdir -p obj
		as -o $@ $<

.PRECIOUS: asm/%.s
asm/%.s: ir/%.bc
		mkdir -p asm
		llc -o $@ $<

.PRECIOUS: ir/%.bc
ir/%.bc: %.ll
		mkdir -p ir
		opt -O3 -lint $< >$@
