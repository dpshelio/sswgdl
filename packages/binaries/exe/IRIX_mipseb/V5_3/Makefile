#   $Id: Makefile,v 1.2 1997/04/02 22:07:42 beth Exp $
#
#  Platform independant makefile for the IDL Call_External() examples.
#
SHELL=/bin/sh
CFLAGS=
FFLAGS=

SHL_LIBS= trace_decode_idl.$(SHL_EXT) 

# The following is the default entry point. This section will determine 
# what system we are on, set the correct flags and call this same makefile
# again with the correct flags.

all : 
	@echo "OS type detected: "`uname`
	@case `uname` in \
	   "SunOS") if [  -d /proc ]; then \
			make libs \
			"SHL_EXT=so" \
			"CC=cc" \
			"F77=f77" \
			"C_LD=cc" \
			"F_LD=f77" \
			"CFLAGS=-K pic -DSPARC -G" \
			"C_LD_FLAGS=-G -DSOLARIS" \
			"FFLAGS=-pic -G" \
			"FOBJS=ftn_only_sun.o ftn_strarr_sun.o" \
			"F_LD_FLAGS=-G" \
			"F_LD_POST= -lF77 -lm -lc"; \
	      	    else \
	           	make libs \
			"SHL_EXT=so" \
			"CC=acc" \
			"F77=f77" \
			"C_LD=ld" \
			"F_LD=ld" \
			"CFLAGS=-pic -DSPARC -fsingle" \
			"C_LD_FLAGS=-assert pure-text" \
			"F_LD_FLAGS=-assert pure-text" \
			"FFLAGS=-pic" \
			"FOBJS=ftn_only_sun.o ftn_strarr_sun.o" \
			"F_LD_POST= -L/usr/lang/SC3.0.1/lib -lF77 "; \
	   	    fi  \
		;; \
	   "AIX") make libs \
			"SHL_EXT=a" \
			"CC=gcc" \
			"F77=f77" \
			"C_LD=ld" \
			"F_LD=f77" \
			"C_LD_FLAGS=-bM:SRE -bnoentry" \
			"F_LD_FLAGS=-bM:SRE -bnoentry" \
			"SIMPLE_EXPORT=-bE:simple.exp" \
			"C_LD_POST=-lc" \
			"DOUBLE_EXPORT=-bE:double_array.exp" \
			"STRING_EXPORT=-bE:string_array.exp" \
			"SIMPLEC2F_EXPORT=-bE:simple_c2f.exp" \
			"FORTRAN_EXPORT=-bE:ftn_only.exp" \
			"FOBJS=ftn_only_ibm.o" \
			"F_LD_POST= -lxlf -lxlf90";; \
	   "HP-UX") make libs \
			"SHL_EXT=sl" \
			"CC=cc" \
			"F77=f77" \
			"C_LD=ld" \
			"F_LD=ld" \
			"CFLAGS=+z" \
			"C_LD_FLAGS=-b" \
			"F_LD_FLAGS=-b" \
			"FFLAGS=+z" \
			"FOBJS=ftn_only_hp.o ftn_strarr_hp.o" ;; \
	   "IRIX" ) make libs \
			"SHL_EXT=so" \
			"CC=cc" \
			"F77=@echo \"NOT Implemented for example: f77 \"" \
			"C_LD=ld" \
			"F_LD=@echo \"NOT Implemented for example: f77 \"" \
			"CFLAGS=-KPIC -Xcpluscomm -c -cckr -float  -O2" \
			"C_LD_FLAGS=-shared";; \
           "IRIX64" ) make libs \
                        "SHL_EXT=so" \
                        "CC=cc" \
                        "F77=@echo \"NOT Implemented for example: f77 \"" \
                        "C_LD=ld" \
                        "F_LD=@echo \"NOT Implemented for example: f77 \"" \
                        "CFLAGS=-KPIC -n32 -Xcpluscomm -c -cckr -float  -O2" \
                        "C_LD_FLAGS= -n32 -shared";; \
	   "OSF1" )  make libs \
			"SHL_EXT=so" \
			"CC=cc" \
			"F77=f77" \
			"C_LD=ld" \
			"F_LD=ld" \
			"CFLAGS=-DOSF1" \
			"C_LD_FLAGS=-S -shared" \
			"F_LD_FLAGS=-S -shared" \
			"FOBJS=ftn_only_osf1.o" \
			"F_LD_POST= -lUfor -lfor -lFutil -lm -lots -lc";; \
	   "Linux" ) make libs \
			"SHL_EXT=so" \
			"CC=cc" \
			"F77=@echo \"NOT Implemented for example: f77 \"" \
			"C_LD=ld" \
			"F_LD=@echo \"NOT Implemented for example: f77 \"" \
			"CFLAGS=-fPIC" \
			"C_LD_FLAGS=-shared";; \
	   *) echo "This system is not supported" ;; \
       esac

libs : $(SHL_LIBS)

# C Only libs

trace_decode_idl.$(SHL_EXT) : trace_decode_idl.o
	$(C_LD) $(C_LD_FLAGS) -o trace_decode_idl.$(SHL_EXT) trace_decode_idl.o $(SIMPLE_EXPORT) \
		$(C_LD_POST)

# Cleanup

tidy :
	rm -f *.o

clean :
	rm -f *.o *.so *.sl *.a

#  Rules for building the object files.

.SUFFIXES: .c .o 

.c.o :
	$(CC) $(CFLAGS) -c $*.c



