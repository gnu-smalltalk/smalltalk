"=====================================================================
|
|   Just a Database Manager
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored by Paolo Bonzini
|
| This file is part of GNU Smalltalk.
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

Object subclass: #JdmErrorTable
        instanceVariableNames: 'errors '
        classVariableNames: 'ErrorTable '
        poolDictionaries: ''
        category: 'Mysql-Driver'!


Object subclass: #JdmServerInfo
	instanceVariableNames: 'serverVersion '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Magnitude subclass: #JdmServerVersion
	instanceVariableNames: 'fileFormat release version '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmConnectionSpec
	instanceVariableNames: 'database host port user password '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmConnection
	instanceVariableNames: 'serverInfo connectionSpec '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmColumn
	instanceVariableNames: 'table name size type flags decimalPlaces '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmFieldConverter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!

JdmFieldConverter class
	instanceVariableNames: 'instance'!


Object subclass: #JdmResult
	instanceVariableNames: 'value type '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!

Object subclass: #JdmResultSet
	instanceVariableNames: 'columns connection columnsByName currentRow '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!

Object subclass: #JdmStatement
	instanceVariableNames: 'connection '
	classVariableNames: 'SQLQueries '
	poolDictionaries: ''
	category: 'Mysql-Driver'!


!JdmErrorTable methodsFor: 'actions'!

throwException: aSymbol 
	self throwException: aSymbol message: ''!

throwException: aSymbol message: aString 
	self 
		error: (self errors at: aSymbol ifAbsent: ['Unknown']) , ': ' , aString! !

!JdmErrorTable methodsFor: 'initialize-release'!

initialize
	errors := JdmConnection dictionaryClass: IdentityDictionary
				from: self class errorTableMap! !

!JdmErrorTable methodsFor: 'accessing'!

errors
	^errors! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmErrorTable class
	instanceVariableNames: ''!


!JdmErrorTable class methodsFor: 'singleton'!

errorTable
	ErrorTable isNil ifTrue: [ErrorTable := self new initialize].
	^ErrorTable!

resetErrorTable
	ErrorTable := nil! !

!JdmErrorTable class methodsFor: 'errors'!

errorTableMap
	"JdmErrorTable resetErrorTable"
	^#(#protocol 'Invalid Protocol'
	    #authentication 'Access denied'
	    #setDatabase   'Could not set the database'
	    #invalidQuery 'Invalid query')! !

!JdmFieldConverter methodsFor: 'actions'!

convert: aValue from: aColumn 
	self subclassResponsibility!

!JdmFieldConverter class methodsFor: 'singleton'!

fieldConverter
	instance isNil ifTrue: [instance := self new initialize].
	^instance!

resetFieldConverter
	"JdmFieldConverter resetFieldConverter"
	instance := nil! !


!JdmColumn methodsFor: 'testing'!

hasFlag: aFlag
	^(self flags bitAnd: aFlag) > 0!

isAutoIncrement
	^self hasFlag: self class autoIncrementFlag!

isBinary
	^self hasFlag: self class binaryFlag!

isBlob
	^self hasFlag: self class blobFlag!

isEnumeration
	^self hasFlag: self class enumFlag!

isMultipleKey
	^self hasFlag: self class multipleKeyFlag!

isNotNull
	^self hasFlag: self class notNullFlag!

isPrimaryKey
	^self hasFlag: self class primaryKeyFlag!

isTimestamp
	^self hasFlag: self class timestampFlag!

isUniqueKey
	^self hasFlag: self class uniqueKeyFlag!

isZerofill
	^self hasFlag: self class zerofillFlag! !

!JdmColumn methodsFor: 'accessing'!

decimalPlaces
	^decimalPlaces!

flags
	^flags!

name
	^name!

size
	^size!

table
	^table!

type
	^type! !


!JdmConnection methodsFor: 'abstract'!

close
    self subclassResponsibility!

rowClass
    self subclassResponsibility!

fieldConverter
    self subclassResponsibility!

