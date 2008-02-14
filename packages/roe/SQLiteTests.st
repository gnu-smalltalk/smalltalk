"=====================================================================
|
|   ROE - SQLite-based testing
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RATestSemantics subclass: RATestSQLiteSemantics [
    | connection |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    connection [
	<category: 'configuration'>
	^connection
    ]

    createRelation: aString attributes: anArray [
	<category: 'configuration'>
	^self connection >> aString
    ]

    setUp [
	<category: 'private'>
	connection := DBI.Connection connect: 'dbi:SQLite:dbname=test.dat'
	    user: nil password: nil.

	self connection
	    do: 'begin';
	    do: 'create table profs (facultyID integer, name text)';
	    do: 'create table students (studentNumber integer, name text)';
	    do: 'create table students2 (studentNumber integer, name text)';
	    do: 'create table courses (courseNumber integer, title text, prof integer)';
	    do: 'create table enrollment (student integer, course integer)'.
	    
	super setUp
    ]

    tearDown [
	<category: 'private'>
	self connection do: 'rollback'.
	self connection close.
	(File name: connection database) remove
    ]
]
