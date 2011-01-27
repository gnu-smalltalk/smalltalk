"======================================================================
|
|   Test the security framework
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003, 2007, 2008  Free Software Foundation.
| Written by Paolo Bonzini
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

Object subclass: A_Super [
    | a |
    aSuper [ ^a ]
]

A_Super subclass: A [
    | a |
    <makeUntrusted: true>

    a: value [ a := value ]

    check [ ^thisContext isUntrusted ]

    check: aBlock [ ^aBlock value ]

    dirtyBlock [ ^[ a printString. thisContext isUntrusted ] ]

    cleanBlock [ ^[ thisContext isUntrusted ] ]
]

"Check that contexts are properly made untrusted -------------------------"

Eval [ A isUntrusted ]
Eval [ A new isUntrusted ]
Eval [ A new check ]
Eval [ A new check: [ thisContext isUntrusted ] ]
Eval [ A new check: [ A new check ] ]
Eval [ A new check: [ A new check: [ thisContext isUntrusted ] ] ]
Eval [ A new check: A new cleanBlock ]
Eval [ A new cleanBlock value ]
Eval [ A new check: A new dirtyBlock ]
Eval [ A new dirtyBlock value ]

"Make the current process untrusted... -----------------------------------"
Eval [
    Processor activeProcess makeUntrusted: true.
    thisContext isUntrusted
]

"...and check that subsequently created process are trusted."
Eval [ thisContext isUntrusted ]

"Make another process untrusted. -----------------------------------------"
Eval [
    | s result |
    s := Semaphore new.
    [ result := thisContext isUntrusted. s signal ] newProcess
        makeUntrusted: true;
        resume.

    s wait.
    ^result
]

"Check that access restrictions are enforced -----------------------------"

Eval [
    Processor activeProcess makeUntrusted: true.
    Set compile: 'lovelyMethod [ ^tally ]'.
    Set compile: 'dangerousMethod [ tally := 0 ]'.
    Set compile: 'lovelyMethod [ ^Array ]'.
    Set compile: 'dangerousMethod [ Array := 0 ]'
]

Eval [
    Processor activeProcess makeUntrusted: true.
    '!Set methodsFor: ''security checking''!

lovelyMethod
    ^tally!

dangerousMethod
    tally := 0!

lovelyMethod
    ^Array!

dangerousMethod
    Array := 0! !' readStream fileIn
]

Eval [
    '!Set methodsFor: ''security checking''!

lovelyTrustedMethod
    ^tally!

dangerousTrustedMethod
    tally := 0!

lovelyTrustedMethod
    ^Array!

dangerousTrustedMethod
    Array := 0! !' readStream fileIn
]

Set subclass: UntrustedSet [
    | a |
    <makeUntrusted: true>

    lovelyMethod [ ^tally ]
    dangerousMethod [ tally := 0 ]
    lovelyMethod [ ^Array ]
    dangerousMethod [ Array := 0 ]
    lovelyMethod [ ^a ]
    lovelyMethod [ a := 1 ]
]

"Check that subclasses are not fragile.  This has security implications
 as this test shows..."

Eval [ A new a: 5; aSuper ]

"Check that methods are properly made untrusted. -------------------------"

Eval [ (A >> #check:) isUntrusted ]
Eval [ (Set >> #lovelyMethod) isUntrusted ]
Eval [ (Set >> #lovelyTrustedMethod) isUntrusted ]
Eval [ (Set >> #dangerousTrustedMethod) isUntrusted ]

"Check that subclasses are properly made untrusted. ----------------------"

A subclass: B [
    | b |
]

Eval [ B isUntrusted ]

