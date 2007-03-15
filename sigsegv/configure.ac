dnl Autoconf configuration for libsigsegv.
dnl Process this file with autoconf to produce a configure script.
dnl
dnl Copyright (C) 2002-2003  Bruno Haible <bruno@clisp.org>
dnl
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software Foundation,
dnl Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

AC_PREREQ(2.60)
AC_INIT
AC_CONFIG_SRCDIR(src/sigsegv.h.in)
AC_CONFIG_AUX_DIR(../build-aux)
AC_CONFIG_MACRO_DIR(../build-aux)

RSE_BOLD

{ echo; echo "${term_bold}Build Tools:${term_norm}"; } >& AS_MESSAGE_FD

AM_INIT_AUTOMAKE(libsigsegv, 2.2)
AM_CONFIG_HEADER(config.h)

AC_PROG_CC
AC_PROG_CPP

AC_CANONICAL_HOST
AC_MSG_CHECKING([host platform])
sv_cv_host="$host"
changequote(,)dnl Autoconf 2.52 brokenness
case "$host_os" in
  linux | linux-*)
    kernelversion=`uname -r | sed -e 's/^\([0-9.]*\).*/\1/'`
    sv_cv_host=`echo $sv_cv_host | sed -e "s/linux/linux$kernelversion/"`
    ;;
esac
changequote([,])dnl Autoconf 2.52 brokenness
cat > conftest.c << EOF
#include <features.h>
#ifdef __GNU_LIBRARY__
Version __GLIBC__ . __GLIBC_MINOR__
#endif
EOF
glibcversion=`$CPP $CPPFLAGS conftest.c 2>/dev/null | grep Version | sed -e 's/Version//' -e 's/ //g'`
if test -n "$glibcversion"; then
  sv_cv_host="$sv_cv_host-glibc$glibcversion"
fi
AC_MSG_RESULT([$sv_cv_host])
PLATFORM="$sv_cv_host"
AC_SUBST(PLATFORM)

AC_PROG_INSTALL
AC_PROG_SED

AC_LIBTOOL_TAGS([])
AC_PROG_LIBTOOL

# For testing cross-compilation behaviour.
#cross_compiling=yes

{ echo; echo "${term_bold}Optional Platform Environment:${term_norm}"; } >& AS_MESSAGE_FD

# Headers to be included with <signal.h>.
AC_CHECK_HEADERS([sys/signal.h])

# How to determine the memory page size.
SV_GETPAGESIZE

# How to allocate fresh memory using mmap.
# (We need mmap, because mprotect() doesn't work on malloc()ed memory on
# some systems.)
SV_MMAP_ANON

AC_CHECK_FUNCS([getrlimit setrlimit])
    
