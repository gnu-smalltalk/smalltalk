dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_C_SYMBOLSET], [

# This test outputs the list of symbols which /bin/cc or /lib/cpp
# define and which we had the foresight to guess at.  When
# cross-compiling, we only consider /lib/cpp.
AC_CACHE_CHECK(builtin preprocessor symbol set, gst_cv_machine_defines,
[   syms="AMIX BIT_MSF BSD BSD4_3 BSD_NET2 CMU CRAY DGUX DOLPHIN DPX2 \
	GO32 GOULD_PN HP700 I386 I80960 I960 Lynx M68000 M68K MACH \
	MIPSEB MIPSEL MSDOS MTXINU MULTIMAX MVS \
	M_COFF M_I186 M_I286 M_I386 M_I8086 M_I86 M_I86SM \
	M_SYS3 M_SYS5 M_SYSIII M_SYSV M_UNIX M_XENIX \
	NeXT OCS88 OSF1 PARISC PC532 PORTAR POSIX \
	PWB R3000 RES RISC6000 RT Sun386i SVR3 SVR4 \
	SYSTYPE_BSD SYSTYPE_SVR4 SYSTYPE_SYSV Tek4132 Tek4300 \
	UMAXV USGr4 USGr4_2 UTEK UTS UTek UnicomPBB UnicomPBD Utek \
	VMS WIN32 Xenix286 \
	_AIX _AIX32 _AIX370 _AM29000 _COFF _CRAY _CX_UX _EPI \
	_IBMESA _IBMR2 _M88K _M88KBCS_TARGET \
	_MIPSEB _MIPSEL _M_COFF _M_I86 _M_I86SM _M_SYS3 \
	_M_SYS5 _M_SYSIII _M_SYSV _M_UNIX _M_XENIX _NLS _PGC_ _R3000 \
	_SYSTYPE_BSD _SYSTYPE_BSD43 _SYSTYPE_SVR4 \
	_SYSTYPE_SYSV _SYSV3 _U370 _UNICOS \
	__386BSD__ __BIG_ENDIAN __BIG_ENDIAN__ __BSD_4_4__ \
	__CYGWIN__ __CYGWIN32__ __DGUX__ __DPX2__ __H3050R __H3050RX \
	__LITTLE_ENDIAN __LITTLE_ENDIAN__ __MACH__ _MSC_VER \
	__MIPSEB __MIPSEB__ __MIPSEL __MIPSEL__ \
	__Next__ __OS2__ __OSF1__ __PARAGON__ __PGC__ __PWB __STDC__ \
	__SVR4_2__ __UMAXV__ __WIN32__ _WIN32 \
	____386BSD____ __alpha __alpha__ __amiga \
	__bsd4_2 __bsd4_2__ __bsdi__ __convex__ \
	__host_mips__ \
	__hp9000s200 __hp9000s300 __hp9000s400 __hp9000s500 \
	__hp9000s500 __hp9000s700 __hp9000s800 \
	__hppa __hpux __hp_osf __ia64 __ia64__ __i386 __i386__ \
	__i486 __i486__ __i860 __i860__ __ibmesa __ksr1__ __linux__ \
	__m68k __m68k__ __m88100__ __m88k __m88k__ \
	__mc68000 __mc68000__ __mc68020 __mc68020__ \
	__mc68030 __mc68030__ __mc68040 __mc68040__ \
	__mc88100 __mc88100__ __mips __mips__ \
	__motorola__ __osf__ __pa_risc __sparc__ __stdc__ \
	__sun __sun__ __svr3__ __svr4__ __ultrix __ultrix__ \
	__unix __unix__ __uxpm__ __uxps__ __vax __vax__ \
	_host_mips _mips _unix \
	a29k aegis aix aixpc alliant alpha am29000 amiga \
	ansi ardent apollo ardent att386 att3b \
	bsd bsd43 bsd4_2 bsd4_3 bsd4_4 bsdi bull \
	cadmus clipper concurrent convex cray ctix \
	dmert encore gcos gcx gimpel gould \
	hbullx20 hcx host_mips hp200 hp300 hp700 hp800 \
	hp9000 hp9000s300 hp9000s400 hp9000s500 \
	hp9000s700 hp9000s800 hp9k8 hppa hpux \
	ia64 i386 i486 i80960 i860 iAPX286 ibm \
	ibm032 ibmrt interdata is68k \
	ksr1 linux luna luna88k m68k m88100 m88k \
	mc300 mc500 mc68000 mc68010 mc68020 mc68030 \
	mc68040 mc68060 mc68k mc68k32 mc700 \
	mc88000 mc88100 merlin mert mips mvs n16 \
	ncl_el ncl_mr \
	news1500 news1700 news1800 news1900 news3700 \
	news700 news800 news900 ns16000 ns32000 \
	ns32016 ns32332 ns32k nsc32000 os osf \
	parisc pc532 pdp11 plexus posix pyr \
	riscix riscos scs sequent sgi sinix sony sony_news \
	sonyrisc sparc sparclite spectrum stardent stratos \
	sun sun3 sun386 svr4 sysV68 sysV88 \
	titan tower tower32 tower32_200 tower32_600 tower32_700 \
	tower32_800 tower32_850 tss u370 u3b u3b2 u3b20 u3b200 \
	u3b20d u3b5 ultrix unix unixpc unos vax venix vms \
	xenix z8000"

    if test $cross_compiling != yes; then
      # Some cpp's do not define any symbols, but instead let /bin/cc do it
      # for them.  For such machines, not using CPP to run this test (instead
      # creating a program which printf's them to stdout) may prove useful.
      (echo "#include <stdio.h>"			;\
      echo "main ()" 					;\
      echo "{"						;\
      Q=\\\"						;\
      for i in $syms; do				 \
	echo "#ifdef $i"				;\
	echo "  printf(\"$Q$i$Q, \");"			;\
	echo "#endif"					;\
      done						;\
      echo "  printf (\"\n\");"				;\
      echo "  exit (0);"				;\
      echo "}")						>conftest.$ac_ext

      dnl Stolen from AC_RUN_IFELSE's definition
      AC_TRY_EVAL(ac_link) && gst_cv_machine_defines=`./conftest 2>/dev/null`
    fi
    if test -z "$gst_cv_machine_defines"; then
      (for i in $syms; do				 \
	echo "#ifdef $i"				;\
	echo "\"$i\","					;\
	echo "#endif"					;\
      done)						>conftest.$ac_ext

      gst_cv_machine_defines=`(eval "$ac_cpp conftest.$ac_ext") | sed -ne '/,/H' -e g -e '$s/\n/ /gp;' `
    fi
    rm -rf conftest*
])

AC_DEFINE_UNQUOTED(MACHINE_DEFINES, $gst_cv_machine_defines,
  [The set of builtin preprocessor symbols which are defined on the target.])

])dnl
