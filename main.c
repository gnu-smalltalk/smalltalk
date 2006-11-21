/***********************************************************************
 *
 *	Main Module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2004,2006
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gstpub.h"

#if STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

#ifdef ENABLE_DISASSEMBLER
#define TRUE_FALSE_ALREADY_DEFINED
#include "dis-asm.h"
#endif

int
main(int argc, const char **argv)
{
  int result;
  gst_smalltalk_args(argc, argv);
  result = gst_init_smalltalk();
  if (result == 0)
    gst_top_level_loop();

  exit(result <= 0 ? 0 : result);
}

#ifdef ENABLE_DISASSEMBLER
void disassemble(stream, from, to)
     FILE *stream;
     char *from, *to;
{
  disassemble_info info;
  bfd_vma pc = (bfd_vma) from;
  bfd_vma end = (bfd_vma) to;

  INIT_DISASSEMBLE_INFO(info, stream, fprintf);
  info.buffer = NULL;
  info.buffer_vma = 0;
  info.buffer_length = end;

  while (pc < end) {
    fprintf_vma(stream, pc);
    putc('\t', stream);
#ifdef __i386__
    pc += print_insn_i386(pc, &info);
#endif
#ifdef __ppc__
    pc += print_insn_big_powerpc(pc, &info);
#endif
#ifdef __sparc__
    pc += print_insn_sparc(pc, &info);
#endif
    putc('\n', stream);
  }
}
#endif
