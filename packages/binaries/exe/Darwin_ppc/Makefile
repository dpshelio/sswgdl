#	$Id: Makefile,v 1.25 2002/10/25 19:51:39 scottm Exp $
#
#
#  Copyright (c) 1988-2002, Research Systems Inc.  All rights reserved.
#  This software includes information which is proprietary to and a
#  trade secret of Research Systems, Inc.  It is not to be disclosed
#  to anyone outside of this organization. Reproduction by any means
#  whatsoever is  prohibited without express written permission.
#
#  11-Marchk-2005 - S.L.Freeland - added Darwin gcc flags which seem to 
#  work and yield a functional client  (althogh I claim no knowledge about what they do...)
#
# makefile for new rpc routines.
#
# Purpose:
# 	This makefile is used to build the routines that make up
#	the IDL rpc system.
#
# Edits:
# 	The following macro might need to be edited if the location
#	of IDL is not the standard location on your system.

IDL_DIR = /usr/local/rsi/idl

# Define macros used in the makefile.

#SERVER_OBJS = rpc_srvr.o rpc_tout.o
#CLIENT_OBJ  = rpc_clnt.o 


# The following macros are defined when this file recurses and should 
# not be edited since they are overridden at run time.

LD_SYS_PRE 	=
LD_SYS_POST 	=   
FLAGS 		= 
C_FLAGS		= -c $(FLAGS) $(ARCH_FLAGS)
LD 		= ld
CC		= gcc
SHELL		= /bin/sh

# Declare a flag when a different arch is being used
ARCH_FLAGS      = 

# The following macro is used to define sub-directory of the IDL_DIR/bin
# directory for the system the file run on.

BIN_DIR 	= 

# Some systems (sun os) use flags to specify dynamic libs and static ones
# during link time.

BDYNAMIC	=
BSTATIC		=
SO_VERSION 	= 
SHL_EXTENSION	=so
SHL_LD_FLAGS	=
L_XM            =-lXm


TEST_POST	=

LD_LIBRARY_PATH = .

# build the loader flags that are required to build the idlrpc executable.
# If this is a Linux system you will need to have motif installed!

LD_FLAGS = $(LD_SYS_PRE) $(ARCH_FLAGS) -L$(IDL_DIR)/bin/$(BIN_DIR) -lidl \
	$(LD_SYS_POST) $(BSTATIC) $(L_XM) -lXt -lXext -lX11 $(BDYNAMIC) \
	$(L_TERMCAP) -lm

# The following is the default entry point. This section will determine 
# what system we are on and call make again with the correct flags set.

