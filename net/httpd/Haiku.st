"======================================================================
|
|   Haiku error messages for web server
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001 Free Software Foundation, Inc.
| Written by Paolo Bonzini.  The jokes in this file were obtained from
| the FSF's email archives of the GNU Project.  The Free Software
| Foundation claims no copyrights on these jokes.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
|
 ======================================================================"

!ErrorResponse class methodsFor: 'haiku'!

haikuErrorMessages: aBoolean
    aBoolean
	ifFalse: [ self initialize ]
	ifTrue: [ self initialize: self haiku ]!

haiku
    ^#(	(404 'Not found'

'<P><BLOCKQUOTE><I>Rather than a beep<BR>
Or a rude error message,<BR>
These words: "File not found."</I></BLOCKQUOTE></P>

<P>The requested URL was not found on this server.</P>')

	(410 'Gone'
	
'<P><BLOCKQUOTE><I>You step in the stream,<BR>
but the water has moved on.<BR>
This page is not here.</I></BLOCKQUOTE></P>

<P>The requested resource is no longer available at the server and no
forwarding address is known. This condition should be considered
permanent.</P>')

	(414 'Request-URI Too Long'

'<P><BLOCKQUOTE><I>Out of memory.<BR>
We wish to hold the whole sky,<BR>
But we never will.</I></BLOCKQUOTE></P>

<P>The server is refusing to service the request because the requested
URL is longer than the server is willing to interpret. This condition
is most likely due to a client''s improper conversion of a POST request
with long query information to a GET request.</P>')

	(503 'Service unavailable'

'<P><BLOCKQUOTE><I>Stay the patient course<BR>
Of little worth is your ire<BR>
The network is down.</I></BLOCKQUOTE></P>

<P>The server is currently unable to handle the request due to a
temporary overloading or maintenance of the server. This is a temporary
condition.</P>'))! !

ErrorResponse haikuErrorMessages: true!


"-------------------------------------------------------------------------
  From http://www.gnu.org/fun/jokes/error-haiku.html:

	With searching comes loss		A file that big?
	and the presence of absence:		It might be very useful.
	That file is gone.			But now it is gone.
	- - - - - - - - - - - -			- - - - - - - - - - - -
	Three things are certain:		The Tao that is seen
	Death, taxes, and lost data.		Is not the true Tao, until
	Guess which has occurred.		You bring fresh toner.
	- - - - - - - - - - - -			- - - - - - - - - - - -
	Having been erased,			The Web site you seek
	The document you're seeking		cannot be located but
	Must now be retyped.			endless others exist
	- - - - - - - - - - - -			- - - - - - - - - - - -
	Chaos reigns within.			ABORTED effort:
	Reflect, repent, and reboot.		Close all that you have.
	Order shall return.			You ask way too much.
	- - - - - - - - - - - -			- - - - - - - - - - - -
	Error messages
	cannot completely convey.
	We now know shared loss.

  Credits and more haiku error messages can be found at
  http://www.salon.com/21st/chal/1998/02/10chal2.html
 -------------------------------------------------------------------------"
