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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Object subclass: #Permission
	instanceVariableNames: 'name actions target positive '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Security'
!

Object subclass: #SecurityPolicy
	instanceVariableNames: 'dictionary owner '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Security'
!

Permission comment: 
'I am the basic class that represents whether operations that could harm
the system''s security are allowed or denied.' !

SecurityPolicy comment: 
'I am the class that represents which operations that could harm
the system''s security are allowed or denied to a particular class.  If
a class does not have a policy, it is allowed everything if it is trusted,
and denied everything if it is untrusted' !


!Permission class methodsFor: 'testing'!

name: aSymbol target: aTarget actions: actionsArray
    ^self new
	name: aSymbol;
	target: aTarget;
	actions: actionsArray;
	yourself
!

name: aSymbol target: aTarget action: action
    ^self name: aSymbol target: aTarget actions: { action }
!

allowing: aSymbol target: aTarget actions: actionsArray
    ^(self name: aSymbol target: aTarget actions: actionsArray)
	allow
!

allowing: aSymbol target: aTarget action: action
    ^(self name: aSymbol target: aTarget actions: { action })
	allow
!

denying: aSymbol target: aTarget actions: actionsArray
    ^(self name: aSymbol target: aTarget actions: actionsArray)
	deny
!

denying: aSymbol target: aTarget action: action
    ^(self name: aSymbol target: aTarget actions: { action })
	deny
!

granting: aSymbol target: aTarget actions: actionsArray
    ^(self name: aSymbol target: aTarget actions: actionsArray)
	allow
!

granting: aSymbol target: aTarget action: action
    ^(self name: aSymbol target: aTarget actions: { action })
	allow
! !


!Permission methodsFor: 'testing'!

check: aPermission for: anObject
    ^(self implies: aPermission)
	ifTrue: [ self isAllowing ]
	ifFalse: [ anObject isUntrusted not ]
!

implies: aPermission
    aPermission name = name ifFalse: [ ^false ].
    (self target notNil and: [ aPermission target notNil ]) ifTrue: [
        (self target isString and: [ aPermission target isString ])
	    ifTrue: [
	        (self target match: aPermission target) ifFalse: [ ^false ] ]
	    ifFalse: [
	        (self target == aPermission target) ifFalse: [ ^false ] ]
    ].

    (self actions notNil and: [ aPermission actions notNil ]) ifTrue: [
	aPermission actions size = 1
	    ifTrue: [ ^self actions includes: (aPermission at: 1) ].

	^aPermission actions allSatisfy: [ :each | self actions includes: each ]
    ].
    ^true
! !



!Permission methodsFor: 'accessing'!

action: anObject
    self actions: { anObject }
!

actions
    ^actions
!

actions: anObject
    actions isNil ifFalse: [
	self error: 'can set permission actions only once' ].

    (actions allSatisfy: [ :each | each isSymbol ]) ifFalse: [
	self error: 'actions must be symbols' ].

    actions := anObject copy asArray
!

allow
    positive isNil ifFalse: [
	self error: 'can set allow/deny only once' ].

    positive := true
!

allowing
    | savePositive result |
    savePositive := positive.
    positive := true.
    result := self copy.
    positive := savePositive.
    ^result
!

deny
    positive isNil ifFalse: [
	self error: 'can set allow/deny only once' ].

    positive := false
!

denying
    | savePositive result |
    savePositive := positive.
    positive := false.
    result := self copy.
    positive := savePositive.
    ^result
!

isAllowing
    ^positive
!

name
    ^name
!

name: anObject
    name isNil ifFalse: [
	self error: 'can set permission name only once' ].

    anObject isSymbol ifFalse: [
	self error: 'permission name must be a symbol' ].

    name := anObject copy
!

target
    ^target
!

target: anObject
    target isNil ifFalse: [
	self error: 'can set permission target only once' ].

    (target allSatisfy: [ :each | each isSymbol ]) ifFalse: [
	self error: 'target must be symbols' ].

    target := anObject copy
! !


!SecurityPolicy methodsFor: 'modifying'!

addPermission: aPermission
    owner isNil ifFalse: [
	thisContext securityCheckFor: #securityManagement target: owner ].

    dictionary isNil ifTrue: [
	dictionary := IdentityDictionary new ].

    (dictionary at: aPermission name ifAbsentPut: [ OrderedCollection new ])
	add: aPermission allowing
!

removePermission: aPermission
    owner isNil ifFalse: [
	thisContext securityCheckFor: #securityManagement target: owner ].

    dictionary isNil ifTrue: [
	dictionary := IdentityDictionary new ].

    (dictionary at: aPermission name ifAbsentPut: [ OrderedCollection new ])
	add: aPermission denying
!

withOwner: aClass
    ^self copy
	owner: aClass;
	yourself
!

owner: aClass
    thisContext securityCheckFor: #securityManagement target: aClass.
    dictionary := dictionary deepCopy.
    owner := aClass.
    ^self
! !


!SecurityPolicy methodsFor: 'querying'!

check: aPermission
    ^(dictionary at: aPermission name ifAbsent: [ #() ])
        inject: owner isUntrusted not into: [ :old :perm |
	  (perm implies: aPermission)
	      ifTrue: [ perm isAllowing ]
	      ifFalse: [ old ] ]
!

implies: aPermission
    ^(dictionary at: aPermission name ifAbsent: [ #() ])
        inject: false into: [ :old :perm |
	  (perm implies: aPermission)
	      ifTrue: [ perm isAllowing ]
	      ifFalse: [ old ] ]
! !
