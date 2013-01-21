"======================================================================
|
|   String manipulation and regular expression resolver
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2005, 2006, 2007, 2008, 2009
| Free Software Foundation, Inc.
| Written by Dragomir Milevojevic, Paolo Bonzini, Mike Anderson.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: RegexResults [
    
    <category: 'Collections-Text'>
    <comment: '
I hold the results of a regular expression match, and I can reconstruct
which parts of the matched string were assigned to each subexpression.
Methods such as #=~ return RegexResults objects, while others transform
the string directly without passing the results object back to the
caller.'>

    matched [
	"Answer whether the regular expression was matched"

	<category: 'testing'>
	self subclassResponsibility
    ]

    ifMatched: oneArgBlock ifNotMatched: zeroArgBlock [
	"If the regular expression was matched, evaluate oneArgBlock with the
	 receiver as the argument.  If it was not, evaluate zeroArgBlock.
	 Answer the result of the block's evaluation."

	<category: 'testing'>
	self subclassResponsibility
    ]

    ifNotMatched: zeroArgBlock ifMatched: oneArgBlock [
	"If the regular expression was matched, evaluate oneArgBlock with the
	 receiver as the argument.  If it was not, evaluate zeroArgBlock.
	 Answer the result of the block's evaluation."

	<category: 'testing'>
	self subclassResponsibility
    ]

    ifNotMatched: zeroArgBlock [
	"If the regular expression was matched, return the receiver.  If it was
	 not, evaluate zeroArgBlock and return its result."

	<category: 'testing'>
	^self ifNotMatched: zeroArgBlock ifMatched: []
    ]

    ifMatched: oneArgBlock [
	"If the regular expression was matched, pass the receiver to
	 oneArgBlock and return its result.  Otherwise, return nil."

	<category: 'testing'>
	^self ifNotMatched: [] ifMatched: oneArgBlock
    ]

    size [
	"If the regular expression was matched, return the number
	 of subexpressions that were present in the regular expression."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    asArray [
	"If the regular expression was matched, return an Array with
	 the subexpressions that were present in the regular expression."

	<category: 'accessing'>
	^1 to: self size collect: [ :each | self at: each ]
    ]

    subject [
	"If the regular expression was matched, return the text
	 that was matched against it."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    from [
	"If the regular expression was matched, return the index
	 of the first character in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    fromAt: anIndex [
	"If the regular expression was matched, return the index of the first
	 character of the anIndex-th subexpression in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    to [
	"If the regular expression was matched, return the index
	 of the last character in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    toAt: anIndex [
	"If the regular expression was matched, return the index of the last
	 character of the anIndex-th subexpression in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    match [
	"If the regular expression was matched, return the text of the
	 successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    matchInterval [
	"If the regular expression was matched, return an Interval for the
	 range of indices of the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    at: anIndex [
	"If the regular expression was matched, return the text of the
	 anIndex-th subexpression in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    intervalAt: anIndex [
	"If the regular expression was matched, return an Interval for the range
	 of indices in the anIndex-th subexpression of the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]
]
