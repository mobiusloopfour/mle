AM_CFLAGS = -W -Wall -Wextra -std=gnu17
AM_CXXFLAGS = -W -Wall -Wextra -std=c++20 -Wno-sign-compare -Wno-unneeded-internal-declaration -Wno-unused-function -Wno-unused-parameter

noinst_LIBRARIES = libmleparse.a

libmleparse_a_SOURCES = \
	Parser.yy Scanner.ll

BUILT_SOURCES = Parser.hh Parser.cc Scanner.cc

bin_PROGRAMS = mle

mle_SOURCES = Driver.cc
mle_DEPENDENCIES = libmleparse.a

LIBS = libmleparse.a

# this output override is needed because the c++ scanner is outputted into
# lex.yy.cc and the automake ylwrap script only checks for lex.yy.c
AM_LFLAGS = -olex.yy.c
AM_YFLAGS = -d

extraclean:
	rm -f Parser.cc Parser.hh Scanner.cc

rebuild: clean extraclean all