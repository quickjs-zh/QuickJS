#
# QuickJS Javascript Engine
# 
# Copyright (c) 2017-2019 Fabrice Bellard
# Copyright (c) 2017-2019 Charlie Gordon
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

ifeq ($(shell uname -s),Darwin)
CONFIG_DARWIN=y
endif
# Windows cross compilation from Linux
#CONFIG_WIN32=y
# use link time optimization (smaller and faster executables but slower build)
CONFIG_LTO=y
# consider warnings as errors (for development)
#CONFIG_WERROR=y
# force 32 bit build for some utilities
#CONFIG_M32=y

ifdef CONFIG_DARWIN
# use clang instead of gcc
CONFIG_CLANG=y
CONFIG_DEFAULT_AR=y
endif

# installation directory
prefix=/usr/local

# use the gprof profiler
#CONFIG_PROFILE=y
# use address sanitizer
#CONFIG_ASAN=y

OBJDIR=.obj

ifdef CONFIG_WIN32
  CROSS_PREFIX=i686-w64-mingw32-
  EXE=.exe
else
  CROSS_PREFIX=
  EXE=
endif
ifdef CONFIG_CLANG
  HOST_CC=clang
  CC=$(CROSS_PREFIX)clang
  CFLAGS=-g -Wall -MMD -MF $(OBJDIR)/$(@F).d
  CFLAGS += -Wextra
  CFLAGS += -Wno-sign-compare
  CFLAGS += -Wno-missing-field-initializers
  CFLAGS += -Wundef -Wuninitialized
  CFLAGS += -Wunused -Wno-unused-parameter
  CFLAGS += -Wwrite-strings
  CFLAGS += -Wchar-subscripts -funsigned-char
  CFLAGS += -MMD -MF $(OBJDIR)/$(@F).d
  ifdef CONFIG_DEFAULT_AR
    AR=$(CROSS_PREFIX)ar
  else
    ifdef CONFIG_LTO
      AR=$(CROSS_PREFIX)llvm-ar
    else
      AR=$(CROSS_PREFIX)ar
    endif
  endif
else
  HOST_CC=gcc
  CC=$(CROSS_PREFIX)gcc
  CFLAGS=-g -Wall -MMD -MF $(OBJDIR)/$(@F).d
  CFLAGS += -Wno-array-bounds -Wno-format-truncation
  ifdef CONFIG_LTO
    AR=$(CROSS_PREFIX)gcc-ar
  else
    AR=$(CROSS_PREFIX)ar
  endif
endif
STRIP=$(CROSS_PREFIX)strip
ifdef CONFIG_WERROR
CFLAGS+=-Werror
endif
DEFINES:=-D_GNU_SOURCE -DCONFIG_VERSION=\"$(shell cat VERSION)\"
CFLAGS+=$(DEFINES)
CFLAGS_DEBUG=$(CFLAGS) -O0
CFLAGS_SMALL=$(CFLAGS) -Os
CFLAGS_OPT=$(CFLAGS) -O2
CFLAGS_NOLTO:=$(CFLAGS_OPT)
LDFLAGS=-g
ifdef CONFIG_LTO
CFLAGS_SMALL+=-flto
CFLAGS_OPT+=-flto
LDFLAGS+=-flto
endif
ifdef CONFIG_PROFILE
CFLAGS+=-p
LDFLAGS+=-p
endif
ifdef CONFIG_ASAN
CFLAGS+=-fsanitize=address
LDFLAGS+=-fsanitize=address
endif
ifdef CONFIG_WIN32
LDEXPORT=
else
LDEXPORT=-rdynamic
endif

PROGS=qjs$(EXE) qjsbn$(EXE) qjsc$(EXE) qjsbnc$(EXE) run-test262 run-test262-bn
ifneq ($(CROSS_PREFIX),)
QJSC_CC=gcc
QJSC=./host-qjsc
QJSBNC=./host-qjsbnc
PROGS+=$(QJSC) $(QJSBNC)
else
QJSC_CC=$(CC)
QJSC=./qjsc$(EXE)
QJSBNC=./qjsbnc$(EXE)
endif
ifndef CONFIG_WIN32
PROGS+=qjscalc
endif
ifdef CONFIG_M32
PROGS+=qjs32 qjs32_s qjsbn32
endif
PROGS+=libquickjs.a libquickjs.bn.a
ifdef CONFIG_LTO
PROGS+=libquickjs.lto.a libquickjs.bn.lto.a
endif