# The idea here is that some other OS than Unix may need
# some of the detection magic, which seems plausible
# especially for CFG_STACKVMA.
case "$host" in
  i?86-*-mingw* | i?86-*-cygwin*)
    FAULT_CONTEXT='CONTEXT'
    FAULT_CONTEXT_INCLUDE='#include <windows.h>'
    CFG_HANDLER=handler-win32.c
    CFG_STACKVMA=stackvma-none.c
    CFG_FAULT=fault-none.h
    CFG_LEAVE=leave-none.c
    CFG_SIGNALS=signals.h
    sv_cv_have_sigsegv_recovery=yes
    sv_cv_have_stack_overflow_recovery=yes
    ;;

  powerpc-*-macos* | powerpc-*-darwin*)
    FAULT_CONTEXT='ppc_exception_state_t'
    FAULT_CONTEXT_INCLUDE='#include <mach/thread_status.h>'
    CFG_FAULT=machfault-macos-powerpc.h
    CFG_HANDLER=handler-macos.c
    CFG_LEAVE=leave-none.c
    CFG_SIGNALS=signals.h
    CFG_STACKVMA=detect
    sv_cv_have_sigsegv_recovery=yes
    ;;

  *)
    FAULT_CONTEXT=void
    FAULT_CONTEXT_INCLUDE=
    CFG_HANDLER=handler-unix.c
    CFG_STACKVMA=detect
    CFG_LEAVE=detect
    CFG_SIGNALS=detect

    # Catching stack overflow requires an alternate signal stack.
    # The old "install a guard page" trick would be unreliable, because
    # we don't know where exactly to place the guard page.
    SV_SIGALTSTACK

    # List of signals that are sent when an invalid virtual memory address
    # is accessed, or when the stack overflows.
    case "$host_os" in
      sunos4* | freebsd* | openbsd* | netbsd* | kfreebsd*)
        CFG_SIGNALS=signals-bsd.h ;;
      hpux*)
        CFG_SIGNALS=signals-hpux.h ;;
      gnu*)
        CFG_SIGNALS=signals-hurd.h ;;
      *)
        CFG_SIGNALS=signals.h ;;
    esac
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([POSIX], sv_cv_fault_posix,
      [*-*-solaris2.[7-9] | i?86-*-linux2.[4-9]* | i?86-*-freebsd[4-9]* | alpha*-dec-osf[4-9]* | *-*-hpux11* | mips-sgi-irix6*],
      [],
      [int sig, siginfo_t *sip, void *ucp],
      [sip->si_addr],
      [action.sa_sigaction = &sigsegv_handler;
       action.sa_flags = SA_SIGINFO;])
  
    SV_TRY_FAULT([Linux/i386], sv_cv_fault_linux_i386, [i?86-*-linux2.[2-9]*],
      [#include <asm/sigcontext.h>],
      [int sig, struct sigcontext sc],
      [sc.cr2])
  
    SV_TRY_FAULT([old Linux/i386], sv_cv_fault_linux_i386_old,
      [i?86-*-linux2.[2-9]*],
      [],
      [int sig, unsigned int more],
      [((unsigned long *) &more) [21]])
  
    SV_TRY_FAULT([Linux/m68k], sv_cv_fault_linux_m68k, [m68k-*-linux*],
      [#include <asm/sigcontext.h>
    #include "$srcdir/src/fault-linux-m68k.c"],
      [int sig, int code, struct sigcontext *scp],
      [get_fault_addr (scp)])
  
    SV_TRY_FAULT([Linux/PowerPC], sv_cv_fault_linux_powerpc, [powerpc*-*-linux*],
      [#include <asm/sigcontext.h>],
      [int sig, struct sigcontext *scp],
      [scp->regs->dar])
  
    SV_TRY_FAULT([Linux/HPPA], sv_cv_fault_linux_hppa, [hppa*-*-linux*],
      [],
      [int sig, siginfo_t *sip, void *ucp],
      [sip->si_ptr],
      [action.sa_sigaction = &sigsegv_handler;
       action.sa_flags = SA_SIGINFO;])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([BSD], sv_cv_fault_bsd, [i?86-*-freebsd[4-9]*],
      [],
      [int sig, int code, struct sigcontext *scp, void *addr],
      [addr])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([IRIX], sv_cv_fault_irix, [mips-sgi-irix6*],
      [],
      [int sig, int code, struct sigcontext *scp],
      [(unsigned long) scp->sc_badvaddr])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([HP-UX HPPA], sv_cv_fault_hpux_hppa, [hppa*-*-hpux11*],
      [
#    define USE_64BIT_REGS(mc) \
      (((mc).ss_flags & SS_WIDEREGS) && ((mc).ss_flags & SS_NARROWISINVALID))
#    define GET_CR21(mc) \
      (USE_64BIT_REGS(mc) ? (mc).ss_wide.ss_64.ss_cr21 : (mc).ss_narrow.ss_cr21)
    ],
      [int sig, int code, struct sigcontext *scp],
      [GET_CR21 (scp->sc_sl.sl_ss)])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([OSF/1 Alpha], sv_cv_fault_osf_alpha,
      [alpha*-*-osf[4-9]* | alpha*-*-linux2.[4-9]*],
      [],
      [int sig, int code, struct sigcontext *scp],
      [scp->sc_traparg_a0])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([NetBSD Alpha], sv_cv_fault_netbsd_alpha,
      [alpha*-*-osf[4-9]* | alpha-*-*bsd*],
      [#include "$srcdir/src/fault-netbsd-alpha.c"],
      [int sig, int code, struct sigcontext *scp],
      [get_fault_addr (scp)])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([AIX], sv_cv_fault_aix, [*-*-aix*],
      [],
      [int sig, int code, struct sigcontext *scp],
      [scp->sc_jmpbuf.jmp_context.o_vaddr])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_FAULT([Hurd], sv_cv_fault_hurd, [],
      [],
      [int sig, int code, struct sigcontext *scp],
      [code])
  
    dnl Now determine the fault handler include file.
    dnl We prefer the platform specific include files to the generic fault-posix.h
    dnl because the former often defines SIGSEGV_FAULT_STACKPOINTER.
    dnl Also we put the BSD test second-to-last, because the test may produce
    dnl false positives.
    dnl
    dnl First the cases where the OS provides the fault address.
    dnl
    CFG_FAULT=fault-none.h
    if test "$sv_cv_fault_aix" = yes; then
      case "$host_cpu" in
        powerpc* | rs6000) CFG_FAULT=fault-aix-powerpc.h ;;
        *) CFG_FAULT=fault-aix.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_irix" = yes; then
      case "$host_cpu" in
        mips*) CFG_FAULT=fault-irix-mips.h ;;
        *) CFG_FAULT=fault-irix.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_hpux_hppa" = yes; then
      case "$host_cpu" in
        hppa* | parisc*) CFG_FAULT=fault-hpux-hppa.h ;;
        *) CFG_FAULT=fault-hpux.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_osf_alpha" = yes; then
      case "$host_cpu" in
        alpha*) CFG_FAULT=fault-osf-alpha.h ;;
        *) CFG_FAULT=fault-osf.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_netbsd_alpha" = yes; then
      case "$host_cpu" in
        alpha*) CFG_FAULT=fault-netbsd-alpha.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_linux_i386" = yes; then
      case "$host_cpu" in
        i?86 | x86_64) CFG_FAULT=fault-linux-i386.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_linux_i386_old" = yes; then
      case "$host_cpu" in
        i?86 | x86_64) CFG_FAULT=fault-linux-i386-old.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_linux_m68k" = yes; then
      case "$host_cpu" in
        m68*) CFG_FAULT=fault-linux-m68k.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_linux_powerpc" = yes; then
      case "$host_cpu" in
        powerpc* | rs6000) CFG_FAULT=fault-linux-powerpc.h ;;
      esac
      FAULT_CONTEXT='struct sigcontext'
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_linux_hppa" = yes; then
      case "$host_cpu" in
        hppa* | parisc*) CFG_FAULT=fault-linux-hppa.h ;;
      esac
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_hurd" = yes; then
      case "$host_os" in
        netbsd*) # A false positive.
          ;;
        *)
          CFG_FAULT=fault-hurd.h
          FAULT_CONTEXT='struct sigcontext'
          ;;
      esac
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_bsd" = yes; then
      case "$host_os" in
        freebsd*|kfreebsd*)
          case "$host_cpu" in
            i?86 | x86_64)
              CFG_FAULT=fault-freebsd-i386.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            *)
              CFG_FAULT=fault-bsd.h
              FAULT_CONTEXT='void'
              ;;
          esac
          ;;
        *)
          CFG_FAULT=fault-bsd.h
          FAULT_CONTEXT='void'
          ;;
      esac
    fi
    if test "$CFG_FAULT" = fault-none.h && test "$sv_cv_fault_posix" = yes; then
      case "$host_os" in
        openbsd*)
          case "$host_cpu" in
            i?86 | x86_64) CFG_FAULT=fault-openbsd-i386.h ;;
            *) CFG_FAULT=fault-openbsd.h ;;
          esac
          FAULT_CONTEXT='struct sigcontext'
          ;;
        linux*)
          case "$host_cpu" in
            ia64)
              CFG_FAULT=fault-linux-ia64.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
          esac
          ;;
      esac
      if test "$CFG_FAULT" = fault-none.h; then
        case "$host_os" in
          solaris*)
            case "$host_cpu" in
              i?86 | x86_64) CFG_FAULT=fault-solaris-i386.h ;;
              sparc*) CFG_FAULT=fault-solaris-sparc.h ;;
              *) CFG_FAULT=fault-solaris.h ;;
            esac
            ;;
          *)
            CFG_FAULT=fault-posix.h
            ;;
        esac
        FAULT_CONTEXT='ucontext_t'
        FAULT_CONTEXT_INCLUDE='#include <ucontext.h>'
      fi
    fi
    dnl
    dnl Next, the cases where there is a hairy CPU dependent way to get the
    dnl fault address.
    dnl
    if test "$CFG_FAULT" = fault-none.h; then
      sv_cv_have_sigsegv_recovery=no
      dnl
      dnl No way to get the fault address. But other information is available.
      dnl
      case "$host_os" in
        linux*)
          case "$host_cpu" in
            alpha*)
              CFG_FAULT=fault-linux-alpha.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            arm* | strongarm* | xscale*)
              CFG_FAULT=fault-linux-arm.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            cris)
              CFG_FAULT=fault-linux-cris.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            mips*)
              CFG_FAULT=fault-linux-mips.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            s390*)
              CFG_FAULT=fault-linux-s390.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            sh*)
              CFG_FAULT=fault-linux-sh.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            sparc*)
              CFG_FAULT=fault-linux-sparc.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
            x86_64)
              CFG_FAULT=fault-linux-x86_64.h
              FAULT_CONTEXT='struct sigcontext'
              ;;
          esac
          ;;
        beos*)
          case "$host_cpu" in
            i?86 | x86_64) CFG_FAULT=fault-beos-i386.h ;;
            *) CFG_FAULT=fault-beos.h ;;
          esac
          FAULT_CONTEXT='struct vregs'
          ;;
      esac
    else
      sv_cv_have_sigsegv_recovery=yes
    fi

    # How to longjmp out of a signal handler, in such a way that the
    # alternate signal stack remains functional.
    CFG_LEAVE=leave-none.c
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_LEAVE_HANDLER_LONGJMP([], sv_cv_leave_handler_longjmp,
      [*-*-osf[4-9]* | *-*-hpux11* | *-*-linux2.[2-9]*],
      [], [])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_LEAVE_HANDLER_LONGJMP([ and sigaltstack],
      sv_cv_leave_handler_longjmp_sigaltstack,
      [*-*-freebsd*],
      [
#    ifndef SS_ONSTACK
#    define SS_ONSTACK SA_ONSTACK
#    endif
      ],
      [stack_t ss;
       if (sigaltstack (NULL, &ss) >= 0)
         {
           ss.ss_flags &= ~SS_ONSTACK;
           sigaltstack (&ss, NULL);
         }
      ])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_LEAVE_HANDLER_LONGJMP([ and setcontext],
      sv_cv_leave_handler_longjmp_setcontext,
      [*-*-irix* | *-*-solaris*],
      [#include <ucontext.h>
#    ifndef SS_ONSTACK
#    define SS_ONSTACK SA_ONSTACK
#    endif
      ],
      [static int fl;
       static ucontext_t uc;
       fl = 0;
       if (getcontext (&uc) >= 0)
         if (fl == 0)
           if (uc.uc_stack.ss_flags & SS_ONSTACK)
             {
               uc.uc_stack.ss_flags &= ~SS_ONSTACK;
               fl = 1;
               setcontext (&uc);
             }
      ])
  
    # How to siglongjmp out of a signal handler, in such a way that the
    # alternate signal stack remains functional.
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_LEAVE_HANDLER_SIGLONGJMP([], sv_cv_leave_handler_siglongjmp,
      [*-*-osf[4-9]* | *-*-hpux11* | *-*-linux2.[2-9]* | *-*-irix* | *-*-solaris*],
      [], [])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_LEAVE_HANDLER_SIGLONGJMP([ and sigaltstack],
      sv_cv_leave_handler_siglongjmp_sigaltstack,
      [*-*-freebsd*],
      [
#    ifndef SS_ONSTACK
#    define SS_ONSTACK SA_ONSTACK
#    endif
      ],
      [stack_t ss;
       if (sigaltstack (NULL, &ss) >= 0)
         {
           ss.ss_flags &= ~SS_ONSTACK;
           sigaltstack (&ss, NULL);
         }
      ])
  
    dnl FIXME: Put in some more known values into the third argument.
    SV_TRY_LEAVE_HANDLER_SIGLONGJMP([ and setcontext],
      sv_cv_leave_handler_siglongjmp_setcontext,
      [],
  [#include <ucontext.h>
#    ifndef SS_ONSTACK
#    define SS_ONSTACK SA_ONSTACK
#    endif
      ],
      [static int fl;
       static ucontext_t uc;
       fl = 0;
       if (getcontext(&uc) >= 0)
         if (fl == 0)
           if (uc.uc_stack.ss_flags & SS_ONSTACK)
             {
               uc.uc_stack.ss_flags &= ~SS_ONSTACK;
               fl = 1;
               setcontext(&uc);
             }
      ])
  
    if test "$sv_cv_leave_handler_longjmp" != no; then
      CFG_LEAVE=leave-nop.c
    else
      if test "$sv_cv_leave_handler_longjmp_sigaltstack" != no; then
        CFG_LEAVE=leave-sigaltstack.c
      else
        if test "$sv_cv_leave_handler_longjmp_setcontext" != no; then
          CFG_LEAVE=leave-setcontext.c
        fi
      fi
    fi
    case "$host_os" in
      # On BeOS, the 6 tests fail because sigaltstack() doesn't exist.
      # If one uses set_signal_stack() instead of sigaltstack(), the first
      # test actually works. i.e. sv_cv_leave_handler_longjmp would be 'yes'.
      beos*)
	CFG_LEAVE=leave-nop.c
        sv_cv_have_stack_overflow_recovery=yes
	;;
      *)
	if test "$sv_cv_sigaltstack" = no; then
          sv_cv_have_stack_overflow_recovery=no
        fi
	;;
    esac
    ;;
