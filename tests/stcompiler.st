"======================================================================
|
|   Regression tests for the STInST compiler
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1999, 200, 2001, 2002, 2011 Free Software Foundation.
| Written by Paolo Bonzini and Holger Hans Peter Freyther.
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


Eval [
    "This is testing bug: http://smalltalk.gnu.org/project/issue/527"
    PackageLoader fileInPackage: 'Compiler'.
    Behavior evaluate: '3'.
]

Eval [
    "Random code to test features of the parser"
    PackageLoader fileInPackage: #Compiler.

    STInST.STEvaluationDriver new parseSmalltalk: '
   | i |
   i := ##(| a | a := -2. ''before everything'' printNl. a).
   [ i < 5 ] whileTrue:  [ i printNl. i := i + 1 ].
   [ i = (900 // 100) ] whileFalse: [ i printNl. i := i + 1 ].
   i even ifTrue: [ i printNl ].
   i odd ifFalse: [ i printNl ].
   (i even or: [i odd])  ifTrue: [ ''okay'' printNl] ifFalse: [ ''huh?!?'' printNl ].
   (i even and: [i odd]) ifFalse: [ ''okay'' printNl] ifTrue: [ ''huh?!?'' printNl ].
   Transcript
       nextPutAll: ''now I''''m testing '';
       print: ''Cascading'';
       nl.

   #(true false nil 53 $a [1 2 3] (1 2 3)
     #{Smalltalk.Association} #perform: #''perform:with:'' ''
Arrays... and multi-line strings'') printNl.

   #(''and now'' '' blocks with parameters...'') do: [ :each |
       Transcript nextPutAll: each ].

   [ :a :b :c | | temp |
       temp := Smalltalk::Transcript.
       temp
	   nl;
	   print: (i = 9 ifTrue: [ ''okay'' ] ifFalse: [ ''huh?!?'' ]);
	   nl;
	   print: thisContext;
	   nl; nextPutAll: a;
	   nl; nextPutAll: b;
	   nl; nextPutAll: c;
	   nl
   ]
       value: ''finally, many parameters, ''
       value: ''cascading ''
       value: ''and block temporaries too! ''.
!' with: STInST.STFileInParser.
]

Eval [
    | squeak |
    "Test the import of squeak code"

    squeak := '!String methodsFor: ''*petitparser-core-converting'' stamp: ''lr 11/7/2009 13:32''!
asParser
    ^ PPLiteralSequenceParser on: self! !'.

    STInST.STClassLoader new parseSmalltalkStream: squeak readStream
		    with: STInST.SqueakFileInParser.
]

