"=====================================================================
|
|   ROE unit tests
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

RAArrayRelation subclass: RAMockRelation [
    | objectClass |
    
    <category: 'Roe-Tests'>
    <comment: nil>

    objectClass [
	^objectClass
    ]

    objectClass: aClass [
	objectClass := aClass
    ]

    objectForValues: aDictionary [
	| values |
	values := Dictionary new.
	aDictionary associationsDo: [:each | values at: each key name asSymbol put: each value].
	^self objectClass fromValues: values
    ]

    printOn: aStream [
	self attributes do: [:ea | aStream nextPutAll: ea name]
    ]
]


TestCase subclass: RATestMapping [
    | courses students |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    setUp [
	<category: 'running'>
	courses := RAMockRelation name: 'courses' attributes: #(#id #title).
	students := RAMockRelation name: 'students' attributes: #(#name #courseID).
	courses addAllValues: #(#(1 'Discrete Math') #(2 'Databases')).
	students addAllValues: #(#('Avi' 2) #('Ken' 2)).
	courses objectClass: RAMockCourse.
	students objectClass: RAMockStudent
    ]

    studentsForCourseID: courseID [
	<category: 'private'>
	^students * (courses where: #id equals: courseID) 
	    whereEqual: #(#id #courseID)
    ]

    testObjectInstantiation [
	<category: 'testing'>
	| mappedStudents |
	mappedStudents := (self studentsForCourseID: 2) asMappedCollection.
	self assert: mappedStudents size = 2.
	self assert: mappedStudents anyOne first class = RAMockStudent.
	self assert: mappedStudents anyOne second class = RAMockCourse
    ]

    testSelfJoins [
	<category: 'testing'>
	| mapping tuple |
	mapping := (students * students * courses * students * courses) 
		    asMappedCollection.
	tuple := mapping anyOne.
	self assert: (tuple collect: [:ea | ea class name]) 
		    = #(#RAMockStudent #RAMockStudent #RAMockCourse #RAMockStudent #RAMockCourse)
    ]

    testSingleObjectInstantiation [
	<category: 'testing'>
	| mappedStudents |
	mappedStudents := students asSingleMappedCollection.
	self assert: mappedStudents size = 2.
	self assert: mappedStudents anyOne class = RAMockStudent
    ]
]



TestCase subclass: RATestSemantics [
    | students students2 courses profs enrollment |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    addAllValues: anArray to: aRelation [
	<category: 'private'>
	aRelation addAllValues: anArray
    ]

    assertQueryOrdered: aRelation gives: anArray [
	<category: 'private'>
	self 
	    assert: (aRelation collect: [:ea | ea values asArray]) asArray = anArray
    ]

    assertQueryUnordered: aRelation gives: anArray [
	<category: 'private'>
	self assert: (aRelation collect: [:ea | ea values asArray]) asSet 
		    = anArray asSet
    ]

    assertTuple: aTuple is: anArray [
	<category: 'private'>
	self assert: aTuple values asArray = anArray
    ]

    createRelation: aString attributes: anArray [
	<category: 'private'>
	self subclassResponsibility
    ]

    selectCourseNumbersForProf: aString [
	<category: 'private'>
	^((profs * courses whereEqual: #(#facultyID #prof)) where: #name
	    equals: aString) project: #courseNumber
    ]

    selectCourseTitlesForStudent: aString [
	<category: 'private'>
	^((students select: [:ea | ea name = aString]) * enrollment * courses 
	    select: [:ea | ea student = ea studentNumber & (ea course = ea courseNumber)]) 
		project: #title
    ]

    setUp [
	<category: 'running'>
	profs := self createRelation: 'profs' attributes: #(#facultyID #name).
	self 
	    addAllValues: #(#(1 'Murphy') #(2 'Cavers') #(3 'Tsiknis') #(4 'Bob'))
	    to: profs.
	students := self createRelation: 'students'
		    attributes: #(#studentNumber #name).
	self addAllValues: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob'))
	    to: students.
	students2 := self createRelation: 'students2'
		    attributes: #(#studentNumber #name).
	self addAllValues: #(#(1 'Avi') #(2 'Julian') #(5 'Lukas') #(6 'Adrian'))
	    to: students2.
	courses := self createRelation: 'courses'
		    attributes: #('courseNumber' 'title' 'prof').
	self 
	    addAllValues: #(#(310 'Software Engineering' 1) #(220 'Discrete Math' 2) #(128 'Scheme' 2) #(304 'Databases' 3))
	    to: courses.
	enrollment := self createRelation: 'enrollment'
		    attributes: #('student' 'course').
	self 
	    addAllValues: #(#(1 310) #(1 220) #(2 220) #(2 128) #(3 220) #(3 304) #(3 310))
	    to: enrollment
    ]

    testAllStudents [
	<category: 'testing'>
	self assertQueryOrdered: students
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob'))
    ]

    testBothStudentAndProf [
	<category: 'testing'>
	| profName studentName |
	profName := profs attributeNamed: #name.
	studentName := students attributeNamed: #name.
	self 
	    assertQueryOrdered: ((profs * students 
		    select: [:ea | (ea at: profName) = (ea at: studentName)]) project: profName)
	    gives: #(#('Bob'))
    ]

    testBothStudentAndProfOldStyle [
	<category: 'testing'>
	self 
	    assertQueryOrdered: (((profs rename: #name to: #profName) 
		    * (students rename: #name to: #studName) 
			select: [:ea | ea profName = ea studName]) project: #profName)
	    gives: #(#('Bob'))
    ]

    testDistinct [
	<category: 'testing'>
	| student |
	student := enrollment attributeNamed: #student.
	self assertQueryOrdered: ((enrollment project: student) distinct 
		    orderBy: student)
	    gives: #(#(1) #(2) #(3)).
	self assertQueryOrdered: ((enrollment project: #course) distinct 
		    orderBy: #course)
	    gives: #(#(128) #(220) #(304) #(310))
    ]

    testFindClassmates [
	<category: 'testing'>
	| classmates |
	classmates := enrollment clone.
	self 
	    assertQueryUnordered: ((enrollment * classmates select: 
			[:ea | 
			(ea at: enrollment >> #course) = (ea at: classmates >> #course) 
			    & ((ea at: enrollment >> #student) ~= (ea at: classmates >> #student))]) 
		    projectAll: (Array with: enrollment >> #student with: classmates >> #student))
	    gives: #(#(1 3) #(1 2) #(2 3) #(3 1) #(2 1) #(3 2))
    ]

    testFindClassmatesOldStyle [
	<category: 'testing'>
	self 
	    assertQueryUnordered: ((enrollment 
		    * (enrollment renameAll: #(#student #course) to: #(#classmate #course2)) 
			select: [:ea | ea course = ea course2 & (ea student ~= ea classmate)]) 
			projectAll: #(#student #classmate))
	    gives: #(#(1 3) #(1 2) #(2 3) #(3 1) #(2 1) #(3 2))
    ]

    testFindProfCourses [
	<category: 'testing'>
	self assertQueryUnordered: (self selectCourseNumbersForProf: 'Cavers')
	    gives: #(#(220) #(128))
    ]

    testFindStudentCourses [
	<category: 'testing'>
	self assertQueryUnordered: (self selectCourseTitlesForStudent: 'Andrew')
	    gives: #(#('Discrete Math') #('Databases') #('Software Engineering'))
    ]

    testIntervalStudents [
	<category: 'testing'>
	| relation |
	relation := students orderBy: #studentNumber ascending: true.
	self assertQueryOrdered: (relation from: 1 to: 0) gives: #().
	self assertQueryOrdered: (relation from: 1 to: 1) gives: #(#(1 'Avi')).
	self assertQueryOrdered: (relation from: 1 to: 4)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob')).
	self assertQueryOrdered: (relation from: 2 to: 3)
	    gives: #(#(2 'Julian') #(3 'Andrew')).
	self assertQueryOrdered: (relation copyFrom: 2 to: 3)
	    gives: #(#(2 'Julian') #(3 'Andrew'))
    ]

    testOrderStudents [
	<category: 'testing'>
	self 
	    assertQueryOrdered: (students orderBy: #studentNumber ascending: true)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob')).
	self 
	    assertQueryOrdered: (students orderBy: #studentNumber ascending: false)
	    gives: #(#(4 'Bob') #(3 'Andrew') #(2 'Julian') #(1 'Avi'))
    ]

    testSelectOneStudent [
	<category: 'testing'>
	self assertQueryOrdered: (students select: [:ea | ea name = 'Julian'])
	    gives: #(#(2 'Julian'))
    ]

    testSize [
	<category: 'testing'>
	self assert: students size = 4
    ]

    testStudentExcept [
	<category: 'testing'>
	self assertQueryUnordered: students - students2
	    gives: #(#(3 'Andrew') #(4 'Bob')).
	self assertQueryUnordered: (students difference: students2)
	    gives: #(#(3 'Andrew') #(4 'Bob')).
	self assertQueryUnordered: students2 - students
	    gives: #(#(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: (students2 difference: students)
	    gives: #(#(5 'Lukas') #(6 'Adrian'))
    ]

    testStudentIndex [
	<category: 'testing'>
	| idx |
	idx := students indexBy: #studentNumber.
	self assertQueryUnordered: (idx at: 1) gives: #(#(1 'Avi')).
	idx := students keyBy: #studentNumber.
	self assertTuple: (idx at: 1) is: #(1 'Avi')
    ]

    testStudentIntersect [
	<category: 'testing'>
	self assertQueryUnordered: (students intersection: students2)
	    gives: #(#(1 'Avi') #(2 'Julian')).
	self assertQueryUnordered: (students2 intersection: students)
	    gives: #(#(1 'Avi') #(2 'Julian'))
    ]

    testStudentNames [
	<category: 'testing'>
	self assertQueryOrdered: (students project: #name)
	    gives: #(#('Avi') #('Julian') #('Andrew') #('Bob'))
    ]

    testStudentUnion [
	<category: 'testing'>
	self assertQueryUnordered: students , students2
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: (students union: students2)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: students2 , students
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: (students2 union: students)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian'))
    ]

    testUpdateAlias [
	<category: 'testing'>
	(students rename: #studentNumber to: #sn) update: [:ea | ea sn: 1].
	self assertQueryUnordered: students
	    gives: #(#(1 'Avi') #(1 'Julian') #(1 'Andrew') #(1 'Bob'))
    ]

    testUpdateAliasWithColumn [
	<category: 'testing'>
	(students renameAll: #(#name #studentNumber) to: #(#cn #sn)) 
	    update: [:ea | ea cn: ea sn asString].
	self assertQueryUnordered: students
	    gives: #(#(1 '1') #(2 '2') #(3 '3') #(4 '4'))
    ]

    testUpdateJoin [
	<category: 'testing'>
	| join |
	join := students * profs.
	self should: [join update: [:ea | ea studentNumber: 17]] raise: Error
    ]

    testUpdateSimpleSelect [
	<category: 'testing'>
	(students select: [:ea | ea name = 'Julian']) 
	    update: [:ea | ea name: 'Fitzell'].
	self assertQueryUnordered: students
	    gives: #(#(1 'Avi') #(2 'Fitzell') #(3 'Andrew') #(4 'Bob'))
    ]

    testUpdateTableWithColumn [
	<category: 'testing'>
	students update: [:ea | ea name: ea studentNumber asString].
	self assertQueryUnordered: students
	    gives: #(#(1 '1') #(2 '2') #(3 '3') #(4 '4'))
    ]

    testUpdateTableWithLiteral [
	<category: 'testing'>
	students update: [:ea | ea name: 'Foo'].
	self assertQueryUnordered: students
	    gives: #(#(1 'Foo') #(2 'Foo') #(3 'Foo') #(4 'Foo'))
    ]
]



RATestSemantics subclass: RATestEvaluatorSemantics [
    
    <comment: nil>
    <category: 'Roe-Tests'>

    createRelation: aString attributes: anArray [
	<category: 'private'>
	^RAArrayRelation name: aString attributes: anArray
    ]
]



TestCase subclass: RATestSyntax [
    | abc def abcdef ab fe abd geh abqe aLT2 bEQfoo abcSquared abcGBa abcGBab abcOBaa abcOBad abcOBaabd abcEabc abcUabc abcIabc abcD abcI |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    assert: aRelation hasAttributes: attributeNames [
	<category: 'private'>
	self assert: (aRelation attributes collect: [:ea | ea name asSymbol]) asArray 
		    = attributeNames
    ]

    assertError: aBlock [
	<category: 'private'>
	self should: aBlock raise: Error
    ]

    setUp [
	<category: 'running'>
	abc := RAArrayRelation name: 'abc' attributes: #(#a #b #c).
	def := RAArrayRelation name: 'def' attributes: #(#d #e #f).
	abcdef := abc * def.
	ab := abc projectAll: #(#a #b).
	fe := def projectAll: #(#f #e).
	abd := abc rename: #c to: #d.
	geh := def renameAll: #(#d #f) to: #(#g #h).
	abqe := ab * (fe rename: #f to: #q).
	aLT2 := abc select: [:ea | ea a < 2].
	bEQfoo := abc select: [:ea | ea b = 'foo' & (ea a >= (ea c * 2))].
	abcSquared := abc * (abc renameAll: #(#a #b #c) to: #(#a1 #b1 #c1)).
	abcGBa := abc groupBy: #a.
	abcGBab := abc groupByAll: #(#a #b).
	abcOBaa := abc orderBy: #a.
	abcOBad := abc orderBy: #a ascending: false.
	abcOBaabd := abc orderByAll: #(#a #b)
		    ascending: (Array with: true with: false).
	abcEabc := abc difference: abc.	"abc - abc"
	abcUabc := abc union: abc.	"abc , abc"
	abcIabc := abc intersection: abc.
	abcD := abc distinct.
	abcI := abc from: 10 to: 15	"abc copyFrom: 10 to: 15"
    ]

    testAttributeNames [
	<category: 'testing'>
	self assert: abc hasAttributes: #(#a #b #c).
	self assert: def hasAttributes: #(#d #e #f).
	self assert: abcdef hasAttributes: #(#a #b #c #d #e #f).
	self assert: ab hasAttributes: #(#a #b).
	self assert: fe hasAttributes: #(#f #e).
	self assert: abd hasAttributes: #(#a #b #d).
	self assert: geh hasAttributes: #(#g #e #h).
	self assert: abqe hasAttributes: #(#a #b #q #e).
	self assert: aLT2 hasAttributes: #(#a #b #c).
	self assert: bEQfoo hasAttributes: #(#a #b #c).
	self assert: abcSquared hasAttributes: #(#a #b #c #a1 #b1 #c1).
	self assert: abcGBa hasAttributes: #(#a #b #c).
	self assert: abcGBab hasAttributes: #(#a #b #c).
	self assert: abcOBaa hasAttributes: #(#a #b #c).
	self assert: abcOBad hasAttributes: #(#a #b #c).
	self assert: abcOBaabd hasAttributes: #(#a #b #c).
	self assert: abcEabc hasAttributes: #(#a #b #c).
	self assert: abcUabc hasAttributes: #(#a #b #c).
	self assert: abcIabc hasAttributes: #(#a #b #c).
	self assert: abcD hasAttributes: #(#a #b #c).
	self assert: abcI hasAttributes: #(#a #b #c)
    ]

    testEquality [
	<category: 'testing'>
	self assert: (abc project: #a) = (abc project: #a).
	self deny: (abc project: #a) = (abc project: #b).
	self deny: (abc project: #a) = (ab project: #a).
	self assert: (abc rename: #a to: #x) = (abc rename: #a to: #x).
	self assert: (abc renameAll: #(#a) to: #(#x)) = (abc rename: #a to: #x).
	self assert: (abc renameAll: #(#a #b) to: #(#x #y)) 
		    = (abc renameAll: #(#b #a) to: #(#y #x)).
	self 
	    deny: (abc rename: #a to: #x) = (abc renameAll: #(#a #b) to: #(#x #y))
    ]

    testErrors [
	<category: 'testing'>
	abc project: #c.
	self assertError: [abc project: #d].
	self assertError: [ab project: #c].
	abc rename: #c to: #e.
	self assertError: [abc rename: #d to: #e].
	abc renameAll: #(#a #b) to: #(#e #f).
	self assertError: [abc renameAll: #(#a #b) to: #(#e)].
	abc where: #a equals: 3.
	self assertError: [abc where: #d equals: 3].
	abc * (abc rename: #a to: #a2) project: #a.
	self assertError: [abc * abc project: #a].
	abc * (abc rename: #a to: #a2) rename: #a to: #e.
	self assertError: [abc * abc rename: #a to: #e].
	abc * (abc rename: #a to: #a2) where: #a equals: 3.
	self assertError: [abc * abc where: #a equals: 3]
    ]

    testEscapingSql [
	<category: 'testing'>
	self assert: '\' asEscapedSql = '\\'.
	self assert: '''' asEscapedSql = ''''''.
	self assert: '\''' asEscapedSql = '\\'''''
    ]

    testOrigins [
	<category: 'testing'>
	self assert: (abc attributeNamed: #a) originalRelation = abc.
	self assert: (abcdef attributeNamed: #a) originalRelation = abc.
	self assert: (abd attributeNamed: #d) originalRelation = abc.
	self assert: (abc attributeNamed: #c) originalAttribute 
		    = (abc attributeNamed: #c).
	self assert: (abd attributeNamed: #d) originalAttribute 
		    = (abc attributeNamed: #c)
    ]

    testPrinting [
	"commented out cause I'm not sure we care"

	"self assert: abc prints: 'abc'.
	 self assert: def prints: 'def'.
	 self assert: abcdef prints: '(abc) * (def)'.
	 self assert: ab prints: '(abc) projectAll: #(#a #b)'.
	 self assert: fe prints: '(def) projectAll: #(#f #e)'.
	 self assert: abd prints: '(abc) renameAll: #(#c) to: #(#d)'.
	 self assert: geh prints: '(def) renameAll: #(#d #f) to: #(#g #h)'.
	 self assert: abqe prints: '((abc) projectAll: #(#a #b)) * ( X R[f->q](P[f,e](def))'.
	 self assert: aLT2 prints: 'S[(a<2)](abc)'.
	 self assert: bEQfoo prints: 'S[((b=''foo'')&(a>=(c*2)))](abc)'.
	 self assert: abcSquared prints: 'abc X R[a->a1,b->b1,c->c1](abc)'.
	 self assert: abcGBa prints: 'G[a](abc)'.
	 self assert: abcGBab prints: 'G[a,b](abc)'.
	 self assert: abcOBaa prints: 'O[a->asc](abc)'.
	 self assert: abcOBad prints: 'O[a->desc](abc)'.
	 self assert: abcOBaabd prints: 'O[a->asc,b->desc](abc)'.
	 self assert: abcEabc prints: 'abc \ abc'.
	 self assert: abcUabc prints: 'abc u abc'.
	 self assert: abcIabc prints: 'abc n abc'.
	 self assert: abcD prints: '{abc}'.
	 self assert: abcI prints: 'I[10,15](abc)'."

	<category: 'testing'>
	
    ]

    testPrintingAlgebraic [
	<category: 'testing'>
	self assert: abc asAlgebraicString = 'abc'.
	self assert: def asAlgebraicString = 'def'.
	self assert: abcdef asAlgebraicString = 'abc X def'.
	self assert: ab asAlgebraicString = 'P[a,b](abc)'.
	self assert: fe asAlgebraicString = 'P[f,e](def)'.
	self assert: abd asAlgebraicString = 'R[c->d](abc)'.
	self assert: geh asAlgebraicString = 'R[d->g,f->h](def)'.
	self assert: abqe asAlgebraicString = 'P[a,b](abc) X R[f->q](P[f,e](def))'.
	self assert: aLT2 asAlgebraicString = 'S[(a<2)](abc)'.
	self assert: bEQfoo asAlgebraicString = 'S[((b=''foo'')&(a>=(c*2)))](abc)'.
	self 
	    assert: abcSquared asAlgebraicString = 'abc X R[a->a1,b->b1,c->c1](abc)'.
	self assert: abcGBa asAlgebraicString = 'G[a](abc)'.
	self assert: abcGBab asAlgebraicString = 'G[a,b](abc)'.
	self assert: abcOBaa asAlgebraicString = 'O[a->asc](abc)'.
	self assert: abcOBad asAlgebraicString = 'O[a->desc](abc)'.
	self assert: abcOBaabd asAlgebraicString = 'O[a->asc,b->desc](abc)'.
	self assert: abcEabc asAlgebraicString = 'abc \ abc'.
	self assert: abcUabc asAlgebraicString = 'abc u abc'.
	self assert: abcIabc asAlgebraicString = 'abc n abc'.
	self assert: abcD asAlgebraicString = '{abc}'.
	self assert: abcI asAlgebraicString = 'I[10,15](abc)'
    ]

    testPrintingSql [
	<category: 'testing'>
	| notNullQuery nullQuery dateQuery trueQuery dummyRelation |
	dummyRelation := RASQLRelation basicNew.
	notNullQuery := abc select: [:ea | ea a ~= nil].
	self assert: (RASqlPrinter print: notNullQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1 IS NOT NULL)'.
	nullQuery := abc select: [:ea | ea a = nil].
	self assert: (RASqlPrinter print: nullQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1 IS NULL)'.
	dateQuery := abc 
		    select: [:ea | ea a = (Date 
				    newDay: 10
				    monthIndex: 11
				    year: 2006)].
	self assert: (RASqlPrinter print: dateQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1=''10-Nov-2006'')'.
	trueQuery := abc select: [:ea | ea a = true].
	self assert: (RASqlPrinter print: trueQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1=''true'')'
    ]
]


Object subclass: RAMockObject [
    
    <category: 'Roe-Tests'>
    <comment: nil>

    RAMockObject class >> fromValues: aDictionary [
	^self new initializeWithValues: aDictionary
    ]

    initializeWithValues: aDictionary [
	<category: 'initialize-release'>
	
    ]
]



RAMockObject subclass: RAMockCourse [
    | title |
    
    <category: 'Roe-Tests'>
    <comment: nil>

    initializeWithValues: aDictionary [
	<category: 'initialize-release'>
	title := aDictionary at: #title
    ]
]



RAMockObject subclass: RAMockStudent [
    | name |
    
    <category: 'Roe-Tests'>
    <comment: nil>

    initializeWithValues: aDictionary [
	<category: 'initialize-release'>
	name := aDictionary at: #name
    ]
]



Object extend [
    asString [
	^self printString
    ]
]

