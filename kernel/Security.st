"======================================================================
|
|   Security-related Class Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2003
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: Permission [
    | name actions target positive |
    
    <category: 'Language-Security'>
    <comment: 'I am the basic class that represents whether operations that could harm
the system''s security are allowed or denied.'>

    Permission class >> name: aSymbol target: aTarget actions: actionsArray [
	<category: 'testing'>
	^(self new)
	    name: aSymbol;
	    target: aTarget;
	    actions: actionsArray;
	    yourself
    ]

    Permission class >> name: aSymbol target: aTarget action: action [
	<category: 'testing'>
	^self 
	    name: aSymbol
	    target: aTarget
	    actions: {action}
    ]

    Permission class >> allowing: aSymbol target: aTarget actions: actionsArray [
	<category: 'testing'>
	^(self 
	    name: aSymbol
	    target: aTarget
	    actions: actionsArray) allow
    ]

    Permission class >> allowing: aSymbol target: aTarget action: action [
	<category: 'testing'>
	^(self 
	    name: aSymbol
	    target: aTarget
	    actions: {action}) allow
    ]

    Permission class >> denying: aSymbol target: aTarget actions: actionsArray [
	<category: 'testing'>
	^(self 
	    name: aSymbol
	    target: aTarget
	    actions: actionsArray) deny
    ]

    Permission class >> denying: aSymbol target: aTarget action: action [
	<category: 'testing'>
	^(self 
	    name: aSymbol
	    target: aTarget
	    actions: {action}) deny
    ]

    Permission class >> granting: aSymbol target: aTarget actions: actionsArray [
	<category: 'testing'>
	^(self 
	    name: aSymbol
	    target: aTarget
	    actions: actionsArray) allow
    ]

    Permission class >> granting: aSymbol target: aTarget action: action [
	<category: 'testing'>
	^(self 
	    name: aSymbol
	    target: aTarget
	    actions: {action}) allow
    ]

    check: aPermission for: anObject [
	<category: 'testing'>
	^(self implies: aPermission) 
	    ifTrue: [self isAllowing]
	    ifFalse: [anObject isUntrusted not]
    ]

    implies: aPermission [
	<category: 'testing'>
	aPermission name = name ifFalse: [^false].
	(self target notNil and: [aPermission target notNil]) 
	    ifTrue: 
		[(self target isString and: [aPermission target isString]) 
		    ifTrue: [(self target match: aPermission target) ifFalse: [^false]]
		    ifFalse: [self target == aPermission target ifFalse: [^false]]].
	(self actions notNil and: [aPermission actions notNil]) 
	    ifTrue: 
		[aPermission actions size = 1 
		    ifTrue: [^self actions includes: (aPermission at: 1)].
		^aPermission actions allSatisfy: [:each | self actions includes: each]].
	^true
    ]

    action: anObject [
	<category: 'accessing'>
	self actions: {anObject}
    ]

    actions [
	<category: 'accessing'>
	^actions
    ]

    actions: anObject [
	<category: 'accessing'>
	actions isNil 
	    ifFalse: [self error: 'can set permission actions only once'].
	(actions allSatisfy: [:each | each isSymbol]) 
	    ifFalse: [self error: 'actions must be symbols'].
	actions := anObject copy asArray
    ]

    allow [
	<category: 'accessing'>
	positive isNil ifFalse: [self error: 'can set allow/deny only once'].
	positive := true
    ]

    allowing [
	<category: 'accessing'>
	| savePositive result |
	savePositive := positive.
	positive := true.
	result := self copy.
	positive := savePositive.
	^result
    ]

    deny [
	<category: 'accessing'>
	positive isNil ifFalse: [self error: 'can set allow/deny only once'].
	positive := false
    ]

    denying [
	<category: 'accessing'>
	| savePositive result |
	savePositive := positive.
	positive := false.
	result := self copy.
	positive := savePositive.
	^result
    ]

    isAllowing [
	<category: 'accessing'>
	^positive
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: anObject [
	<category: 'accessing'>
	name isNil ifFalse: [self error: 'can set permission name only once'].
	anObject isSymbol 
	    ifFalse: [self error: 'permission name must be a symbol'].
	name := anObject copy
    ]

    target [
	<category: 'accessing'>
	^target
    ]

    target: anObject [
	<category: 'accessing'>
	target isNil ifFalse: [self error: 'can set permission target only once'].
	(target allSatisfy: [:each | each isSymbol]) 
	    ifFalse: [self error: 'target must be symbols'].
	target := anObject copy
    ]
]



Object subclass: SecurityPolicy [
    | dictionary owner |
    
    <category: 'Language-Security'>
    <comment: 'I am the class that represents which operations that could harm
the system''s security are allowed or denied to a particular class.  If
a class does not have a policy, it is allowed everything if it is trusted,
and denied everything if it is untrusted'>

    addPermission: aPermission [
	<category: 'modifying'>
	owner isNil 
	    ifFalse: [thisContext securityCheckFor: #securityManagement target: owner].
	dictionary isNil ifTrue: [dictionary := IdentityDictionary new].
	(dictionary at: aPermission name ifAbsentPut: [OrderedCollection new]) 
	    add: aPermission allowing
    ]

    removePermission: aPermission [
	<category: 'modifying'>
	owner isNil 
	    ifFalse: [thisContext securityCheckFor: #securityManagement target: owner].
	dictionary isNil ifTrue: [dictionary := IdentityDictionary new].
	(dictionary at: aPermission name ifAbsentPut: [OrderedCollection new]) 
	    add: aPermission denying
    ]

    withOwner: aClass [
	<category: 'modifying'>
	^(self copy)
	    owner: aClass;
	    yourself
    ]

    owner: aClass [
	<category: 'modifying'>
	thisContext securityCheckFor: #securityManagement target: aClass.
	dictionary := dictionary deepCopy.
	owner := aClass.
	^self
    ]

    check: aPermission [
	<category: 'querying'>
	^(dictionary at: aPermission name ifAbsent: [#()]) 
	    inject: owner isUntrusted not
	    into: [:old :perm | (perm implies: aPermission) ifTrue: [perm isAllowing] ifFalse: [old]]
    ]

    implies: aPermission [
	<category: 'querying'>
	^(dictionary at: aPermission name ifAbsent: [#()]) inject: false
	    into: [:old :perm | (perm implies: aPermission) ifTrue: [perm isAllowing] ifFalse: [old]]
    ]
]