esac

AC_MSG_CHECKING([if the system supports catching SIGSEGV])
AC_MSG_RESULT([$sv_cv_have_sigsegv_recovery])
if test $sv_cv_have_sigsegv_recovery != no; then
  HAVE_SIGSEGV_RECOVERY=1
else
  HAVE_SIGSEGV_RECOVERY=0
fi
AC_SUBST(HAVE_SIGSEGV_RECOVERY)

dnl Stack direction.
AC_CACHE_CHECK([for stack direction], sv_cv_stack_direction_msg, [
  case "$host_cpu" in
    dnl See the #define STACK_GROWS_DOWNWARD in gcc-3.1/gcc/config/*/*.h.
    a29k | \
    alpha* | \
    arc | \
    arm* | strongarm* | xscale* | \
    avr | \
    c1 | c2 | c32 | c34 | c38 | \
    clipper | \
    cris | \
    d30v | \
    elxsi | \
    fr30 | \
    h8300 | \
    i?86 | x86_64 | \
    i860 | \
    ia64 | \
    m32r | \
    m68* | \
    m88k | \
    mcore | \
    mips* | \
    mmix | \
    mn10200 | \
    mn10300 | \
    ns32k | \
    pdp11 | \
    pj* | \
    powerpc* | rs6000 | \
    romp | \
    s390* | \
    sh* | \
    sparc* | \
    v850 | \
    vax | \
    xtensa)
      sv_cv_stack_direction=-1 ;;
    c4x | \
    dsp16xx | \
    i960 | \
    hppa* | parisc* | \
    stormy16 | \
    we32k)
      sv_cv_stack_direction=1 ;;
    *)
      if test $cross_compiling = no; then
        cat > conftest.c <<EOF
