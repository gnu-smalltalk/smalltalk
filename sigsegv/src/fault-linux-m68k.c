/* Fault handler information subroutine.  Linux/m68k version.
 * Taken from gcc-3.2/boehm-gc/os_dep.c.
 *
 * Copyright 1988, 1989 Hans-J. Boehm, Alan J. Demers
 * Copyright (c) 1991-1995 by Xerox Corporation.  All rights reserved.
 * Copyright (c) 1996-1999 by Silicon Graphics.  All rights reserved.
 * Copyright (c) 1999 by Hewlett-Packard Company.  All rights reserved.
 *
 * THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
 * OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
 *
 * Permission is hereby granted to use or copy this program
 * for any purpose,  provided the above notices are retained on all copies.
 * Permission to modify the code and to distribute modified code is granted,
 * provided the above notices are retained, and a notice that the code was
 * modified is included with the above copyright notice.
 */

static void *
get_fault_addr (struct sigcontext *scp)
{
  int format = (scp->sc_formatvec >> 12) & 0xf;
  unsigned long *framedata = (unsigned long *) (scp + 1);
  unsigned long ea;

  switch (format)
    {
    case 10: case 11: /* 68020/030 */
      ea = framedata[2];
      return (void *) ea;
    case 7: /* 68040 */
      ea = framedata[3];
      break;
    case 4: /* 68060 */
      ea = framedata[0];
      break;
    default:
      return (void *) 0;
    }
  if (framedata[1] & 0x08000000)
    /* Correct addr on misaligned access.  */
    ea = (ea + 4095) & ~4095;
  return (void *) ea;
}
