.PHONY: default all clean

default: all
all: \
  trace_fail.opt trace_ok.opt trace_inline_ok.opt trace_inline_fail.opt \
  trace_mixup.opt trace_lwt_ok.opt trace_lwt_fail.opt trace_lwt_wrap.opt

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

# Misuse of reraise leading to wrong (or incomplete) trace
trace_mixup.opt: trace_mixup.ml
	ocamlopt -o trace_mixup.opt -g trace_mixup.ml
	./$@ > $@.out

# Decent trace achieved with Lwt.backtrace_bind and reraise
trace_lwt_ok.opt: trace_lwt_ok.ml
	ocamlfind ocamlopt -o trace_lwt_ok.opt \
	  -g -inline 0 -package lwt.unix -linkpkg \
	  trace_lwt_ok.ml
	./$@ > $@.out

# Missing trace despite using Lwt.backtrace_bind
trace_lwt_fail.opt: trace_lwt_fail.ml
	ocamlfind ocamlopt -o trace_lwt_fail.opt \
	  -g -inline 0 -package lwt.unix -linkpkg \
	  trace_lwt_fail.ml
	./$@ > $@.out

# Missing trace despite using Lwt.backtrace_bind
trace_lwt_wrap.opt: trace_lwt_wrap.ml
	ocamlfind ocamlopt -o trace_lwt_wrap.opt \
	  -g -package lwt.unix -linkpkg \
	  trace_lwt_wrap.ml
	./$@ > $@.out

clean:
	rm -f *.[oa] *.cm[ioxa] *.cmx[as] *.out *.opt *.run *~
