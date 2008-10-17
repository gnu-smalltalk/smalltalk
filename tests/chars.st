"======================================================================
|
|   Test the character (of the) system
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2006, 2007, 2008  Free Software Foundation.
| Written by Steve Byrne
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

Eval [ $A ]

Eval [ $b ]

Eval [ $$ ]

Eval [ $!  ]

Eval [ $  ]

Eval [
    a := 0 to: 255.
    b := a collect: [ :each | each asCharacter ].
    c := b collect: [ :each | each asInteger ].

    c = a asArray
]


Eval [
    allChars := (0 to: 127) asByteArray asString.

    ^(0 to: 127) allSatisfy: [ :index |
        (allChars at: index + 1) == index asCharacter ]
]


Eval [
    allChars := (0 to: 255) asByteArray asString.

    #(#isVowel #isLetter #isUppercase #isLowercase #isAlphaNumeric
      #isDigit #isSeparator)
        do: [ :symbol |
            symbol printNl.
    
            which := allChars collect: [ :each | 
                (each perform: symbol) ifTrue: [ $x ] ifFalse: [ $_ ]
	    ].
    
            Transcript showCr: (which copyFrom: 1 to: 64).
            Transcript showCr: (which copyFrom: 65 to: 128).
            Transcript showCr: (which copyFrom: 129 to: 192).
            Transcript showCr: (which copyFrom: 193 to: 256).
            Transcript nl.
        ]
]

Eval [
    printable := (33 to: 126) asByteArray asString.
    
    #(#asUppercase #asLowercase)
        do: [ :symbol |
            symbol printNl.
    
            which := printable collect: [ :each | (each perform: symbol) ].
    
            Transcript showCr: (which copyFrom: 1 to: 47).
            Transcript showCr: (which copyFrom: 48 to: 94).
            Transcript nl.
        ]
]
