#! @bindir@/gst -f

"======================================================================
|
|   Smalltalk SUnit runner (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

(Smalltalk includesKey: #TestSuitesScripter)
    ifFalse: [
	Transcript show: 'SUnit not loaded.'; nl.
	ObjectMemory quit: 1 ]!

| suite script result |
Smalltalk arguments isEmpty ifTrue: [ ^self ].
script := Smalltalk arguments fold: [ :a :b | a, ' ', b ].
suite := TestSuitesScripter run: script.
result := suite run.
result printNl.

result errorCount > 0 ifTrue: [
    Transcript show: 'Errors:'; nl.
    (result errors asSortedCollection: [ :a :b | a printString <= b printString ])
	do: [ :each | Transcript show: '    '; print: each; nl ] ].

result failureCount > 0 ifTrue: [
    Transcript show: 'Failures:'; nl.
    (result failures asSortedCollection: [ :a :b | a printString <= b printString ])
	do: [ :each | Transcript show: '    '; print: each; nl ] ].

result runCount = result passedCount ifFalse: [
    ObjectMemory quit: 1 ]!