#include <stdio.h>
int
get_stack_direction ()
{
  auto char dummy;
  static char *dummyaddr = (char *)0;
  if (dummyaddr != (char *)0)
    return &dummy > dummyaddr ? 1 : &dummy < dummyaddr ? -1 : 0;
  else
    {
      dummyaddr = &dummy;
      {
        int result = get_stack_direction ();
        /* The next assignment avoids tail recursion elimination
           (IRIX 6.4 CC).  */
        dummyaddr = (char *)0;
        return result;
      }
    }
}
int
main ()
{
  printf ("%d\n", get_stack_direction ());
  return 0;
}
EOF
        AC_TRY_EVAL(ac_link)
        sv_cv_stack_direction=`./conftest`
      else
        sv_cv_stack_direction=0
      fi
      ;;
  esac
  case $sv_cv_stack_direction in
    1)  sv_cv_stack_direction_msg="grows up";;
    -1) sv_cv_stack_direction_msg="grows down";;
    *)  sv_cv_stack_direction_msg="unknown";;
  esac
])
AC_DEFINE_UNQUOTED(STACK_DIRECTION, [$sv_cv_stack_direction],
  [Define as the direction of stack growth for your system.
   STACK_DIRECTION > 0 => grows toward higher addresses
   STACK_DIRECTION < 0 => grows toward lower addresses
   STACK_DIRECTION = 0 => spaghetti stack.])

