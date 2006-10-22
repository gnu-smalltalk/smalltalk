/*  -*- Mode: C -*-  */

/* stream.c ---  customizable stream routines
 * Copyright (C) 1998, 1999, 2000, 2002, 2003 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1998
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

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef WITH_DMALLOC
#  include <dmalloc.h>
#endif

#include "compat.h"
#include "stream.h"
#include "mem.h"

struct stream
{
  snv_pointer stream;
  unsigned long limit;

  StreamGet get_func;
  StreamPut put_func;
};

static int
stream_not_readable (STREAM *stream)
{
  return -1;
}

static int
stream_not_writable (int ch, STREAM *stream)
{
  return -1;
}

/**
 * stream_new: constructor
 * @dets: user supplied stream details to be passed into the various funcs.
 * @limit: the maximum number of consecutive bytes to fit in @dets.
 * @get_func: function to get a character from @dets stream.
 * @put_func: function to put a character in @dets stream.
 * 
 * Allocate and initialize a new %STREAM data type.  The @get_func
 * and @put_func can be NULL if you intend to create a non-readable
 * or non-writable stream, respectively.
 * 
 * Return value:
 * The address of the newly allocated and initialised stream is returned.
 **/
STREAM *
stream_new (snv_pointer dets, unsigned long limit, StreamGet get_func, StreamPut put_func)
{
  STREAM *new = snv_new (STREAM, 1);

  new->stream = dets;
  new->limit = limit;

  new->get_func = get_func ? get_func : stream_not_readable;
  new->put_func = put_func ? put_func : stream_not_writable;

  return new;
}


/**
 * stream_delete: destructor
 * @stream: The stream pending deletion
 * 
 * The memory associated with @stream is recycled.

 * Return value:
 * The %dets supplied by the user when the stream was created are
 * returned for handling by the calling function.
 **/
snv_pointer
stream_delete (STREAM *stream)
{
  snv_pointer dets = stream->stream;
  snv_delete (stream);
  return dets;
}

/**
 * stream_details:
 * @stream: the stream being queried.
 *
 * The finalization function specified when @stream was created (if any)
 * is called, and then the memory associated with @stream is recycled.
 * It is the responsibility of the finalization function to recycle, or
 * otherwise manage, any memory associated with the user supplied %dets.
 * Return value:
 * This function returns the stream details associated with @stream
 * when it was originally created.
 **/
snv_pointer
stream_details (STREAM *stream)
{
  return stream ? stream->stream : NULL;
}

/**
 * stream_put:
 * @ch: A single character to be placed in @stream.
 * @stream: The stream to be written to.
 * 
 * This function will @ch in @stream if that stream's output limit will
 * not be exceeded.
 * 
 * Return value:
 * If @stream is full, return 1.  Otherwise, if any other error occurs,
 * that error code is returned unchanged.  This is of course dependant
 * on what the handler function uses to indicate an error.  If the stream
 * is not full and the stream's writing function succeeds, 1 (the number of
 * characters emitted!) is returned.
 **/
int
stream_put (int ch, STREAM *stream)
{
  int ch_or_errorcode;

  if (!stream)
    return -1;

  if (stream->limit < 1)
    return 1;

  stream->limit -= 1;
  ch_or_errorcode = (*stream->put_func) ((unsigned char) ch, stream);

  return (ch_or_errorcode < 0) ? ch_or_errorcode : 1;
}

/**
 * stream_puts:
 * @s: A string to be placed in @stream.
 * @stream: The stream to be written to.
 *
 * This function will @ch in @stream if that stream's output limit will
 * not be exceeded.
 *
 * Return value:
 * If any other error occurs, that error code is returned unchanged.
 * This is of course dependant on what the handler function uses to
 * indicate an error.  If the stream becomes full, the remaining
 * characters are not printed.  If the stream's writing function
 * always succeeds, the number of characters emitted or skipped is
 * returned.
 **/
int
stream_puts (char *s, STREAM *stream)
{
  int ch_or_errorcode;
  int num;

  if (!stream)
    return -1;

  for (num = 0; *s; num++, s++)
    {
      if (stream->limit < 1)
        return num + strlen (s);

      stream->limit -= 1;
      ch_or_errorcode = (*stream->put_func) ((unsigned char) *s, stream);

      if (ch_or_errorcode < 0)
	return ch_or_errorcode;
    }

  return num;
}

/**
 * stream_get:
 * @stream: The stream to be read from.
 * 
 * This function will try to read a single character from @stream.
 * 
 * Return value:
 * If an error occurs or the end of @stream is reached, -1 is returned.
 * Under normal circumstances the value if the character read (cast to
 * an int) is returned.
 **/
int
stream_get (STREAM *stream)
{
  return (*stream->get_func) (stream);
}

/* stream.c ends here */
