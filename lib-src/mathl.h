/******************************** -*- C -*- ****************************
 *
 *      Declarations for long double functions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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

#ifndef GST_MATHL_H
#define GST_MATHL_H

extern long double acosl(long double x);
extern long double asinl (long double x);
extern long double atanl (long double x);
extern long double ceill(long double x);
extern long double cosl(long double x);
extern long double expl (long double x);
extern long double floorl(long double x);
extern long double frexpl(long double x, int *exp);
extern long double ldexpl(long double x, int exp);
extern long double logl(long double x);
extern long double sinl (long double x);
extern long double sqrtl(long double x);
extern long double tanl (long double x);
extern long double truncl(long double x);

extern double trunc(double x);
extern float truncf(float x);

extern long lrintl(long double x);
extern long lrint(double x);
extern long lrintf(float x);

#endif
