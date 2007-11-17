/* Fault handler information.  Woe32 version.
   Copyright (C) 1993-1999, 2002-2003, 2007  Bruno Haible <bruno@clisp.org>
   Copyright (C) 2003  Paolo Bonzini <bonzini@gnu.org>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include "sigsegv.h"

#define WIN32_LEAN_AND_MEAN /* avoid including junk */
#include <windows.h>
#include <winerror.h>
/*
 * extern LPTOP_LEVEL_EXCEPTION_FILTER SetUnhandledExceptionFilter (LPTOP_LEVEL_EXCEPTION_FILTER TopLevelExceptionFilter);
 * extern DWORD VirtualQuery (LPCVOID Address, PMEMORY_BASIC_INFORMATION Buffer, DWORD Length);
 * extern BOOL VirtualProtect (LPVOID Address, DWORD Size, DWORD NewProtect, PDWORD OldProtect);
 * extern DWORD GetLastError (void);
 */

/* User's SIGSEGV handler.  */
static sigsegv_handler_t user_handler = (sigsegv_handler_t) NULL;

/* Stack overflow handling is tricky:
   First, we must catch a STATUS_STACK_OVERFLOW exception. This is signalled
   when the guard page at the end of the stack has been touched. The operating
   system remaps the page with protection PAGE_READWRITE and only then calls
   our exception handler. Actually, it's even more complicated: The stack has
   the following layout:

           |                             |guard|----------stack-----------|

   and when the guard page is touched, the system maps it PAGE_READWRITE and
   allocates a new guard page below it:

           |                       |guard|-------------stack--------------|

   Only when no new guard page can be allocated (because the maximum stack
   size has been reached), will we see an exception.

           |guard|-------------------------stack--------------------------|

   Second, we must reinstall the guard page. Otherwise, on the next stack
   overflow, the application will simply crash (on WinNT: silently, on Win95:
   with an error message box and freezing the system).
   But since we don't know where %esp points to during the exception handling,
   we must first leave the exception handler, before we can restore the guard
   page. And %esp must be made to point to a reasonable value before we do
   this.

   Note: On WinNT, the guard page has protection PAGE_READWRITE|PAGE_GUARD.
   On Win95, which doesn't know PAGE_GUARD, it has protection PAGE_NOACCESS.
 */

static stackoverflow_handler_t stk_user_handler =
  (stackoverflow_handler_t) NULL;
static unsigned long stk_extra_stack;
static unsigned long stk_extra_stack_size;

static void
stack_overflow_handler (unsigned long faulting_page_address, stackoverflow_context_t context)
{
  MEMORY_BASIC_INFORMATION info;
  DWORD oldprot;
  unsigned long base;
  unsigned long address;

  /* First get stack's base address.  */
  if (VirtualQuery ((void*) faulting_page_address, &info, sizeof (info))
      != sizeof (info))
    goto failed;
  base = (unsigned long) info.AllocationBase;

  /* Now search for the first existing page.  */
  address = base;
  for (;;)
    {
      if (VirtualQuery ((void*) address, &info, sizeof (info)) != sizeof (info))
        goto failed;
      if (address != (unsigned long) info.BaseAddress)
       goto failed;
      if (info.State != MEM_FREE)
        {
          if ((unsigned long) info.AllocationBase != base)
            goto failed;
          if (info.State == MEM_COMMIT)
            break;
        }
      address = (unsigned long) info.BaseAddress + info.RegionSize;
    }

  /* Now add the PAGE_GUARD bit to the first existing page.  */
  /* On WinNT this works...  */
  if (VirtualProtect (info.BaseAddress, 0x1000, info.Protect | PAGE_GUARD,
                      &oldprot))
    goto ok;
  if (GetLastError () == ERROR_INVALID_PARAMETER)
    /* ... but on Win95 we need this:  */
    if (VirtualProtect (info.BaseAddress, 0x1000, PAGE_NOACCESS, &oldprot))
      goto ok;
 failed:
  for (;;)
    (*stk_user_handler) (1, context);
 ok:
  for (;;)
    (*stk_user_handler) (0, context);
}

