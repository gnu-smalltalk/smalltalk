"======================================================================
|
|   Test the set routines
|
|
 ======================================================================"


"======================================================================
|
| Written by Paolo Bonzini (original code by Jonathan Carlson)
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

True extend [
    Object >> should: aBlock [ aBlock value assert ]
    assert [ 'passed' printNl ]
]

False extend [
    Object >> shouldnt: aBlock [ aBlock value not assert ]
    assert [ self error: 'failed' ]
]

Eval [

    set := Set new: 50.

    set add: 5.
    self should: [set includes: 5].

    set addAll: (1 to: 100).
    self should: [set size = 100].

    self should: [[set at: 5. false] on: Error do: [:ex | ex return: true]].
    self should: [[set at: 5 put: #abc. false] on: Error do: [:ex | ex return: true]].

    set := Set with: 5 with: #abc.

    self should: [set includes: 5].
    self should: [set includes: #abc].

    self should: [(set occurrencesOf: 0) = 0].
    self should: [(set occurrencesOf: 5) = 1].
    set add: 5.
    self should: [(set occurrencesOf: 5) = 1].

    set remove: 5.
    self should: [set includes: #abc].
    self shouldnt: [set includes: 5]
]
