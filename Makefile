all: \
	test-euler1 \
	test-hello

.PHONY: test-%
test-%: bin/%
		./$< | diff -u $(notdir $<).txt -

.PRECIOUS: bin/%
bin/%: obj/%.o
		mkdir -p bin
		ld -o $@ -macosx_version_min 10.13 $< -lc

.PRECIOUS: obj/%.o
obj/%.o: asm/%.s
		mkdir -p obj
		as -o $@ $<

.PRECIOUS: asm/%.s
asm/%.s: %.ll
		mkdir -p asm
		llc -o $@ $<