# examples
ifeq ($(CROSS_PREFIX),)
ifdef CONFIG_ASAN
PROGS+=
else
PROGS+=examples/hello examples/hello_module examples/test_fib
ifndef CONFIG_DARWIN
PROGS+=examples/fib.so examples/point.so
endif
endif
endif

all: $(OBJDIR) $(OBJDIR)/quickjs.check.o $(OBJDIR)/qjs.check.o $(PROGS)

QJS_LIB_OBJS=$(OBJDIR)/quickjs.o $(OBJDIR)/libregexp.o $(OBJDIR)/libunicode.o $(OBJDIR)/cutils.o $(OBJDIR)/quickjs-libc.o

QJSBN_LIB_OBJS=$(patsubst %.o, %.bn.o, $(QJS_LIB_OBJS)) $(OBJDIR)/libbf.bn.o

QJS_OBJS=$(OBJDIR)/qjs.o $(OBJDIR)/repl.o $(QJS_LIB_OBJS)

QJSBN_OBJS=$(OBJDIR)/qjs.bn.o $(OBJDIR)/repl-bn.bn.o $(OBJDIR)/qjscalc.bn.o $(QJSBN_LIB_OBJS)

LIBS=-lm
ifndef CONFIG_WIN32
LIBS+=-ldl
endif

$(OBJDIR):
	mkdir -p $(OBJDIR) $(OBJDIR)/examples $(OBJDIR)/tests

qjs$(EXE): $(QJS_OBJS)
	$(CC) $(LDFLAGS) $(LDEXPORT) -o $@ $^ $(LIBS)

qjs-debug$(EXE): $(patsubst %.o, %.debug.o, $(QJS_OBJS))
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

