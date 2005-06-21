/*  -*- Mode: C -*-  */

/* mem.h --- memory handling macros
 * Copyright (C) 1999 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1999
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

#ifndef SNPRINTFV_MEM_H
#define SNPRINTFV_MEM_H 1

#include <snprintfv/compat.h>

#ifdef WITH_DMALLOC
#  include <dmalloc.h>
#endif

/* This is the API we use throughout libsnprintfv. */
#define snv_new(type, count)		\
		((type*)snv_malloc((size_t)sizeof(type) * (count)))
#define snv_renew(type, ptr, count)	\
    		((type*)snv_xrealloc((ptr), (size_t)sizeof(type) * (count)))
#define snv_delete(old)	snv_free(old)

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/* These function pointers are exposed through the API incase a user
   of this library needs to map our memory management routines to
   their own (e.g. xmalloc). */

/**
 * snv_malloc:
 * @count: The number of bytes to allocate.
 *
 * Allocates a fresh block of memory whose size is @count bytes.
 *
 * Return value:
 * The pointer to the newly-allocated memory area.
 */
SNV_SCOPE snv_pointer (*snv_malloc) (size_t count);

/**
 * snv_realloc:
 * @old: The pointer to the block whose size must be changed.
 * @count: The number of bytes to allocate.
 *
 * Reallocates a fresh block of memory pointed to by @old
 * so that its size becomes @count bytes.
 *
 * Return value:
 * The pointer to the newly-allocated memory area, possibly
 * the same as @old.
 */
SNV_SCOPE snv_pointer (*snv_realloc) (snv_pointer old, size_t count);

/**
 * snv_free:
 * @old: The pointer to the block that must freed.
 *
 * Frees a block of memory pointed to by @old.
 */
SNV_SCOPE void (*snv_free) (snv_pointer old);

/* And these are reimplemented tout court because they are
   not fully portable.  */
extern snv_pointer snv_xrealloc (snv_pointer old, size_t count);
extern char* snv_strdup (const char *str);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* SNPRINTFV_MEM_H */

/* mem.h ends here */
