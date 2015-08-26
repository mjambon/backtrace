.PHONY: default all clean

default: all
all: trace_fail.opt trace_ok.opt trace_inline_ok.opt trace_inline_fail.opt

# Missing call point despite -inline 0
trace_fail.opt: trace_fail.ml
	ocamlopt -o trace_fail.opt -g -inline 0 trace_fail.ml
	./$@ > $@.out

# Complete trace with or without -inline 0
trace_ok.opt: trace_ok.ml
	ocamlopt -o trace_ok.opt -g trace_ok.ml
	./$@ > $@.out

# Complete trace only with -inline 0
trace_inline_ok.opt: trace_inline.ml
	ocamlopt -o trace_inline_ok.opt -g -inline 0 trace_inline.ml
	./$@ > $@.out

# Incomplete trace when not using -inline 0
trace_inline_fail.opt: trace_inline.ml
	ocamlopt -o trace_inline_fail.opt -g trace_inline.ml
	./$@ > $@.out

clean:
	rm -f *.[oa] *.cm[ioxa] *.cmx[as] *.out *.opt *.run *~