/* This is the stack overflow and page fault handler.  */
static LONG WINAPI
main_exception_filter (EXCEPTION_POINTERS *ExceptionInfo)
{
  if ((stk_user_handler
       && ExceptionInfo->ExceptionRecord->ExceptionCode == STATUS_STACK_OVERFLOW
      )
      ||
      (user_handler != (sigsegv_handler_t)NULL
       && ExceptionInfo->ExceptionRecord->ExceptionCode == EXCEPTION_ACCESS_VIOLATION
     ))
    {
#if 0 /* for debugging only */
      printf ("Exception!\n");
      printf ("Code = 0x%x\n",
              ExceptionInfo->ExceptionRecord->ExceptionCode);
      printf ("Flags = 0x%x\n",
              ExceptionInfo->ExceptionRecord->ExceptionFlags);
      printf ("Address = 0x%x\n",
              ExceptionInfo->ExceptionRecord->ExceptionAddress);
      printf ("Params:");
      {
        DWORD i;
        for (i = 0; i < ExceptionInfo->ExceptionRecord->NumberParameters; i++)
          printf (" 0x%x,",
                  ExceptionInfo->ExceptionRecord->ExceptionInformation[i]);
      }
      printf ("\n");
      printf ("Registers:\n");
      printf ("eip = 0x%x\n", ExceptionInfo->ContextRecord->Eip);
      printf ("eax = 0x%x, ", ExceptionInfo->ContextRecord->Eax);
      printf ("ebx = 0x%x, ", ExceptionInfo->ContextRecord->Ebx);
      printf ("ecx = 0x%x, ", ExceptionInfo->ContextRecord->Ecx);
      printf ("edx = 0x%x\n", ExceptionInfo->ContextRecord->Edx);
      printf ("esi = 0x%x, ", ExceptionInfo->ContextRecord->Esi);
      printf ("edi = 0x%x, ", ExceptionInfo->ContextRecord->Edi);
      printf ("ebp = 0x%x, ", ExceptionInfo->ContextRecord->Ebp);
      printf ("esp = 0x%x\n", ExceptionInfo->ContextRecord->Esp);
#endif
      if (ExceptionInfo->ExceptionRecord->NumberParameters == 2)
        {
          if (stk_user_handler
              && ExceptionInfo->ExceptionRecord->ExceptionCode == STATUS_STACK_OVERFLOW)
            {
              char *address = (char *) ExceptionInfo->ExceptionRecord->ExceptionInformation[1];
              /* Restart the program, giving it a sane value for %esp.
                 At the same time, copy the contents of
                 ExceptionInfo->ContextRecord (which, on Windows XP, happens
                 to be allocated in the guard page, where it will be
                 inaccessible as soon as we restore the PAGE_GUARD bit!) to
                 this new stack.  */
              unsigned long faulting_page_address = (unsigned long)address & -0x1000;
              unsigned long new_safe_esp = ((stk_extra_stack + stk_extra_stack_size) & -16);
              CONTEXT *orig_context = ExceptionInfo->ContextRecord;
              CONTEXT *safe_context = (CONTEXT *) (new_safe_esp -= sizeof (CONTEXT)); /* make room */
              memcpy (safe_context, orig_context, sizeof (CONTEXT));
              new_safe_esp -= 8; /* make room for arguments */
              new_safe_esp &= -16; /* align */
              new_safe_esp -= 4; /* make room for (unused) return address slot */
              ExceptionInfo->ContextRecord->Esp = new_safe_esp;
              /* Call stack_overflow_handler(faulting_page_address,safe_context).  */
              ExceptionInfo->ContextRecord->Eip = (unsigned long)&stack_overflow_handler;
              *(unsigned long *)(new_safe_esp + 4) = faulting_page_address;
              *(unsigned long *)(new_safe_esp + 8) = (unsigned long) safe_context;
              return EXCEPTION_CONTINUE_EXECUTION;
            }
          if (user_handler != (sigsegv_handler_t) NULL
              && ExceptionInfo->ExceptionRecord->ExceptionCode == EXCEPTION_ACCESS_VIOLATION)
            {
              /* ExceptionInfo->ExceptionRecord->ExceptionInformation[0] is 1
                 if it's a write access, 0 if it's a read access. But we don't
                 need this info because we don't have it on Unix either.  */
              void *address = (void *) ExceptionInfo->ExceptionRecord->ExceptionInformation[1];
              if ((*user_handler) (address, 1))
                return EXCEPTION_CONTINUE_EXECUTION;
            }
        }
    }
  return EXCEPTION_CONTINUE_SEARCH;
}

