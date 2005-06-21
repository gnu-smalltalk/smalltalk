"======================================================================
|
|   Maps a stream of lines into a stream of whitespace collapsed tokens
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
| Written by Steve Byrne.
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
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

"
|     Change Log
| ============================================================================
| Author       Date       Change 
| sbb	     25 Aug 94	  Prepared for release.
|
"


PushBackStream subclass: #CollapsedStream
       instanceVariableNames: 'lineStream'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CollapsedStream class methodsFor: 'instance creation'!

"inherit PushBackStream>>on: "
!


!CollapsedStream methodsFor: 'accessing'!

next
    | token | 
    queue size > 0
	ifTrue: [ ^queue removeFirst ].
    
    self atEnd
	ifTrue: [ '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& reached end' printNl. ^nil ].

    token _ self nextToken.
    (token isMemberOf: WhitespaceTok) 
	ifTrue: 
	    [ "collapse blank lines and adjacent whitespace into a single
	       whitespace"
	     [ lineStream atEnd not
		   and: [ token _ self nextToken.
			  token isMemberOf: WhitespaceTok ] ] whileTrue: [ ].
	     self putBack: token.
	     ^WhitespaceTok new.
	     ].
    ^token
!

nextBypass
    | token | 
    queue size > 0
	ifTrue: [ ^queue removeFirst ].
    
    token _ self nextToken.
    (token isMemberOf: WhitespaceTok) 
	ifTrue: 
	    [ "collapse blank lines and adjacent whitespace into a single
	       whitespace"
	     [ token _ self nextToken.
	       token isMemberOf: WhitespaceTok ] whileTrue: [ ].
	     self putBack: token.
	     ^WhitespaceTok new.
	     ].
    ^token
!

atEnd
    (queue size > 0) 
	ifTrue: [ ^false ].

    lineStream isNil
	ifTrue: [ stream atEnd
		      ifTrue: [ ^true ].
		  lineStream _ ReadStream on: stream next ].
    ^lineStream atEnd and: [ stream atEnd ]
! 

atRealEnd
    (queue size > 0)
	ifTrue: [ ^false ].
    
    (lineStream isNil or: [ lineStream atEnd ])
	ifTrue: [ stream atEnd
		      ifTrue: [ ^true ]. ].
    ^false
!

close
    "do nothing"
    ^self
! !


!CollapsedStream methodsFor: 'private'!

		 
nextToken
    | line wasAtEnd|
    (lineStream isNil or: [ lineStream atEnd ])
	  ifTrue: [ wasAtEnd _ lineStream notNil.
		    line _ stream next.
		    lineStream _ ReadStream on: line.
		    wasAtEnd ifTrue: [ "Synthesize a white token" 
				       ^WhitespaceTok new ].
		    ].
    
    ^lineStream next
! !
