/***********************************************************************
 *
 *	Main Module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2004
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
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
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
