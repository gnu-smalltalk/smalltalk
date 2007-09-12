"======================================================================
|
| Copyright 2006 Mike Anderson
| Written by Mike Anderson
|
| This is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| This code is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| Mumble; see the file COPYING.  If not, write to the Free Software
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================
"



Object subclass: Statement [
    | connection |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a prepared statement.'>

    Statement class >> on: aConnection [
        "Return a new statement for this connection."

        <category: 'instance creation'>
        ^self new
            connection: aConnection;
            yourself
    ]

    connection [
        "Return the connection for which the statement was prepared."

        <category: 'private'>
        ^connection
    ]

    connection: aConnection [
        "Associate the statement to the given Connection."

        <category: 'private'>
        connection := aConnection
    ]

    execute [
	"Execute with no parameters (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    executeWith: aParameter [
	"Execute with one parameters."

	<category: 'querying'>
	^self executeWithAll: {aParameter}
    ]

    executeWith: aParam1 with: aParam2 [
	"Execute with two parameters."

	<category: 'querying'>
	^self executeWithAll: 
		{aParam1.
		aParam2}
    ]

    executeWith: aParam1 with: aParam2 with: aParam3 [
	"Execute with three parameters."

	<category: 'querying'>
	^self executeWithAll: 
		{aParam1.
		aParam2.
		aParam3}
    ]

    executeWithAll: aParams [
	"Execute taking parameters from the Collection aParams (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]
]