if test "$CFG_STACKVMA" = detect; then
  CFG_STACKVMA=stackvma-none.c
  dnl Determination of the stack's virtual memory area.
  AC_CACHE_CHECK([for PIOCMAP in sys/procfs.h], sv_cv_procfsvma, [
    AC_TRY_LINK([#include <sys/procfs.h>],
      [int x = PIOCNMAP + PIOCMAP; prmap_t y;],
      sv_cv_procfsvma=yes, sv_cv_procfsvma=no)
  ])
  if test $sv_cv_procfsvma = yes; then
    CFG_STACKVMA=stackvma-procfs.c
  else
    case "$host_os" in
      darwin*|macos*) CFG_STACKVMA=stackvma-mach.c ;;
      linux*) CFG_STACKVMA=stackvma-linux.c ;;
      freebsd*) CFG_STACKVMA=stackvma-freebsd.c ;;
      beos*) CFG_STACKVMA=stackvma-beos.c ;;
    esac
  fi
fi

AC_CACHE_CHECK([if the system supplies the stack pointer],
	       [sv_cv_have_fault_stack_pointer], [
AC_EGREP_CPP([xyzzy], [
#include "$srcdir/src/$CFG_FAULT"
#ifdef SIGSEGV_FAULT_STACKPOINTER
xyzzy
#endif
], [sv_cv_have_fault_stack_pointer=yes], [sv_cv_have_fault_stack_pointer=no])
])