qjsc$(EXE): $(OBJDIR)/qjsc.o $(QJS_LIB_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

qjsbnc$(EXE): $(OBJDIR)/qjsc.bn.o $(QJSBN_LIB_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

ifneq ($(CROSS_PREFIX),)

$(QJSC): $(OBJDIR)/qjsc.host.o \
    $(patsubst %.o, %.host.o, $(QJS_LIB_OBJS))
	$(HOST_CC) $(LDFLAGS) -o $@ $^ $(LIBS)

$(QJSBNC): $(OBJDIR)/qjsc.bn.host.o \
    $(patsubst %.o, %.host.o, $(QJSBN_LIB_OBJS))
	$(HOST_CC) $(LDFLAGS) -o $@ $^ $(LIBS)

endif #CROSS_PREFIX

QJSC_DEFINES:=-DCONFIG_CC=\"$(QJSC_CC)\" -DCONFIG_PREFIX=\"$(prefix)\"
ifdef CONFIG_LTO
QJSC_DEFINES+=-DCONFIG_LTO
endif
QJSC_HOST_DEFINES:=-DCONFIG_CC=\"$(HOST_CC)\" -DCONFIG_PREFIX=\"$(prefix)\"

$(OBJDIR)/qjsc.o $(OBJDIR)/qjsc.bn.o: CFLAGS+=$(QJSC_DEFINES)
$(OBJDIR)/qjsc.host.o $(OBJDIR)/qjsc.bn.host.o: CFLAGS+=$(QJSC_HOST_DEFINES)

qjs32: $(patsubst %.o, %.m32.o, $(QJS_OBJS))
	$(CC) -m32 $(LDFLAGS) $(LDEXPORT) -o $@ $^ $(LIBS)

qjs32_s: $(patsubst %.o, %.m32s.o, $(QJS_OBJS))
	$(CC) -m32 $(LDFLAGS) -o $@ $^ $(LIBS)
	@size $@

qjsbn$(EXE): $(QJSBN_OBJS)
	$(CC) $(LDFLAGS) $(LDEXPORT) -o $@ $^ $(LIBS)

qjsbn32: $(patsubst %.o, %.m32.o, $(QJSBN_OBJS))
	$(CC) -m32 $(LDFLAGS) $(LDEXPORT) -o $@ $^ $(LIBS)

qjscalc: qjsbn
	ln -sf $< $@

qjsbn-debug$(EXE): $(patsubst %.o, %.debug.o, $(QJSBN_OBJS))
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

ifdef CONFIG_LTO
LTOEXT=.lto
else
LTOEXT=
endif

libquickjs$(LTOEXT).a: $(QJS_LIB_OBJS)
	$(AR) rcs $@ $^

libquickjs.bn$(LTOEXT).a: $(QJSBN_LIB_OBJS)
	$(AR) rcs $@ $^

ifdef CONFIG_LTO
libquickjs.a: $(patsubst %.o, %.nolto.o, $(QJS_LIB_OBJS))
	$(AR) rcs $@ $^

libquickjs.bn.a: $(patsubst %.o, %.nolto.o, $(QJSBN_LIB_OBJS))
	$(AR) rcs $@ $^
endif # CONFIG_LTO

repl.c: $(QJSC) repl.js 
	$(QJSC) -c -o $@ -m repl.js

repl-bn.c: $(QJSBNC) repl.js 
	$(QJSBNC) -c -o $@ -m repl.js

qjscalc.c: $(QJSBNC) qjscalc.js
	$(QJSBNC) -c -o $@ qjscalc.js

ifneq ($(wildcard unicode/UnicodeData.txt),)
$(OBJDIR)/libunicode.o $(OBJDIR)/libunicode.m32.o $(OBJDIR)/libunicode.m32s.o $(OBJDIR)/libunicode.bn.o $(OBJDIR)/libunicode.bn.m32.o \
    $(OBJDIR)/libunicode.nolto.o $(OBJDIR)/libunicode.bn.nolto.o: libunicode-table.h

libunicode-table.h: unicode_gen
	./unicode_gen unicode $@
endif

run-test262: $(OBJDIR)/run-test262.o $(QJS_LIB_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS) -lpthread

run-test262-bn: $(OBJDIR)/run-test262.bn.o $(QJSBN_LIB_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS) -lpthread

run-test262-debug: $(patsubst %.o, %.debug.o, $(OBJDIR)/run-test262.o $(QJS_LIB_OBJS))
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS) -lpthread

run-test262-32: $(patsubst %.o, %.m32.o, $(OBJDIR)/run-test262.o $(QJS_LIB_OBJS))
	$(CC) -m32 $(LDFLAGS) -o $@ $^ $(LIBS) -lpthread

run-test262-bn32: $(patsubst %.o, %.m32.o, $(OBJDIR)/run-test262.bn.o $(QJSBN_LIB_OBJS))
	$(CC) -m32 $(LDFLAGS) -o $@ $^ $(LIBS) -lpthread

# object suffix order: bn, nolto, [m32|m32s]

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_OPT) -c -o $@ $<

$(OBJDIR)/%.host.o: %.c | $(OBJDIR)
	$(HOST_CC) $(CFLAGS_OPT) -c -o $@ $<

$(OBJDIR)/%.pic.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_OPT) -fPIC -DJS_SHARED_LIBRARY -c -o $@ $<

$(OBJDIR)/%.bn.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_OPT) -DCONFIG_BIGNUM -c -o $@ $<

$(OBJDIR)/%.bn.host.o: %.c | $(OBJDIR)
	$(HOST_CC) $(CFLAGS_OPT) -DCONFIG_BIGNUM -c -o $@ $<

$(OBJDIR)/%.nolto.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_NOLTO) -c -o $@ $<

$(OBJDIR)/%.bn.nolto.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_NOLTO) -DCONFIG_BIGNUM -c -o $@ $<

$(OBJDIR)/%.m32.o: %.c | $(OBJDIR)
	$(CC) -m32 $(CFLAGS_OPT) -c -o $@ $<

$(OBJDIR)/%.m32s.o: %.c | $(OBJDIR)
	$(CC) -m32 $(CFLAGS_SMALL) -c -o $@ $<

