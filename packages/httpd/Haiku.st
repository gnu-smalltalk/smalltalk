ErrorResponse class extend [

    haikuErrorMessages: aBoolean [
	<category: 'haiku'>
	aBoolean ifFalse: [self initialize] ifTrue: [self initialize: self haiku]
    ]

    haiku [
	<category: 'haiku'>
	^#(#(404 'Not found' '<P><BLOCKQUOTE><I>Rather than a beep<BR>
Or a rude error message,<BR>
These words: "File not found."</I></BLOCKQUOTE></P>

<P>The requested URL was not found on this server.</P>') #(410 'Gone' '<P><BLOCKQUOTE><I>You step in the stream,<BR>
but the water has moved on.<BR>
This page is not here.</I></BLOCKQUOTE></P>

<P>The requested resource is no longer available at the server and no
forwarding address is known. This condition should be considered
permanent.</P>') #(414 'Request-URI Too Long' '<P><BLOCKQUOTE><I>Out of memory.<BR>
We wish to hold the whole sky,<BR>
But we never will.</I></BLOCKQUOTE></P>

<P>The server is refusing to service the request because the requested
URL is longer than the server is willing to interpret. This condition
is most likely due to a client''s improper conversion of a POST request
with long query information to a GET request.</P>') #(503 'Service unavailable' '<P><BLOCKQUOTE><I>Stay the patient course<BR>
Of little worth is your ire<BR>
The network is down.</I></BLOCKQUOTE></P>

<P>The server is currently unable to handle the request due to a
temporary overloading or maintenance of the server. This is a temporary
condition.</P>'))
    ]

]



Eval [
    ErrorResponse haikuErrorMessages: true
]