#if defined __CYGWIN__ && defined __i386__

/* In Cygwin programs, SetUnhandledExceptionFilter has no effect because Cygwin
   installs a global exception handler.  We have to dig deep in order to install
   our main_exception_filter.  */

/* Data structures for the current thread's exception handler chain.
   On the x86 Windows uses register fs, offset 0 to point to the current
   exception handler; Cygwin mucks with it, so we must do the same... :-/ */

/* Magic taken from winsup/cygwin/include/exceptions.h.  */

struct exception_list
  {
    struct exception_list *prev;
    int (*handler) (EXCEPTION_RECORD *, void *, CONTEXT *, void *);
  };
typedef struct exception_list exception_list;

/* Magic taken from winsup/cygwin/exceptions.cc.  */

__asm__ (".equ __except_list,0");

extern exception_list *_except_list __asm__ ("%fs:__except_list");

/* For debugging.  _except_list is not otherwise accessible from gdb.  */
static exception_list *
debug_get_except_list ()
{
  return _except_list;
}

/* Cygwin's original exception handler.  */
static int (*cygwin_exception_handler) (EXCEPTION_RECORD *, void *, CONTEXT *, void *);

/* Our exception handler.  */
static int
libsigsegv_exception_handler (EXCEPTION_RECORD *exception, void *frame, CONTEXT *context, void *dispatch)
{
  EXCEPTION_POINTERS ExceptionInfo;
  ExceptionInfo.ExceptionRecord = exception;
  ExceptionInfo.ContextRecord = context;
  if (main_exception_filter (&ExceptionInfo) == EXCEPTION_CONTINUE_SEARCH)
    return cygwin_exception_handler (exception, frame, context, dispatch);
  else
    return 0;
}

static void
do_install_main_exception_filter ()
{
  /* We cannot insert any handler into the chain, because such handlers
     must lie on the stack (?).  Instead, we have to replace(!) Cygwin's
     global exception handler.  */
  cygwin_exception_handler = _except_list->handler;
  _except_list->handler = libsigsegv_exception_handler;
}

#else

static void
do_install_main_exception_filter ()
{
  SetUnhandledExceptionFilter ((LPTOP_LEVEL_EXCEPTION_FILTER) &main_exception_filter);
}

#endif

static void
install_main_exception_filter ()
{
  static int main_exception_filter_installed = 0;

  if (!main_exception_filter_installed)
    {
      do_install_main_exception_filter ();
      main_exception_filter_installed = 1;
    }
}

int
sigsegv_install_handler (sigsegv_handler_t handler)
{
  user_handler = handler;
  install_main_exception_filter ();
  return 0;
}

void
sigsegv_deinstall_handler (void)
{
  user_handler = (sigsegv_handler_t) NULL;
}

void
sigsegv_leave_handler (void)
{
}

int
stackoverflow_install_handler (stackoverflow_handler_t handler,
                               void *extra_stack, unsigned long extra_stack_size)
{
  stk_user_handler = handler;
  stk_extra_stack = (unsigned long) extra_stack;
  stk_extra_stack_size = extra_stack_size;
  install_main_exception_filter ();
  return 0;
}

void
stackoverflow_deinstall_handler (void)
{
  stk_user_handler = (stackoverflow_handler_t) NULL;
}