$(OBJDIR)/%.bn.m32.o: %.c | $(OBJDIR)
	$(CC) -m32 $(CFLAGS_OPT) -DCONFIG_BIGNUM -c -o $@ $<

$(OBJDIR)/%.debug.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_DEBUG) -c -o $@ $<

$(OBJDIR)/%.bn.debug.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS_DEBUG) -DCONFIG_BIGNUM -c -o $@ $<

$(OBJDIR)/%.check.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS) -DCONFIG_CHECK_JSVALUE -c -o $@ $<

regexp_test: libregexp.c libunicode.c cutils.c
	$(CC) $(LDFLAGS) $(CFLAGS) -DTEST -o $@ libregexp.c libunicode.c cutils.c $(LIBS)

jscompress: jscompress.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ jscompress.c

unicode_gen: $(OBJDIR)/unicode_gen.host.o $(OBJDIR)/cutils.host.o libunicode.c unicode_gen_def.h
	$(HOST_CC) $(LDFLAGS) $(CFLAGS) -o $@ $(OBJDIR)/unicode_gen.host.o $(OBJDIR)/cutils.host.o

clean:
	rm -f repl.c repl-bn.c qjscalc.c out.c
	rm -f *.a *.o *.d *~ jscompress unicode_gen regexp_test $(PROGS)
	rm -f hello.c hello_module.c test_fib.c
	rm -f examples/*.so tests/*.so
	rm -rf $(OBJDIR)/ *.dSYM/ qjs-debug qjsbn-debug
	rm -rf run-test262-debug run-test262-32 run-test262-bn32

install: all
	mkdir -p "$(DESTDIR)$(prefix)/bin"
	$(STRIP) qjs qjsbn qjsc qjsbnc
	install -m755 qjs qjsbn qjsc qjsbnc "$(DESTDIR)$(prefix)/bin"
	ln -sf qjsbn "$(DESTDIR)$(prefix)/bin/qjscalc"
	mkdir -p "$(DESTDIR)$(prefix)/lib/quickjs"
	install -m644 libquickjs.a libquickjs.bn.a "$(DESTDIR)$(prefix)/lib/quickjs"
ifdef CONFIG_LTO
	install -m644 libquickjs.lto.a libquickjs.bn.lto.a "$(DESTDIR)$(prefix)/lib/quickjs"
endif
	mkdir -p "$(DESTDIR)$(prefix)/include/quickjs"
	install -m644 quickjs.h quickjs-libc.h "$(DESTDIR)$(prefix)/include/quickjs"

###############################################################################
# examples

# example of static JS compilation
HELLO_SRCS=examples/hello.js
HELLO_OPTS=-fno-string-normalize -fno-map -fno-promise -fno-typedarray \
           -fno-typedarray -fno-regexp -fno-json -fno-eval -fno-proxy \
           -fno-date -fno-module-loader

hello.c: $(QJSC) $(HELLO_SRCS)
	$(QJSC) -e $(HELLO_OPTS) -o $@ $(HELLO_SRCS)

ifdef CONFIG_M32
examples/hello: $(OBJDIR)/hello.m32s.o $(patsubst %.o, %.m32s.o, $(QJS_LIB_OBJS))
	$(CC) -m32 $(LDFLAGS) -o $@ $^ $(LIBS)
else
examples/hello: $(OBJDIR)/hello.o $(QJS_LIB_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)
endif

# example of static JS compilation with modules
HELLO_MODULE_SRCS=examples/hello_module.js
HELLO_MODULE_OPTS=-fno-string-normalize -fno-map -fno-promise -fno-typedarray \
           -fno-typedarray -fno-regexp -fno-json -fno-eval -fno-proxy \
           -fno-date -m
examples/hello_module: $(QJSC) libquickjs$(LTOEXT).a $(HELLO_MODULE_SRCS)
	$(QJSC) $(HELLO_MODULE_OPTS) -o $@ $(HELLO_MODULE_SRCS)

# use of an external C module (static compilation)

test_fib.c: $(QJSC) examples/test_fib.js
	$(QJSC) -e -M examples/fib.so,fib -m -o $@ examples/test_fib.js

examples/test_fib: $(OBJDIR)/test_fib.o $(OBJDIR)/examples/fib.o libquickjs$(LTOEXT).a
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

examples/fib.so: $(OBJDIR)/examples/fib.pic.o
	$(CC) $(LDFLAGS) -shared -o $@ $^

examples/point.so: $(OBJDIR)/examples/point.pic.o
	$(CC) $(LDFLAGS) -shared -o $@ $^

###############################################################################
# documentation

DOCS=doc/quickjs.pdf doc/quickjs.html doc/jsbignum.pdf doc/jsbignum.html 

build_doc: $(DOCS)

clean_doc: 
	rm -f $(DOCS)

doc/%.pdf: doc/%.texi
	texi2pdf --clean -o $@ -q $<

doc/%.html.pre: doc/%.texi
	makeinfo --html --no-headers --no-split --number-sections -o $@ $<

doc/%.html: doc/%.html.pre
	sed -e 's|</style>|</style>\n<meta name="viewport" content="width=device-width, initial-scale=1.0">|' < $< > $@

###############################################################################
# tests

ifndef CONFIG_DARWIN
test: tests/bjson.so
endif

test: qjs qjsbn
	./qjs tests/test_closure.js
	./qjs tests/test_op.js
	./qjs tests/test_builtin.js
	./qjs tests/test_loop.js
	./qjs tests/test_std.js
ifndef CONFIG_DARWIN
	./qjs tests/test_bjson.js
	./qjs examples/test_point.js
endif
	./qjsbn tests/test_closure.js
	./qjsbn tests/test_op.js
	./qjsbn tests/test_builtin.js
	./qjsbn tests/test_loop.js
	./qjsbn tests/test_std.js
	./qjsbn --qjscalc tests/test_bignum.js

test-32: qjs32 qjsbn32
	./qjs32 tests/test_closure.js
	./qjs32 tests/test_op.js
	./qjs32 tests/test_builtin.js
	./qjs32 tests/test_loop.js
	./qjs32 tests/test_std.js
	./qjsbn32 tests/test_closure.js
	./qjsbn32 tests/test_op.js
	./qjsbn32 tests/test_builtin.js
	./qjsbn32 tests/test_loop.js
	./qjsbn32 tests/test_std.js
	./qjsbn32 --qjscalc tests/test_bignum.js

stats: qjs qjs32
	./qjs -qd
	./qjs32 -qd

microbench: qjs
	./qjs --std tests/microbench.js

microbench-32: qjs32
	./qjs32 --std tests/microbench.js

# ES5 tests (obsolete)
test2o: run-test262
	time ./run-test262 -m -c test262o.conf

test2o-32: run-test262-32
	time ./run-test262-32 -m -c test262o.conf

test2o-update: run-test262
	./run-test262 -u -c test262o.conf

# Test262 tests
test2-default: run-test262
	time ./run-test262 -m -c test262.conf

test2: run-test262
	time ./run-test262 -m -c test262.conf -a

test2-32: run-test262-32
	time ./run-test262-32 -m -c test262.conf -a

test2-update: run-test262
	./run-test262 -u -c test262.conf -a

test2-check: run-test262
	time ./run-test262 -m -c test262.conf -E -a

# Test262 + BigInt tests
test2bn-default: run-test262-bn
	time ./run-test262-bn -m -c test262bn.conf

test2bn: run-test262-bn
	time ./run-test262-bn -m -c test262bn.conf -a

test2bn-32: run-test262-bn32
	time ./run-test262-bn32 -m -c test262bn.conf -a

testall: all test microbench test2o test2 test2bn

testall-32: all test-32 microbench-32 test2o-32 test2-32 test2bn-32

testall-complete: testall testall-32

bench-v8: qjs qjs32
	make -C tests/bench-v8
	./qjs -d tests/bench-v8/combined.js

tests/bjson.so: $(OBJDIR)/tests/bjson.pic.o
	$(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS)

-include $(wildcard $(OBJDIR)/*.d)