executeQuery: aQuery info: queryInfo
    self subclassResponsibility!

readColumnHeadings
    self subclassResponsibility! !

!JdmConnection methodsFor: 'initializing'!

initialize
!

!JdmConnection methodsFor: 'accessing'!

connectionSpec
	^connectionSpec!

connectionSpec: anObject
	connectionSpec := anObject!

createStatement
	^JdmStatement on: self!

serverInfo
	^serverInfo!

serverInfo: anObject
	serverInfo := anObject!

initialize! !

!JdmConnection class methodsFor: 'instance creation'!

on: aConnectionSpec
        ^(self new)
                connectionSpec: aConnectionSpec;
                initialize! !

!JdmConnection class methodsFor: 'utility'!

dictionaryClass: aClass from: keysAndValues
        | dictionary |
        dictionary := aClass new: keysAndValues size.
        1 to: keysAndValues size
                by: 2
                do: [:i | dictionary at: (keysAndValues at: i) put: (keysAndValues at: i + 1)].
        ^dictionary! !

!JdmConnectionSpec methodsFor: 'accessing'!

database
	^database!

database: anObject
	database := anObject!

host
	^host!

host: anObject
	host := anObject!

password
	^password!

password: anObject
	password := anObject!

port
	^port!

port: anObject
	port := anObject!

user
	^user!

user: anObject
	user := anObject! !

!JdmConnectionSpec methodsFor: 'initialize-release'!

initialize
	database := 'test'.
	host := 'localhost'.
	port := 3306.
	user := ''.
	password := ''! !

!JdmServerVersion methodsFor: 'initialize-release'!

initialize
	fileFormat := 0.
	release := 0.
	version := 0.! !

!JdmServerVersion methodsFor: 'printing'!

printOn: aStream 
	aStream
		nextPutAll: fileFormat printString;
		nextPut: $.;
		nextPutAll: release printString;
		nextPut: $.;
		nextPutAll: version printString! !

!JdmServerVersion methodsFor: 'accessing'!

fileFormat
	^fileFormat!

fileFormat: anInteger
	fileFormat := anInteger!

serverRelease
	"Renamed this because of a conflict with the Object method release"
	^release!

serverRelease: anInteger
	release := anInteger!

version
	^version!

version: anInteger
	version := anInteger! !

!JdmServerVersion methodsFor: 'comparing'!

< aJdmServerVersion 
	^aJdmServerVersion fileFormat > fileFormat or: 
			[(aJdmServerVersion fileFormat = fileFormat 
				and: [aJdmServerVersion serverRelease > release]) or: 
						[aJdmServerVersion serverRelease = release 
							and: [aJdmServerVersion version > version]]]!

= aJdmServerVersion 
	^fileFormat = aJdmServerVersion fileFormat and: 
			[release = aJdmServerVersion serverRelease 
				and: [version = aJdmServerVersion version]]! !

!JdmServerInfo methodsFor: 'accessing'!

serverVersion
	^serverVersion!

serverVersion: anObject
	serverVersion := anObject! !



!JdmResult methodsFor: 'testing'!

hasResultSet
	^type = #read! !


!JdmResult methodsFor: 'accessing'!

type
	^type!

type: aType
	type := aType!

value
	^value!

value: aValue
	value := aValue! !



!JdmResultSet methodsFor: 'private-accessing'!

currentRow
	^currentRow! !

!JdmResultSet methodsFor: 'accessing'!

columnAt: index
	^columns at: index!

columnNamed: aName 
	^self columnAt: (columnsByName at: aName ifAbsent: [^nil])!

columns
	^columns!

connection
	^connection!

connection: anObject
	connection := anObject!

flush
	self hasNext ifFalse: [^self].
	[self next] whileTrue: []!

next
	currentRow := (self connection rowClass withNumColumns: columns size) 
				readFrom: connection responsePacket readStream.
	^currentRow isEmpty not!

rawValueAt: anIndex
	^self currentRow at: anIndex!