all : 
	@echo "OS type detected: "`uname`
	@case `uname` in \
	   "AIX") make rpclib \
			"LD=cc" \
			"SHL_EXTENSION=a" \
			"SHL_LD_FLAGS= -bM:SRE -bE:idl_rpc.export -bnoentry" \
			"TEST_LD_FLAGS=-L." \
			"BIN_DIR=bin.ibm" ;; \
	   "Darwin" )  make rpclib \
			"LD=cc" \
		        "SHL_CFLAGS= -no-cpp-precomp -dynamic -flat_namespace undefined suppress  -fno-common" \
			"SHL_LD_FLAGS=-dynamiclib -multiply_defined suppress" \
		        "LD_SYS_PRE=-L/usr/X11R6/lib" \
			"FLAGS=-no-cpp-precomp  -dynamic -fno-common" \
			"LD_SYS_POST= -lMesaGLU -lMesaGL -lOSMesa -llanginfo" \
			"TEST_LD_FLAGS=-L." \
			"BIN_DIR=bin.darwin.ppc" \
			"SHL_EXTENSION=dylib" ;; \
	   "HP-UX") make rpclib  \
			"FLAGS=-Aa +e -D_HPUX_SOURCE +DAportable" \
			"LD_SYS_PRE= -Wl,+b,. -Wl,+s -Wl,-E -L." \
			"LD_SYS_POST= -lMesaGLU -lMesaGL -lcur_colr -lcl -lnsl -lpthread -ldld" \
			"BIN_DIR=bin.hp" \
			"SHL_CFLAGS=+z" \
			"SHL_LD_FLAGS= -b -Brestricted +b . +s" \
			"SHL_EXTENSION= sl" \
			"TEST_POST=-lnsl" \
			"TEST_LD_FLAGS= -Wl,+b,. -Wl,+s -L.";; \
	   "IRIX" )  make rpclib "BIN_DIR=bin.sgi" \
			"SHL_CFLAGS=-KPIC" \
			"SHL_LD_FLAGS=-Bsymbolic -shared" \
			"ARCH_FLAGS=-n32 -mips3" \
			"TEST_LD_FLAGS=-L. -rpath ." \
			"LD_SYS_POST= /usr/lib32/fixade.o -lfpe -lpthread" \
			"L_TERMCAP=-ltermcap";; \
	   "IRIX64" )  make rpclib "BIN_DIR=bin.sgi" \
			"SHL_CFLAGS=-KPIC" \
			"SHL_LD_FLAGS=-Bsymbolic -shared" \
			"ARCH_FLAGS=-n32 -mips3" \
			"TEST_LD_FLAGS= -L. -rpath ." \
			"LD_SYS_POST= /usr/lib32/mips3/fixade.o -lfpe -lpthread" \
			"L_TERMCAP=-ltermcap";; \
	   "Linux" )  make rpclib \
		      "LD_SYS_PRE=-L/usr/X11R6/lib" \
		      "SHL_CFLAGS= -fPIC" \
		      "LD_SYS_POST=-Wl,-rpath,. -lMesaGLU -lMesaGL -lOSMesa -lXp -lXpm -lrt -lpthread" \
		      "SHL_LD_FLAGS= -shared" \
		      "TEST_LD_FLAGS=-L. -Wl,-rpath,." \
		      "BIN_DIR=bin.linux.x86" \
		      "L_TERMCAP=-ltermcap" ;; \
	   "OSF1" )  make rpclib "BIN_DIR=bin.alpha" \
			"SHL_LD_FLAGS=-expect_unresolved '*' -shared" \
			"TEST_LD_FLAGS=-L. -Wl,-rpath,." \
			"LD_SYS_POST=-lrt -lpthread" \
			"FLAGS= -float" \
			"L_TERMCAP=-ltermcap";; \
	   "SunOS") if [ -d /proc -a `mach` = i386 ]; then \
	           	make rpclib "FLAGS=-DSOLARIS -Xa -xlibmieee" \
			"LD_SYS_PRE=-L/usr/openwin/lib -L/usr/dt/lib -R.:/usr/dt/lib" \
			"LD_SYS_POST= -lnsl -lintl -lgen -lsunmath -lpthread -lrt" \
			"SHL_CFLAGS=-K pic" \
			"SHL_LD_FLAGS=-Bsymbolic -z nodefs -R . -G" \
			"TEST_LD_FLAGS= -z defs -i -R . -L." \
			"TEST_POST=-lnsl" \
			"BIN_DIR=bin.solaris2.x86" \
			"L_TERMCAP=-ltermcap"; \
	      	    elif [ -d /proc ]; then \
	           	make rpclib "FLAGS= -DSOLARIS" \
			"LD_SYS_PRE=-L/usr/openwin/lib -L/usr/dt/lib -R.:/usr/dt/lib" \
			"LD_SYS_POST= -lnsl -lintl -lgen -lsunmath -lpthread -lrt" \
			"SHL_CFLAGS=-K pic" \
			"SHL_LD_FLAGS=-Bsymbolic -z nodefs -R . -G" \
			"TEST_LD_FLAGS= -z defs -i -R . -L." \
			"TEST_POST=-lnsl" \
			"BIN_DIR=bin.solaris2.sparc" \
			"L_TERMCAP=-ltermcap"; \
	   	    fi  \
		;; \
	   *) echo "This system is not supported" ;; \
       esac

# The following is the entry point that triggers the actual build 

rpclib: idlrpc  libidl_rpc.$(SHL_EXTENSION)$(SO_VERSION)  \
		idlRpcClient


idlRpcClient : idlRpcClient.o
	$(CC) -o idlRpcClient $(ARCH_FLAGS) $(TEST_LD_FLAGS) idlRpcClient.o \
			-lidl_rpc $(TEST_POST)

tidy: 
	rm -f $(CLIENT_OBJS) $(SERVER_OBJS)
clean : 
	rm -f libidl_rpc.* idlrpc idlRpcClient $(SERVER_OBJS) rpc_clnt.o idlRpcClient.o \
		idl_rpc_xdr.o idl_rpc_test idl_rpc_test.o idl_rpc_obsolete.o

.SUFFIXES: .c .o

.c.o :
	$(CC) $(C_FLAGS) $*.c

