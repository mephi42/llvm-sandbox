all: test-hello

.PHONY: test-%
test-%: bin/%
		./$< | diff -u $(notdir $<).txt -

.PRECIOUS: bin/%
bin/%: obj/%.o
		mkdir -p bin
		ld -o $@ -macosx_version_min 10.13 $< -lc

.PRECIOUS: obj/%.o
obj/%.o: %.ll
		mkdir -p obj
		llc -o $@ -filetype=obj $<
