#line 1 "../../../snprintfv/snprintfv/stream.in"
/*  -*- Mode: C -*-  */

/* stream.h --- customizable stream routines
 * Copyright (C) 1998, 1999, 2000, 2002 Gary V. Vaughan
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

#ifndef STREAM_H
#define STREAM_H 1

#define STREAM_READABLE		(1 << 0)
#define STREAM_WRITABLE		(1 << 1)

/**
 * SNV_UNLIMITED:
 * Used to denote that there is no upper limit to the number of characters
 * that can safely be written to a stream.
 **/
#define SNV_UNLIMITED           ~(0L)

#ifdef __cplusplus
extern "C"
{
#if 0
/* This brace is so that emacs can still indent properly: */ }
#endif
#endif				/* __cplusplus */

/**
 * STREAM:
 * Data type used to pass details of streams between functions,
 * much like stdio's %FILE, but more flexible.  A %STREAM can be uni- or
 * bi-directional depending on how it is initialised.
 **/
typedef struct stream STREAM;

/**
 * StreamPut:
 * @ch: The character to write to @stream cast to an int.
 * @stream:  The stream being written to.
 *
 * Type of the function to put a character in a writeable stream.
 *
 * Return value:
 * The function should return the character written to the
 * stream, cast to an int if it was written successfully, or
 * else %EOF, if the write failed.
 **/
typedef int (*StreamPut) (int ch, STREAM * stream);

/**
 * StreamGet:
 * @stream:  The stream being read from.
 *
 * Type of the function to get a character from a readable stream.
 *
 * Return value:
 * The function should return the character read from the
 * stream, cast to an int if it was read successfully, or
 * else %EOF, if the read failed.
 **/
typedef int (*StreamGet) (STREAM * stream);


/**
 * stream_new:  constructor 
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
extern STREAM * stream_new (snv_pointer dets, unsigned long limit, StreamGet get_func, StreamPut put_func);


/**
 * stream_delete:  destructor 
 * @stream: The stream pending deletion
 * 
 * The memory associated with @stream is recycled.
 * Return value:
 * The %dets supplied by the user when the stream was created are
 * returned for handling by the calling function.
 **/
extern snv_pointer stream_delete (STREAM *stream);


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
extern snv_pointer stream_details (STREAM *stream);


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
extern int stream_put (int ch, STREAM *stream);


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
extern int stream_puts (char *s, STREAM *stream);


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
extern int stream_get (STREAM *stream);


#line 88 "../../../snprintfv/snprintfv/stream.in"
#ifdef __cplusplus
#if 0
/* This brace is so that emacs can still indent properly: */
{
#endif
}
#endif /* __cplusplus */

#endif /* STREAM_H */