AC_MSG_CHECKING([if the virtual memory area for an address can be found])
if test "$CFG_STACKVMA" != "stackvma-none.c"; then
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

# Now we can pick a stack overflow detection heuristic.  From best to worst:
# - stack pointer near bottom of stack 
# - fault address near bottom of stack 
# - fault address near stack pointer
case "$sv_cv_have_sigsegv_recovery:$sv_cv_have_fault_stack_pointer:$CFG_STACKVMA" in
  yes:yes:stackvma-none.c) CFG_HEURISTICS=heur-ab.h ;;
  *:*:stackvma-none.c) CFG_HEURISTICS=heur-none.h ;;
  yes:*:*) CFG_HEURISTICS=heur-ac.h ;;
  *:yes:*) CFG_HEURISTICS=heur-bc.h ;;
esac

AC_CACHE_CHECK([if the system supports catching stack overflow],
	       [sv_cv_have_stack_overflow_recovery], [
if test "$CFG_HEURISTICS" = heur-none.h; then
  sv_cv_have_stack_overflow_recovery=no
else
  sv_cv_have_stack_overflow_recovery=yes
fi
])

if test $sv_cv_have_stack_overflow_recovery != no; then
  HAVE_STACK_OVERFLOW_RECOVERY=1
else
  HAVE_STACK_OVERFLOW_RECOVERY=0
fi
AC_SUBST(HAVE_STACK_OVERFLOW_RECOVERY)

if test $sv_cv_have_sigsegv_recovery = no \
   && test $sv_cv_have_stack_overflow_recovery = no; then
  CFG_HANDLER=handler-none.c
fi

AC_DEFINE_UNQUOTED(CFG_HEURISTICS, "$CFG_HEURISTICS",
  [The name of the include file describing the stack overflow detection heuristics.])
AC_DEFINE_UNQUOTED(CFG_SIGNALS, "$CFG_SIGNALS",
  [The name of the include file describing which signals should be trapped.])
AC_DEFINE_UNQUOTED(CFG_FAULT, "$CFG_FAULT",
  [The name of the include file describing the fault handler.])
AC_DEFINE_UNQUOTED(CFG_LEAVE, "$CFG_LEAVE",
  [The name of the file implementing sigsegv_reset_onstack_flag.])
AC_DEFINE_UNQUOTED(CFG_STACKVMA, "$CFG_STACKVMA",
  [The name of the file determining the stack virtual memory area.])
AC_DEFINE_UNQUOTED(CFG_HANDLER, "$CFG_HANDLER",
  [The name of the file implementing the handler functionality.])

AC_SUBST(CFG_HEURISTICS)
AC_SUBST(CFG_SIGNALS)
AC_SUBST(CFG_FAULT)
AC_SUBST(CFG_STACKVMA)
AC_SUBST(CFG_LEAVE)
AC_SUBST(CFG_HANDLER)
AC_SUBST(FAULT_CONTEXT)
AC_SUBST(FAULT_CONTEXT_INCLUDE)

{ echo; echo "${term_bold}Build Parameters:${term_norm}"; } >& AS_MESSAGE_FD

dnl Relocatability is a nop for this package.
AC_RELOCATABLE_NOP

{ echo; echo "${term_bold}Output Substitution:${term_norm}"; } >& AS_MESSAGE_FD

AC_OUTPUT([Makefile
           src/Makefile src/sigsegv.h
           tests/Makefile])

{ echo; echo "Now please type '${term_bold}make${term_norm}' to compile. Good luck."; echo; } >& AS_MESSAGE_FD
