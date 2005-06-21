"======================================================================
|
|   Test the security framework
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003  Free Software Foundation.
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

Object subclass: #A_Super
        instanceVariableNames: 'a'
        classVariableNames: ''
        poolDictionaries: ''
        category: ''!

A_Super subclass: #A
        instanceVariableNames: 'a'
        classVariableNames: ''
        poolDictionaries: ''
        category: ''!

A makeUntrusted: true!

!A_Super methodsFor: 'checking'!

aSuper
    ^a
! !

!A methodsFor: 'checking'!

a: value
    a := value
!

check
    ^thisContext isUntrusted
!

check: aBlock
    ^aBlock value
!

dirtyBlock
    ^[ a printString. thisContext isUntrusted ]
!

cleanBlock
    ^[ thisContext isUntrusted ]
! !

"Check that contexts are properly made untrusted -------------------------"

^A isUntrusted!
^A new isUntrusted!
^A new check!
^A new check: [ thisContext isUntrusted ]!
^A new check: [ A new check ]!
^A new check: [ A new check: [ thisContext isUntrusted ] ]!
^A new check: A new cleanBlock!
^A new cleanBlock value!
^A new check: A new dirtyBlock!
^A new dirtyBlock value!

"Make the current process untrusted... -----------------------------------"
Processor activeProcess makeUntrusted: true.
^thisContext isUntrusted!

"...and check that subsequently created process are trusted."
^thisContext isUntrusted!

"Make another process untrusted. -----------------------------------------"
| s result |
s := Semaphore new.
[ result := thisContext isUntrusted. s signal ] newProcess
    makeUntrusted: true;
    resume.

s wait.
^result!

"Check that access restrictions are enforced -----------------------------"

Processor activeProcess makeUntrusted: true.
Set compile: 'lovelyMethod ^tally'.
Set compile: 'dangerousMethod tally := 0'.
Set compile: 'lovelyMethod ^Array'.
Set compile: 'dangerousMethod Array := 0'!

!Processor activeProcess makeUntrusted: true.
Set methodsFor: 'security checking'!

lovelyMethod
    ^tally!

dangerousMethod
    tally := 0!

lovelyMethod
    ^Array!

dangerousMethod
    Array := 0! !

!Set methodsFor: 'security checking'!

lovelyTrustedMethod
    ^tally!

dangerousTrustedMethod
    tally := 0!

lovelyTrustedMethod
    ^Array!

dangerousTrustedMethod
    Array := 0! !

Set subclass: #UntrustedSet
        instanceVariableNames: 'a'
        classVariableNames: ''
        poolDictionaries: ''
        category: ''!

UntrustedSet makeUntrusted: true!

!UntrustedSet methodsFor: 'security checking'!

lovelyMethod
    ^tally!

dangerousMethod
    tally := 0!

lovelyMethod
    ^Array!

dangerousMethod
    Array := 0!

lovelyMethod
    ^a!

lovelyMethod
    a := 1! !

"Check that subclasses are not fragile.  This has security implications
 as this test shows..."

^A new a: 5; aSuper!

"Check that methods are properly made untrusted. -------------------------"

^(A >> #check:) isUntrusted!
^(Set >> #lovelyMethod) isUntrusted!
^(Set >> #lovelyTrustedMethod) isUntrusted!
^(Set >> #dangerousTrustedMethod) isUntrusted!

"Check that subclasses are properly made untrusted. ----------------------"

A subclass: #B
        instanceVariableNames: 'b'
        classVariableNames: ''
        poolDictionaries: ''
        category: ''!

^B isUntrusted!

