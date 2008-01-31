"======================================================================
|
|   C preprocessor string literal unquoter layer 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
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

StreamWrapper subclass: #StringUnquoteStream
	       instanceVariableNames: ''
	       classVariableNames: ''
	       poolDictionaries: ''
	       category: nil
!

StringUnquoteStream comment:
'I process a sequence of tokens, looking for strings or character literals.
When I find them, I scan them for any occurance of quoted characters, and
remove the quoting character, converting any special characters (such as
"\n") into their internal representation.  I yield a stream of tokens where
strings and chars are "fixed"'!


!StringUnquoteStream methodsFor: 'accessing'!

next
    | result nextTok |
    result _ super next.
    ((result isKindOf: CStringToken) or: 
	 [ result isKindOf: CCharacterToken ])
	ifTrue: [ ^self processQuotedChars: result ]
	ifFalse: [ ^result ]     
! !


!StringUnquoteStream methodsFor: 'private'!

processQuotedChars: aLiteral
    "Note that characters are also represented as strings"
    | string changed rStream wStream ch |
    string _ aLiteral value.
    changed _ false.
    rStream _ ReadStream on: string.
    wStream _ WriteStream on: (String new: string size).
    [ rStream atEnd ]
	whileFalse: [ ch _ rStream next.
		      ch == $\
			  ifTrue: [ changed _ true.
				    ch _ self parseEscapedChar: rStream. ].
		      wStream nextPut: ch. ].
    changed 
	ifTrue: [ ^(aLiteral class) value: wStream contents ]
	ifFalse: [ ^aLiteral ]
!

parseEscapedChar: aStream
    "called right after \ in a string or a character literal"
    | ch num count | 
    ch _ aStream next.
    ch == $b ifTrue: [ ^Character value: 8 ].
    ch == $n ifTrue: [ ^Character value: 10 ].
    ch == $r ifTrue: [ ^Character value: 13 ].
    ch == $f ifTrue: [ ^Character value: 12 ].
    ch == $t ifTrue: [ ^Character value: 9 ].
    ch == $v ifTrue: [ ^Character value: 11 ].
    " this should probably go away "
    ch == (Character nl) ifTrue: 
	[ ch _ aStream next.
	  ch == $\
	      ifTrue: [ ^self parseEscapedChar: aStream ]
	      ifFalse: [ ^ch ]
	      ].
    ch == $\ ifTrue: [ ^$\ ].
    ch == $' ifTrue: [ ^$' ].
    ch == $" ifTrue: [ ^$" ].
    ch == $x ifTrue: [ "have \xhhh"
		       ch _ aStream next.
		       num _ 0.	
		       count _ 0.
		       [ (self isDigit: ch base: 16) and:
			     [ count < 3 ] 
			   ] whileTrue:
			   [ num _ num * 16 + ch digitValue.
			     aStream next. 
			     ch _ aStream peek.
			     count _ count + 1
			     ].
		       ^Character value: num ].
    (self isDigit: ch base: 8)
	ifTrue: [ "have \ooo"
		  num _ 0.	
		  count _ 0.
		  [ (self isDigit: ch base: 8) and:
			[ count < 3 ] 
			] whileTrue:
			    [ num _ num * 8 + ch digitValue.
			      aStream next. 
			      ch _ aStream peek.
			      count _ count + 1 ].
		  ^Character value: num ].
    self error: 'Illegal quoted character'
! !