rawValueNamed: aName 
	^self rawValueAt: (columnsByName at: aName)!

valueAt: anIndex 
	| aValue |
	aValue := self currentRow at: anIndex.
	aValue isNil ifTrue: [^aValue].
	^self connection fieldConverter convert: aValue
		from: (self columns at: anIndex)!

valueNamed: aName 
	^self valueAt: (columnsByName at: aName)! !

!JdmResultSet methodsFor: 'testing'!

hasNext
	^self currentRow isEmpty not! !

!JdmResultSet methodsFor: 'initialize-release'!

initialize
	columnsByName := LookupTable new.
	columns := self connection readColumnHeadings.
	columns keysAndValuesDo: [ :index :column |
            columnsByName at: column name put: index
	].
	currentRow := self connection rowClass withNumColumns: columns size! !


!JdmResultSet class methodsFor: 'instance creation'!

on: aConnection 
	^(self new)
		connection: aConnection;
		initialize! !

!JdmStatement methodsFor: 'private-accessing'!

connection: aConnection
	connection := aConnection!

createResult: queryInfo queryResult: result
	^self
	    perform: ((queryInfo at: 1) , 'Result:queryResult:') asSymbol
	    with: queryInfo
	    with: result!

readResult: queryInfo queryResult: result
	^JdmResult new
		type: (queryInfo at: 1);
		value: ((queryInfo at: 2) value on: connection)!

updateResult: queryInfo queryResult: result
	^(JdmResult new)
		type: (queryInfo at: 1);
		value: result! !

!JdmStatement methodsFor: 'accessing'!

executeQuery: aQuery 
	| queryInfo |
	queryInfo := self class queryInfoFor: aQuery.
	queryInfo isNil 
		ifTrue: 
			[JdmErrorTable errorTable throwException: #invalidQuery message: aQuery].
	
	^self createResult: queryInfo queryResult:
	    (connection executeQuery: aQuery info: queryInfo)
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmStatement class
	instanceVariableNames: ''!


!JdmStatement class methodsFor: 'constants'!

sqlQueries
	^#(#('EXPLAIN'   #(#read #{JdmResultSet}))
	   #('SELECT'    #(#read #{JdmResultSet}))
	   #('SHOW'	 #(#read #{JdmResultSet}))
	   #('DESCRIBE'  #(#read #{JdmResultSet}))
           #('BEGIN'     #(#update))
           #('START'     #(#update))
           #('COMMIT'    #(#update))
           #('ROLLBACK'  #(#update))
           #('INSERT'    #(#update))
           #('UPDATE'    #(#update))
           #('DELETE'    #(#update))
           #('CREATE'    #(#update))
           #('DROP'      #(#update))
           #('ALTER'     #(#update))
           #('LOCK'      #(#update))
           #('UNLOCK'    #(#update))
           #('SET'       #(#update))
           #('GRANT'     #(#update))
           #('REPLACE'   #(#update)))! !

!JdmStatement class methodsFor: 'private-parsing'!

getCommand: aQuery 
	| readStream writeStream aCharacter |
	writeStream := WriteStream on: String new.
	readStream := ReadStream on: aQuery.
	readStream skipSeparators.
	[readStream atEnd or: [aCharacter := readStream next. aCharacter isSeparator]] 
		whileFalse: [writeStream nextPut: aCharacter asUppercase].
	^writeStream contents! !

!JdmStatement class methodsFor: 'accessing'!

queryInfoFor: aQuery 
	^SQLQueries at: (self getCommand: aQuery) ifAbsent: [nil]! !

!JdmStatement class methodsFor: 'initialize-release'!

initialize
	"JdmStatement initialize"

	SQLQueries := LookupTable new.
	self sqlQueries do: 
			[:association | 
			SQLQueries 
				add: (Association key: (association at: 1) value: (association at: 2))]!

initializeOnLoad
	self initialize! !

!JdmStatement class methodsFor: 'instance creation'!

on: aConnection 
	^self new connection: aConnection! !

JdmStatement initialize!
