#line 1 "./dl.in"
/*  -*- Mode: C -*-  */

/* ltdl.c --- dynamic loading header file for Snprintfv
 * Copyright (C) 2002 Gary V. Vaughan
 * Originally by Paolo Bonzini, 2002
 * This file is part of Snprintfv
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * As a special exception to the GNU General Public License, if you
 * distribute this file as part of a program that also links with and
 * uses the libopts library from AutoGen, you may include it under
 * the same distribution terms used by the libopts library.
 */

/* Code: */

/**
 * snv_load_all_modules:  
 *
 * Register the Snprintfv modules available in the %LTDL_LIBRARY_PATH
 *
 * Return value:
 * None, but exits with an error code of %EXIT_FAILURE if there
 * is an error.
 */
extern void snv_load_all_modules (void);


#line 31 "./dl.in"
