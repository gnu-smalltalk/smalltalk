"======================================================================
|
|   VisualWorks XSL Framework
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000, 2002 Cincom, Inc.
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



Namespace current: XSL [

XML.NodeBuilder subclass: XSLNodeBuilder [
    | nodeNameMap |
    
    <comment: nil>
    <category: 'XSL-XSL-Support'>

    makeText: text [
	<category: 'building'>
	^TextTemplate text: text
    ]

    pi: nm text: text [
	<category: 'building'>
	^XSL_PI new name: nm text: text
    ]

    tag: tag attributes: attributes elements: elements position: p stream: stream [
	<category: 'building'>
	| elementClass |
	elementClass := tag namespace = XSL_URI 
		    ifTrue: 
			[self nodeNameMap at: tag type
			    ifAbsent: 
				[self error: 'The action ' , tag asString , ' is not yet implemented']]
		    ifFalse: [Template].
	^elementClass 
	    tag: tag
	    attributes: attributes
	    elements: elements
    ]

    nodeNameMap [
	<category: 'private'>
	nodeNameMap == nil 
	    ifTrue: 
		[nodeNameMap := Dictionary new.
		XSLCommand withAllSubclasses 
		    do: [:beh | beh tag == nil ifFalse: [nodeNameMap at: beh tag put: beh]]].
	^nodeNameMap
    ]
]

]



Namespace current: XSL [

XML.XPathNodeContext subclass: XSLNodeContext [
    | db mode |
    
    <comment: nil>
    <category: 'XSL-XSL-XSL'>

    db [
	<category: 'accessing'>
	^db
    ]

    db: aRuleDatabase [
	<category: 'accessing'>
	db := aRuleDatabase
    ]

    mode [
	<category: 'accessing'>
	^mode
    ]

    mode: aSymbol [
	<category: 'accessing'>
	mode := aSymbol
    ]
]

]



Namespace current: XSL [

Object subclass: RuleDatabase [
    | rules variables normalized namedTemplates attributeSets currentImportance uriStack output |
    
    <import: XML>
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    RuleDatabase class >> constructXML [
	"RuleDatabase constructXML"

	<category: 'XML for examples'>
	^'<doc a="1" b="2">
    <title c="3" d="4">An example</title>
    <p k="xyz">This is a test.</p>
    <p>This is <emph>another</emph> test.</p>
    </doc>'
    ]

    RuleDatabase class >> constructXSL [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			indent-result="yes">
    	<xsl:variable name="tag" select="$tag2"/>
    	<xsl:variable name="tag2" select="''new''"/>

    	<xsl:template match="*">
    		<xsl:element name="{$tag}-{name(.)}">
    			<xsl:for-each select="@*">
    				<xsl:attribute name="{name(.)}-copy">
    					..<xsl:value-of select="."/>..
    				</xsl:attribute>
    			</xsl:for-each>
    			<xsl:apply-templates/>
    		</xsl:element>
    	</xsl:template>

    	<xsl:template match="p" priority="1">
    		<xsl:copy>
    			<xsl:apply-templates select="@*|*|text()"/>
    		</xsl:copy>
    	</xsl:template>

    	<xsl:template match="p/@*">
    		<xsl:copy>
    			<xsl:apply-templates select="text()"/>
    		</xsl:copy>
    	</xsl:template>
    </xsl:stylesheet>'
    ]

    RuleDatabase class >> macroXML [
	<category: 'XML for examples'>
	^'<?xml version="1.0"?>

    <doc>
    	<p>a paragraph</p>
    	<p>another paragraph</p>
    	<warning>the warning</warning>
    	<p>closing paragraph</p>
    	<warning>warning 2</warning>
    	<warning>warning 3</warning>
    	<list>
    		<item><surname>Smith</surname><name>Joe</name><MI>G.</MI></item>
    		<item><surname>Jones</surname><name>John</name><MI>P.</MI></item>
    		<item><surname>Smith</surname><name>Bill</name><MI>M.</MI></item>
    		<item><surname>Bell</surname><name>Alexander</name><MI>G.</MI></item>
    		<item><surname>Smith</surname><name>Bill</name><MI>A.</MI></item>
    	</list>
    </doc>'
    ]

    RuleDatabase class >> macroXSL [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			indent-result="yes">
    	<xsl:template name="warning-para">
    		<xsl:param name="format" select="''1. ''"/>
    		<xsl:param name="content"/>
    		<box font-color="red">
    			<xsl:number format="{$format}"/>
    			<xsl:text>Warning! </xsl:text>
    			<xsl:copy-of select="$content"/>
    		</box>
    	</xsl:template>

    	<xsl:template match=''p|doc''>
    		<xsl:copy><xsl:apply-templates/></xsl:copy>
    	</xsl:template>

    	<xsl:template match=''warning''>
    		<xsl:call-template name="warning-para">
    			<xsl:with-param name="format" select="''A. ''"/>
    			<xsl:with-param name="content">
    				<xsl:apply-templates/>
    				<xsl:text> (see appendix)</xsl:text>
    			</xsl:with-param>
    		</xsl:call-template>
    	</xsl:template>

    	<xsl:template match=''list''>
    		<list>
    			<xsl:apply-templates select="item">
    				<xsl:sort select="surname" order="ascending"/>
    				<xsl:sort select="name" order="descending"/>
    			</xsl:apply-templates>
    		</list>
    	</xsl:template>

    	<xsl:template match=''item''>
    		<name>
    			<xsl:value-of select="name"/>
    			<xsl:text> </xsl:text>
    			<xsl:value-of select="MI"/>
    			<xsl:text> </xsl:text>
    			<xsl:value-of select="surname"/>
    		</name>
    	</xsl:template>

    </xsl:stylesheet>'
    ]

    RuleDatabase class >> numberedSourceData [
	<category: 'XML for examples'>
	^'1. Overview
2. Tree Construction
    2.1 Overview
    2.2 Stylesheet Structure
    2.3 Processing Model
    2.4 Data Model
    	2.4.1 Root Node
    	2.4.2 Element Nodes
    	2.4.3 Attribute Nodes
    	2.4.4 Character Data
    	2.4.5 Whitespace Stripping
    2.5 Template Rules
    	2.5.1 Conflict Resolution for Template Rules
    	2.5.2 Built-in Template Rule
    2.6 Patterns
    	2.6.1 Alternative Patterns
    	2.6.2 Matching on Element Ancestry
    	2.6.3 Anchors
    	2.6.4 Matching the Root Node
    	2.6.5 Matching on Element Types
    	2.6.6 Qualifiers
    	2.6.7 Matching on Children
    	2.6.8 Matching on Attributes
    	2.6.9 Matching on Position
    	2.6.10 Whitespace in Patterns
    	2.6.11 Specificity
    2.7 Templates
    	2.7.1 Overview
    	2.7.2 Literal Result Elements
    	2.7.3 Named Attribute Sets
    	2.7.4 Literal Text in Templates
    	2.7.5 Processing with xsl:process-children
    	2.7.6 Processing with xsl:process
    	2.7.7 Direct Processing
    	2.7.8 Numbering in the Source Tree
    	2.7.9 Number to String Conversion Attributes
    	2.7.10 Conditionals within a Template
    	2.7.11 Computing Generated Text
    	2.7.12 String Constants
    	2.7.13 Macros
    2.8 Style Rules
    2.9 Combining Stylesheets
    	2.9.1 Stylesheet Import
    	2.9.2 Stylesheet Inclusion
    	2.9.3 Embedding Stylesheets
    2.10 Extensibility
3. Formatting Objects
    3.1 Introduction
    3.2 Notations Used in this Section
    3.3 Formatting Objects and Their Properties
    3.4 Formatting Objects to be Defined in Subsequent Drafts
    3.5 Page-sequence Layout Object
    	3.5.1 Purpose
    	3.5.2 Formatting Object Summary
    	3.5.3 Formatting Object''s Formal Specification
    	3.5.4 To Resolve
    3.6 Simple-page-master Layout Object
    	3.6.1 Purpose
    	3.6.2 Formatting Object Summary
    	3.6.3 Formatting Object''s Formal Specification
    	3.6.4 To Resolve
A. DTD for XSL Stylesheets
B. References
    B.1 Normative References
    B.2 Other References
C. Examples (Non-Normative)
D. Design Principles (Non-Normative)
E. Acknowledgements (Non-Normative)
'
    ]

    RuleDatabase class >> numberedXML [
	"RuleDatabase numberedXML"

	<category: 'XML for examples'>
	| src stack str depth parent title tag |
	stack := OrderedCollection new.
	stack add: (Element tag: 'doc').
	src := self numberedSourceData readStream.
	[src atEnd] whileFalse: 
		[str := src upTo: Character nl.
		depth := str occurrencesOf: Character tab.
		str := str copyFrom: depth + 1 to: str size.
		tag := depth = 0 
			    ifTrue: [str first isDigit ifTrue: ['chapter'] ifFalse: ['appendix']]
			    ifFalse: [#('section' 'subsection') at: depth].
		str := str copyFrom: (str indexOf: $ ) + 1 to: str size.
		[depth + 1 = stack size] whileFalse: [stack removeLast].
		parent := stack last.
		title := Text text: str.
		title := Element tag: 'title' elements: (Array with: title).
		title := Element tag: tag elements: (Array with: title).
		stack addLast: title.
		parent elements: (parent children copyWith: title)].
	^stack first printString
    ]

    RuleDatabase class >> numberedXML2 [
	"RuleDatabase numberedXML2"

	<category: 'XML for examples'>
	| src stack str depth title tag |
	stack := OrderedCollection new.
	stack add: (Element tag: 'doc').
	src := self numberedSourceData readStream.
	[src atEnd] whileFalse: 
		[str := src upTo: Character nl.
		depth := str occurrencesOf: Character tab.
		str := str copyFrom: depth + 1 to: str size.
		tag := depth = 0 ifTrue: ['H1'] ifFalse: [#('H2' 'H3' 'H4') at: depth].
		str := str copyFrom: (str indexOf: $ ) + 1 to: str size.
		title := Text text: str.
		title := Element tag: tag elements: (Array with: title).
		stack last elements: (stack last children copyWith: title)].
	^stack first printString
    ]

    RuleDatabase class >> numberedXSL [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			xmlns:fo="http://www.w3.org/1999/XSL/Transform/FO"
    			result-ns="fo"
    			indent-result="yes">
    	<xsl:template match="doc">
    		<html>
    		<body>
    			<xsl:apply-templates/>
    		</body>
    		</html>
    	</xsl:template>

    	<xsl:template match="*" priority="-10">
    		<UL>
    			<xsl:apply-templates/>
    		</UL>
    	</xsl:template>

    	<xsl:template match="title">
    		<LI>
    			<xsl:number level="multi"
    					count="chapter|section|subsection"
    					format="1. "/>
    			<xsl:apply-templates/>
    		</LI>
    	</xsl:template>

    	<xsl:template match="appendix//title" priority="1">
    		<LI>
    			<xsl:number level="multi"
    					count="appendix|section|subsection"
    					format="I.a. "/>
    			<xsl:apply-templates/>
    		</LI>
    	</xsl:template>
    </xsl:stylesheet>'
    ]

    RuleDatabase class >> numberedXSL1 [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			xmlns:fo="http://www.w3.org/1999/XSL/Transform/FO"
    			result-ns="fo"
    			indent-result="yes">
    	<xsl:template match="doc">
    		<html>
    		<body>
    			<xsl:apply-templates/>
    		</body>
    		</html>
    	</xsl:template>

    	<xsl:template match="*" priority="-10">
    		<UL>
    			<xsl:apply-templates/>
    		</UL>
    	</xsl:template>

    	<xsl:template match="title">
    		<LI>
    			<xsl:number level="single"
    					count="chapter|section|subsection"
    					format="1. "/>
    			<xsl:apply-templates/>
    		</LI>
    	</xsl:template>

    	<xsl:template match="appendix//title" priority="1">
    		<LI>
    			<xsl:number level="single"
    					count="appendix|section|subsection"
    					format="I. "/>
    			<xsl:apply-templates/>
    		</LI>
    	</xsl:template>
    </xsl:stylesheet>'
    ]

    RuleDatabase class >> numberedXSL2 [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			xmlns:fo="http://www.w3.org/1999/XSL/Transform/FO"
    			result-ns="fo"
    			indent-result="yes">
    	<xsl:template match="doc">
    		<html>
    		<body>
    			<xsl:apply-templates/>
    		</body>
    		</html>
    	</xsl:template>

    	<xsl:template match="H3">
    		<fo:block>
    			<xsl:number level="any" count="H1"/>
    			<xsl:text>.</xsl:text>
    			<xsl:number level="any" from="H1" count="H2"/>
    			<xsl:text>.</xsl:text>
    			<xsl:number level="any" from="H2" count="H3"/>
    			<xsl:text> </xsl:text>
    			<xsl:apply-templates/>
    		</fo:block>
    	</xsl:template>

    	<xsl:template match="H2">
    		<fo:block>
    			<xsl:number level="any" count="H1"/>
    			<xsl:text>.</xsl:text>
    			<xsl:number level="any" from="H1" count="H2"/>
    			<xsl:text> </xsl:text>
    			<xsl:apply-templates/>
    		</fo:block>
    	</xsl:template>

    	<xsl:template match="H1">
    		<fo:block>
    			<xsl:number level="any" count="H1"/>
    			<xsl:text> </xsl:text>
    			<xsl:apply-templates/>
    		</fo:block>
    	</xsl:template>

    </xsl:stylesheet>'
    ]

    RuleDatabase class >> patternsXML [
	<category: 'XML for examples'>
	^'<?xml version="1.0"?>

    <!DOCTYPE a [
    	<!ELEMENT a (a | b | c)*>
    	<!ELEMENT b (#PCDATA | c)*>
    	<!ELEMENT c (#PCDATA)>
    	<!ATTLIST a
    		x ID #IMPLIED
    		y CDATA #IMPLIED>
    ]>

    <a x="top">
    	<a x="c1" y="tester">
    		<b><c>title</c>
    		body of chapter1</b>
    		<b><c>subsection</c>
    		more of chapter 1</b>
    	</a>
    	<a x="c2">
    		<b><c>title2</c>
    		body of chapter 2</b>
    	</a>
    </a>'
    ]

    RuleDatabase class >> patternsXSL [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			indent-result="yes">
    	<xsl:template match=''/''>
    		<xsl:comment>--------------------</xsl:comment>
    		<xsl:apply-templates/>
    		<xsl:pi name="vwst">arg1="class" arg2="Array"</xsl:pi>
    	</xsl:template>

    	<xsl:template match=''a''>
    		<div><xsl:apply-templates/></div>
    	</xsl:template>

    	<xsl:template match=''b''>
    		<span><xsl:apply-templates/></span>
    	</xsl:template>

    	<xsl:template match=''c''>
    		<H1><xsl:apply-templates/></H1>
    	</xsl:template>

    	<xsl:template match=''a[@y="tester"]//c'' priority="1">
    		<H1 attr="test"><xsl:apply-templates/></H1>
    		<H2 attr="test"><xsl:value-of select=''id("c2")/b/c''/></H2>
    	</xsl:template>

    </xsl:stylesheet>'
    ]

    RuleDatabase class >> sampleXML [
	<category: 'XML for examples'>
	^'<doc>
    <title>An example</title>
    <p>This is a test.</p>
    <p>This is <emph>another</emph> test.</p>
    </doc>'
    ]

    RuleDatabase class >> sampleXSL [
	<category: 'XML for examples'>
	^'<?xml version=''1.0''?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    			xmlns:fo="http://www.w3.org/1999/XSL/Transform/FO"
    			result-ns="fo"
    			indent-result="yes">
    	<xsl:template match=''/''>
    		<fo:page-sequence font-family="serif">
    			<fo:simple-page-master name=''scrolling''/>
    			<fo:queue queue-name=''body''>
    				<xsl:apply-templates/>
    			</fo:queue>
    		</fo:page-sequence>
    	</xsl:template>

    	<xsl:template match="title">
    		<fo:block font-weight="bold">
    			<xsl:apply-templates/>
    		</fo:block>
    	</xsl:template>

    	<xsl:template match="p">
    		<fo:block>
    			<xsl:apply-templates/>
    		</fo:block>
    	</xsl:template>

    	<xsl:template match="emph">
    		<fo:sequence font-style="italic">
    			<xsl:apply-templates/>
    		</fo:sequence>
    	</xsl:template>

    </xsl:stylesheet>'
    ]

    RuleDatabase class >> allTest [
	"XSL.RuleDatabase allTest"

	<category: 'examples'>
	| sel |
	sel := self class selectors select: [:s | 'test*' match: s].
	sel asSortedCollection do: [:s | self perform: s]
    ]

    RuleDatabase class >> examplesDirectory [
	<category: 'examples'>
	^Directory image / 'xml'
    ]

    RuleDatabase class >> store: document on: filename [
	<category: 'examples'>
	(FileStream open: filename mode: FileStream write)
	    print: document;
	    close
    ]

    RuleDatabase class >> test [
	"RuleDatabase test"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self sampleXSL.
	doc := XMLParser processDocumentString: self sampleXML
		    beforeScanDo: [:parser | parser validate: false].
	^test process: doc
    ]

    RuleDatabase class >> test2 [
	"RuleDatabase test2"

	<category: 'examples'>
	| test doc default result |
	default := self examplesDirectory.
	test := self new.
	test readFileNamed: (default nameAt: 'activityinfo.xsl').
	doc := XMLParser 
		    processDocumentInFilename: (default nameAt: 'activityinfo.xml')
		    beforeScanDo: [:parser | parser validate: false].
	result := test process: doc.
	self store: result on: 'activityinfo.html'
    ]

    RuleDatabase class >> test2a [
	"RuleDatabase test2a"

	<category: 'examples'>
	| test doc default result |
	default := self examplesDirectory.
	test := self new.
	test readFileNamed: (default nameAt: 'activityinfo2.xsl').
	doc := XMLParser 
		    processDocumentInFilename: (default nameAt: 'activityinfo.xml')
		    beforeScanDo: [:parser | parser validate: false].
	result := test process: doc.
	self store: result on: 'activityinfo2.html'
    ]

    RuleDatabase class >> test2b [
	"RuleDatabase test2b"

	<category: 'examples'>
	| test doc default result |
	default := self examplesDirectory.
	test := self new.
	test readFileNamed: (default nameAt: 'activityinfo3.xsl').
	doc := XMLParser 
		    processDocumentInFilename: (default nameAt: 'activityinfo.xml')
		    beforeScanDo: [:parser | parser validate: false].
	result := test process: doc.
	self store: result on: 'activityinfo3.html'
    ]

    RuleDatabase class >> test3 [
	"RuleDatabase test3"

	<category: 'examples'>
	| test doc default result |
	default := self examplesDirectory.
	test := self new.
	test readFileNamed: (default nameAt: 'listgen.xsl').
	doc := XMLParser 
		    processDocumentInFilename: (default nameAt: 'listgen.xml')
		    beforeScanDo: [:parser | parser validate: false].
	result := test process: doc.
	self store: result on: 'listgen.html'
    ]

    RuleDatabase class >> test4 [
	"RuleDatabase test4"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self numberedXSL.
	doc := XMLParser processDocumentString: self numberedXML
		    beforeScanDo: [:parser | parser validate: false].
	^test process: doc
    ]

    RuleDatabase class >> test4a [
	"RuleDatabase test4a"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self numberedXSL1.
	doc := XMLParser processDocumentString: self numberedXML
		    beforeScanDo: [:parser | parser validate: false].
	^test process: doc
    ]

    RuleDatabase class >> test4b [
	"RuleDatabase test4b"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self numberedXSL2.
	doc := XMLParser processDocumentString: self numberedXML2
		    beforeScanDo: [:parser | parser validate: false].
	^test process: doc
    ]

    RuleDatabase class >> test5 [
	"RuleDatabase test5"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self constructXSL.
	doc := XMLParser processDocumentString: self constructXML
		    beforeScanDo: [:parser | parser validate: false].
	^test process: doc
    ]

    RuleDatabase class >> test6 [
	"RuleDatabase test6"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self patternsXSL.
	doc := XMLParser processDocumentString: self patternsXML.
	^test process: doc
    ]

    RuleDatabase class >> test7 [
	"RuleDatabase test7"

	<category: 'examples'>
	| test doc |
	test := self new.
	test readString: self macroXSL.
	doc := XMLParser processDocumentString: self macroXML
		    beforeScanDo: [:parser | parser validate: false].
	^test process: doc
    ]

    RuleDatabase class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    importance [
	<category: 'importance'>
	^currentImportance
    ]

    importance: aValueHolder [
	<category: 'importance'>
	currentImportance := aValueHolder
    ]

    raiseImportance [
	<category: 'importance'>
	currentImportance := (currentImportance value + 1) asValue
    ]

    replaceImportance: oldValue [
	<category: 'importance'>
	variables 
	    do: [:clist | clist do: [:c | c replaceImportance: oldValue with: currentImportance]].
	namedTemplates 
	    do: [:mlist | mlist do: [:m | m replaceImportance: oldValue with: currentImportance]].
	rules do: [:r | r replaceImportance: oldValue with: currentImportance]
    ]

    addAttributeSet: anAttributeSet [
	<category: 'loading'>
	| all |
	anAttributeSet importanceHolder: currentImportance.
	all := attributeSets at: anAttributeSet name
		    ifAbsentPut: [OrderedCollection new].
	all add: anAttributeSet
    ]

    addNamedTemplate: aRule [
	<category: 'loading'>
	| all |
	aRule importanceHolder: currentImportance.
	all := namedTemplates at: aRule name ifAbsentPut: [OrderedCollection new].
	(all contains: [:c | c importance = currentImportance value]) 
	    ifTrue: 
		[self 
		    error: 'There are two named templates named %1 with the same importance' 
			    % {aRule name}].
	all add: aRule
    ]

    addRule: aRule [
	<category: 'loading'>
	aRule importanceHolder: currentImportance.
	rules add: aRule
    ]

    addRuleSet: anXSLCommand topLevel: isTopLevel [
	<category: 'loading'>
	anXSLCommand purgeUnimportant.
	isTopLevel 
	    ifTrue: [anXSLCommand topLevelAddToRuleDB: self]
	    ifFalse: [anXSLCommand addToRuleDB: self]
    ]

    addVariable: aVariable [
	<category: 'loading'>
	| all |
	aVariable importanceHolder: currentImportance.
	all := variables at: aVariable name ifAbsentPut: [OrderedCollection new].
	(all contains: [:c | c importance = currentImportance value]) 
	    ifTrue: 
		[self error: 'There are two variables named %1 with the same importance' 
			    % {aVariable name}].
	all add: aVariable
    ]

    attributesForSet: setName [
	<category: 'loading'>
	| list map |
	list := attributeSets at: setName
		    ifAbsent: [self error: 'No attribute set named "%1".' % {setName asString}].
	map := Dictionary new.
	list do: 
		[:as | 
		(as allAttributesFrom: self) do: 
			[:attr | 
			(map at: attr name
			    ifAbsentPut: [SortedCollection sortBlock: [:a1 :a2 | a1 key > a2 key]]) 
				add: as importance -> attr]].
	list := OrderedCollection new.
	map do: 
		[:singleList | 
		(singleList size > 1 
		    and: [(singleList at: 1) key = (singleList at: 2) key]) 
			ifTrue: 
			    [self 
				error: 'Attribute set "%1" includes more than one definition of the attribute "%2".' 
					% 
					    {setName asString.
					    singleList first name asString}].
		list add: singleList first value].
	^list
    ]

    bindVariableValues: aNodeContext arguments: argDictionary [
	<category: 'loading'>
	variables do: 
		[:var | 
		var 
		    process: aNodeContext
		    into: nil
		    takeArgumentsFrom: argDictionary]
    ]

    normalizeRules [
	<category: 'loading'>
	normalized ifTrue: [^self].
	normalized := true.
	self normalizeVariables.
	namedTemplates keys do: 
		[:nm | 
		| clist |
		clist := namedTemplates at: nm.
		(clist collect: [:c | c importance]) asSet size = clist size 
		    ifFalse: 
			[self error: 'Named template named "' , nm 
				    , '" has more than one definition with the same importance'].
		namedTemplates at: nm
		    put: (clist asSortedCollection: [:c1 :c2 | c1 importance < c2 importance]) 
			    last].
	namedTemplates do: [:m | m normalize].
	rules do: [:r | r normalize]
    ]

    normalizeVariables [
	<category: 'loading'>
	| unsorted sorted lastSize list |
	variables class == Dictionary ifFalse: [^self].
	variables keys do: 
		[:nm | 
		| clist |
		clist := variables at: nm.
		(clist collect: [:c | c importance]) asSet size = clist size 
		    ifFalse: 
			[self error: 'Variable named "' , nm 
				    , '" has more than one definition with the same importance'].
		variables at: nm
		    put: (clist asSortedCollection: [:c1 :c2 | c1 importance < c2 importance]) 
			    last].
	variables do: [:c | c normalize].
	unsorted := variables asOrderedCollection.
	sorted := OrderedCollection new.
	lastSize := -1.
	[sorted size = lastSize] whileFalse: 
		[lastSize := sorted size.
		unsorted copy do: 
			[:var | 
			list := var expression xpathUsedVarNames.
			list := list reject: [:nm | sorted includes: nm].
			list isEmpty 
			    ifTrue: 
				[sorted add: var name.
				unsorted remove: var]]].
	unsorted isEmpty 
	    ifFalse: [self error: 'There is a cycle of reference between the variables'].
	variables := sorted collect: [:v | variables at: v]
    ]

    readFileNamed: aFilename [
	<category: 'loading'>
	| doc |
	self initURI: 'file' name: aFilename asString.
	doc := XMLParser processDocumentInFilename: aFilename
		    beforeScanDo: 
			[:parser | 
			parser builder: XSLNodeBuilder new.
			parser validate: false].
	self addRuleSet: doc root topLevel: true
    ]

    readStream: aStream [
	<category: 'loading'>
	self readStream: aStream topLevel: true
    ]

    readStream: aStream topLevel: isTopLevel [
	<category: 'loading'>
	| doc parser |
	parser := XMLParser on: aStream.
	parser builder: XSLNodeBuilder new.
	parser validate: false.
	doc := parser scanDocument.
	self addRuleSet: doc root topLevel: isTopLevel
    ]

    readString: aString [
	<category: 'loading'>
	| doc |
	self initURI: 'file' name: (Directory working / 'xxx') name.
	doc := XMLParser processDocumentString: aString
		    beforeScanDo: 
			[:parser | 
			parser builder: XSLNodeBuilder new.
			parser validate: false].
	self addRuleSet: doc root topLevel: true
    ]

    resolveAttributesForSet: setName [
	<category: 'loading'>
	| list |
	list := attributeSets at: setName
		    ifAbsent: [self error: 'No attribute set named "%1".' % {setName asString}]
    ]

    setOutput: anOutputCommand [
	<category: 'loading'>
	output := anOutputCommand
    ]

    uriStack [
	<category: 'loading'>
	^uriStack
    ]

    chooseBestRule: ruleList for: aNodeContext [
	<category: 'processing'>
	| best |
	ruleList size = 1 ifTrue: [^ruleList first].
	best := ruleList 
		    asSortedCollection: [:r1 :r2 | r1 importance >= r2 importance].
	best := best asOrderedCollection 
		    select: [:r1 | r1 importance = best first importance].
	best size = 1 ifTrue: [^best first].
	best := best collect: [:r1 | r1 priority -> r1].
	best := best asSortedCollection: [:a1 :a2 | a1 > a2].
	best := best asOrderedCollection select: [:a1 | a1 key = best first key].
	best := best collect: [:a | a value].
	best size = 1 ifTrue: [^best first].
	best size = 0 
	    ifFalse: 
		[self halt: 'Conflicting rules for ' , aNodeContext node simpleDescription 
			    , ', use priority to rank the rules.'.
		^best last].
	^nil
    ]

    process: aDocument [
	<category: 'processing'>
	^self process: aDocument arguments: Dictionary new
    ]

    process: aDocument arguments: passedArguments [
	<category: 'processing'>
	| doc baseDoc baseVars |
	self normalizeRules.
	doc := DocumentFragment new.
	baseVars := Dictionary new.
	baseDoc := (XSLNodeContext new)
		    add: aDocument;
		    index: 1;
		    variables: baseVars;
		    db: self.
	self bindVariableValues: baseDoc arguments: passedArguments.
	baseDoc variables: (ChainedDictionary new parent: baseVars).
	(self 
	    process: baseDoc
	    into: ElementProxy new
	    mode: nil) children 
	    do: [:elm | doc addNode: elm].
	doc addNamespaceDefinitions.
	^doc
    ]

    process: aNodeContext into: aProxy mode: mode [
	<category: 'processing'>
	| rule list |
	list := rules select: [:r | r match: aNodeContext].
	list := list select: [:r | r modeIsLike: mode].
	rule := self chooseBestRule: list for: aNodeContext.
	rule == nil 
	    ifFalse: 
		[rule 
		    process: aNodeContext
		    into: aProxy
		    arguments: #()].
	^aProxy
    ]

    ruleMatching: aNodeContext mode: mode [
	<category: 'processing'>
	| rule list |
	list := OrderedCollection new: 5.
	1 to: rules size
	    do: 
		[:i | 
		rule := rules at: i.
		((rule modeIsLike: mode) and: [rule match: aNodeContext]) 
		    ifTrue: [list add: rule]].
	"list := rules select: [:r | r match: aNodeContext].
	 list := list select: [:r | r modeIsLike: mode]."
	rule := self chooseBestRule: list for: aNodeContext.
	^rule
    ]

    ruleNamed: aName [
	<category: 'processing'>
	^namedTemplates at: aName ifAbsent: []
    ]

    initialize [
	<category: 'initialize'>
	| baseRule action builtinImportance |
	normalized := false.
	rules := OrderedCollection new.
	variables := Dictionary new.
	namedTemplates := Dictionary new.
	attributeSets := Dictionary new.
	currentImportance := 1 asValue.
	builtinImportance := 0 asValue.
	action := ApplyTemplatesCommand new.
	baseRule := Rule new.
	baseRule mode: #any.
	baseRule attributes: (Array with: (Attribute name: 'match' value: '*|/')).
	baseRule elements: (Array with: action).
	baseRule importanceHolder: builtinImportance.
	rules add: baseRule.
	action := ValueOfCommand new.
	action attributes: (Array with: (Attribute name: 'select' value: '.')).
	baseRule := Rule new.
	baseRule mode: #any.
	baseRule 
	    attributes: (Array with: (Attribute name: 'match' value: 'text()')).
	baseRule elements: (Array with: action).
	baseRule importanceHolder: builtinImportance.
	rules add: baseRule
    ]

    initURI: aProtocol name: aName [
	<category: 'initialize'>
	uriStack == nil 
	    ifTrue: 
		[uriStack := OrderedCollection with: aProtocol 
				    -> (aName copy asString replaceAll: Directory pathSeparator with: $/)]
    ]

    output [
	<category: 'accessing'>
	output == nil ifTrue: [output := OutputCommand new].
	^output
    ]

    outputMethodFor: aDocument [
	<category: 'accessing'>
	| rt |
	self output method = #auto ifFalse: [^self output method].
	rt := aDocument root.
	(rt notNil 
	    and: [rt tag namespace isEmpty and: [rt tag type asLowercase = 'html']]) 
		ifTrue: [^'html'].
	^'xml'
    ]
]

]



Namespace current: XSL [

XML.Text subclass: DenormalizedText [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    saxDo: aDriver [
	<category: 'enumerating'>
	[aDriver normalizeText: false] on: Error do: [:dummy | ].
	super saxDo: aDriver.
	[aDriver normalizeText: true] on: Error do: [:dummy | ]
    ]
]

]



Namespace current: XSL [

XML.Element subclass: XSLCommand [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    XPathExtensionFunctions := nil.

    XSLCommand class >> tag [
	<category: 'accessing'>
	^nil
    ]

    XSLCommand class >> xslFunctions [
	<category: 'accessing'>
	^XPathExtensionFunctions
    ]

    XSLCommand class >> formatNumber: aNumber pattern: pattern formatName: formatName in: aNodeContext [
	<category: 'xpath'>
	^aNumber xpathAsString
    ]

    XSLCommand class >> initialize [
	"XSLCommand initialize"

	<category: 'class initialization'>
	| functions |
	functions := ChainedDictionary new.
	functions parent: XPathFunction baseFunctions.
	functions at: 'format-number'
	    put: ((XPathFunction new)
		    name: 'format-number';
		    valueBlock: 
			    [:fn :ns | 
			    | n s1 s2 |
			    (fn arguments size between: 2 and: 3) 
				ifFalse: [self error: 'format-number() takes two or three arguments.'].
			    n := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsNumber.
			    s1 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
			    fn arguments size = 3 
				ifTrue: [s2 := ((fn arguments at: 3) xpathEvalIn: ns) xpathAsString]
				ifFalse: [s2 := nil].
			    self 
				formatNumber: n
				pattern: s1
				formatName: s2
				in: ns]).
	XPathExtensionFunctions := functions
    ]

    checkQNameSyntax: aString [
	<category: 'private'>
	| str mode colons ch valid |
	str := aString readStream.
	mode := #colon.
	colons := 0.
	[str atEnd] whileFalse: 
		[ch := str next.
		mode == #colon 
		    ifTrue: 
			[valid := ch = $_ or: [ch isLetter].
			mode := #letter]
		    ifFalse: 
			[ch = $: 
			    ifTrue: 
				[valid := true.
				colons := colons + 1.
				mode := #colon]
			    ifFalse: 
				[valid := ch isLetter or: [ch isDigit or: ['.-_' includes: ch]].
				mode := #letterOrDigit]].
		valid ifFalse: [self error: 'Syntax error in qualified name.']].
	(mode = #colon or: [colons > 1]) 
	    ifTrue: [self error: 'Syntax error in qualified name.']
    ]

    checkURISyntax: aString [
	<category: 'private'>
	| n type ch |
	n := aString findLast: [:c | c = $#].
	n = aString size 
	    ifTrue: 
		[self 
		    error: 'The name for an attribute or element, using the x#y syntax, has no type following the #.'].
	type := aString copyFrom: n + 1 to: aString size.
	ch := type at: 1.
	(ch = $_ or: [ch isLetter]) 
	    ifFalse: [self error: 'Type name syntax error in "%1".' % {type}].
	2 to: type size
	    do: 
		[:i | 
		ch := type at: i.
		(ch isLetter or: [ch isDigit or: ['.-_' includes: ch]]) 
		    ifFalse: [self error: 'Type name syntax error in "%1".' % {type}]]
    ]

    collate: node1 to: node2 within: aNodeContext [
	<category: 'private'>
	| list sign |
	(list := self sortList) == nil 
	    ifFalse: 
		[1 to: list size
		    do: 
			[:i | 
			sign := (list at: i) 
				    collate: node1
				    to: node2
				    within: aNodeContext.
			sign = 0 ifFalse: [^sign = -1]]].
	^node1 precedes: node2
    ]

    readAttribute: attName [
	<category: 'private'>
	^self readAttribute: attName
	    default: 
		[self 
		    error: '%1 needs to have an attribute named %2' % 
				{self tag asString.
				attName}]
    ]

    readAttribute: attName default: def [
	<category: 'private'>
	| att |
	att := self valueOfAttribute: attName ifAbsent: [nil].
	^att == nil ifTrue: [def value] ifFalse: [att]
    ]

    readInteger: attName default: def [
	<category: 'private'>
	| att val |
	att := self valueOfAttribute: attName ifAbsent: [nil].
	^att == nil 
	    ifTrue: [def value]
	    ifFalse: 
		[att isEmpty ifTrue: [self error: 'The %1 attribute is empty' % {attName}].
		att := att readStream.
		val := Number readFrom: att.
		val = 0 ifTrue: [self error: 'Bad number format, ' , (att instVarAt: 1)].
		att atEnd 
		    ifFalse: 
			[self error: 'The %1 attribute is not a legal integer value' % {attName}].
		val]
    ]

    readMatchPattern: attName [
	<category: 'private'>
	^self readMatchPattern: attName
	    default: 
		[self 
		    error: '%1 needs to have an attribute named %2' % 
				{self tag asString.
				attName}]
    ]

    readMatchPattern: attName default: def [
	<category: 'private'>
	| att |
	att := self valueOfAttribute: attName ifAbsent: [nil].
	^att == nil 
	    ifTrue: [def value]
	    ifFalse: 
		[(XPathParser new)
		    xmlNode: self;
		    functions: self class xslFunctions;
		    parse: att as: #expression]
    ]

    readSelectPattern: attName [
	<category: 'private'>
	^self readSelectPattern: attName
	    default: 
		[self 
		    error: '%1 needs to have an attribute named %2' % 
				{self tag asString.
				attName}]
    ]

    readSelectPattern: attName default: def [
	<category: 'private'>
	| att d |
	att := self valueOfAttribute: attName ifAbsent: [nil].
	^att == nil 
	    ifTrue: 
		[d := def value.
		d == nil 
		    ifFalse: 
			[d := (XPathParser new)
				    xmlNode: self;
				    functions: self class xslFunctions;
				    parse: d as: #expression].
		d]
	    ifFalse: 
		[(XPathParser new)
		    xmlNode: self;
		    functions: self class xslFunctions;
		    parse: att as: #expression]
    ]

    readTag: attName [
	<category: 'private'>
	| att |
	att := self valueOfAttribute: attName ifAbsent: [nil].
	^att == nil 
	    ifTrue: 
		[self 
		    error: '%1 needs to have an attribute named %2' % 
				{self tag asString.
				attName}]
	    ifFalse: [att]
    ]

    readTagList: attName default: defaultBlock [
	<category: 'private'>
	| att str output buffer ch |
	att := self valueOfAttribute: attName ifAbsent: [nil].
	^att == nil 
	    ifTrue: [defaultBlock value]
	    ifFalse: 
		[str := att readStream.
		output := OrderedCollection new.
		buffer := String new writeStream.
		
		[str
		    skipSeparators;
		    atEnd] whileFalse: 
			    [[(ch := str next) notNil and: [ch isSeparator not]] 
				whileTrue: [buffer nextPut: ch].
			    output add: buffer contents.
			    buffer reset].
		output asArray]
    ]

    xslNodesFrom: aNodeContext [
	<category: 'private'>
	| list nc |
	list := aNodeContext node 
		    selectNodes: [:nd | nd isAttribute not or: [nd tag qualifier ~= 'xmlns']].
	nc := aNodeContext copy documentOrder.
	nc addAll: list.
	^nc
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self shouldNotImplement
    ]

    defaultTag [
	<category: 'accessing'>
	^'xsl:' , self class tag
    ]

    defineVariable: aVariable [
	<category: 'accessing'>
	self parent defineVariable: aVariable
    ]

    purgeUnimportant [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    sortList [
	"Answer a list of sort blocks that take two arguments,
	 and return -1 if the arguments are in order, 1 if they
	 are in reversed order, and 0 if that particular sort block
	 cannot order them."

	<category: 'accessing'>
	^nil
    ]

    xslElements [
	<category: 'accessing'>
	^self children select: [:i | i isContent]
    ]

    generatesAttributes [
	<category: 'testing'>
	^false
    ]

    isStylesheetEntry [
	<category: 'testing'>
	Transcript
	    nl;
	    tab;
	    show: 'Stylesheet contains a top-level element that is not permitted (%1)' 
			% {self tag}.
	Transcript
	    nl;
	    tab;
	    show: 'It has been ignored'.
	^false
    ]

    shouldStrip [
	<category: 'testing'>
	^true
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	elements := #().
	userData := false
    ]

    normalize [
	<category: 'initialize'>
	self stripSpace.
	self xslElements do: [:elm | elm normalize]
    ]

    stripSpace [
	<category: 'initialize'>
	self shouldStrip 
	    ifTrue: [self elements: (self children select: [:t | t isBlankText not])]
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData := true
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self subclassResponsibility
    ]

    process: aNodeContext into: aProxy takeArgumentsFrom: arguments [
	<category: 'processing'>
	self process: aNodeContext into: aProxy
    ]

    processAttributeSets: aNodeContext into: aProxy [
	<category: 'processing'>
	| list vars |
	self useAttrs isEmpty ifTrue: [^self].
	vars := aNodeContext variables.
	aNodeContext variables: vars parent.
	self useAttrs do: 
		[:attSetName | 
		list := aNodeContext db attributesForSet: attSetName.
		list do: [:att | att process: aNodeContext into: aProxy]].
	aNodeContext variables: vars
    ]

    processAttributeValue: aString for: aNodeContext [
	<category: 'processing'>
	| source ch output elm p expr |
	source := XPathReadStream on: aString.
	output := (String new: 64) writeStream.
	[source atEnd] whileFalse: 
		[ch := source next.
		ch = ${ 
		    ifTrue: 
			[(source peekFor: ${) 
			    ifTrue: [output nextPut: ${]
			    ifFalse: 
				[p := XPathParser new.
				p
				    initScanner;
				    xmlNode: self;
				    functions: self class xslFunctions;
				    init: source
					notifying: nil
					failBlock: nil.
				p expression.
				p atEndOfExpression 
				    ifFalse: [self error: 'Syntax error in: ' , aString storeString].
				expr := p result.
				elm := expr xpathValueIn: aNodeContext.
				output nextPutAll: elm xpathAsString

				"Not needed with our XPath parser!"
				"p pastEnd ifFalse: [source skip: -1]"]]
		    ifFalse: 
			[ch = $} 
			    ifTrue: 
				[source next = $} ifFalse: [self error: 'Expected doubled }'].
				output nextPut: $}]
			    ifFalse: [output nextPut: ch]]].
	^output contents
    ]

    resolveComputedTag: nm [
	<category: 'processing'>
	| n type ns qualifier |
	^(nm includes: $#) 
	    ifTrue: 
		[self checkURISyntax: nm.
		n := nm findLast: [:c | c = $#].
		type := nm copyFrom: n + 1 to: nm size.
		ns := nm copyFrom: 1 to: n - 1.
		qualifier := self findQualifierAtNamespace: 'quote:' , ns.
		qualifier == nil ifTrue: [qualifier := self findQualifierAtNamespace: ns].
		qualifier == nil 
		    ifTrue: 
			[self 
			    error: 'The namespace %1 has not been bound to a qualifier in this stylesheet, and automatic creation of qualifiers has not been implemented.' 
				    % {ns}].
		NodeTag new 
		    qualifier: qualifier
		    ns: ns
		    type: type]
	    ifFalse: 
		[self checkQNameSyntax: nm.
		self resolveTag: nm]
    ]

    resolveTag: aTagString [
	<category: 'processing'>
	| c qual ns |
	c := aTagString occurrencesOf: $:.
	^c = 0 
	    ifTrue: 
		[NodeTag new 
		    qualifier: ''
		    ns: ''
		    type: aTagString]
	    ifFalse: 
		[c > 1 
		    ifTrue: [self error: 'A qualified name has too many colons.']
		    ifFalse: 
			[c := aTagString indexOf: $:.
			(c = 1 or: [c = aTagString size]) 
			    ifTrue: [self error: 'A qualified name cannot begin or end with a colon.'].
			qual := aTagString copyFrom: 1 to: c - 1.
			ns := self findNamespaceAt: qual.
			ns == nil 
			    ifTrue: 
				[self 
				    error: 'The namespace qualifier %1 has not been bound to a namespace in this stylesheet' 
					    % {qual}].
			"Use a # in the match to make sure there's at least one more character"
			('quote:#*' match: ns) 
			    ifTrue: [ns := ns copyFrom: 'quote:' size + 1 to: ns size].
			NodeTag new 
			    qualifier: qual
			    ns: ns
			    type: (aTagString copyFrom: c + 1 to: aTagString size)]]
    ]

    selectAll: startNode withPattern: pattern [
	<category: 'processing'>
	^pattern xpathValueIn: startNode
    ]

    valueAsVariableIn: aNodeContext [
	<category: 'processing'>
	| new list |
	^self expression == nil 
	    ifTrue: 
		[new := ElementProxy new.
		list := self xslElements.
		1 to: list size
		    do: 
			[:i | 
			| elm |
			elm := list at: i.
			elm process: aNodeContext into: new].
		new]
	    ifFalse: [self expression xpathValueIn: aNodeContext]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CallTemplateCommand [
    | name |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    CallTemplateCommand class >> tag [
	<category: 'accessing'>
	^'call-template'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| rule arguments list vars |
	rule := aNodeContext db ruleNamed: self name.
	arguments := Dictionary new.
	list := self xslElements.
	1 to: list size
	    do: [:i | (list at: i) process: aNodeContext intoArgs: arguments].
	rule == nil 
	    ifTrue: [self error: 'Named template not found']
	    ifFalse: 
		[vars := aNodeContext variables.
		aNodeContext variables: vars clone.
		rule 
		    process: aNodeContext
		    into: aProxy
		    arguments: arguments.
		aNodeContext variables: vars]
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readAttribute: 'name' default: [nil]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: XSLDefinition [
    | importance |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    importance [
	<category: 'accessing'>
	^importance value
    ]

    importanceHolder: aValueHolder [
	<category: 'accessing'>
	importance := aValueHolder
    ]

    replaceImportance: oldValue with: currentImportance [
	<category: 'accessing'>
	importance == oldValue ifTrue: [importance := currentImportance]
    ]

    isStylesheetEntry [
	<category: 'testing'>
	^true
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self subclassResponsibility
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: Include [
    | href |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Top Level'>

    Include class >> tag [
	<category: 'accessing'>
	^'include'
    ]

    href [
	<category: 'accessing'>
	self testPatternInitialized.
	^href
    ]

    purgeUnimportant [
	<category: 'accessing'>
	elements == nil 
	    ifFalse: [self error: 'Includes should not have contents.'].
	(self parent isKindOf: RuleSet) 
	    ifFalse: 
		[self error: self tag asString , ' can only be used at the top level']
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	href := self readAttribute: 'href'
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	| uri save |
	save := aDB importance.
	aDB importance: save copy.
	uri := aDB uriStack last resolveRelativePath: self href.
	aDB uriStack addLast: uri.
	aDB readStream: uri resource topLevel: false.
	aDB uriStack removeLast.
	aDB replaceImportance: save
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: AttributeSet [
    | name useAttrs |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Top Level'>

    AttributeSet class >> tag [
	<category: 'accessing'>
	^'attribute-set'
    ]

    allAttributesFrom: aDB [
	<category: 'accessing'>
	| all |
	all := Dictionary new.
	useAttrs do: 
		[:setName | 
		(aDB attributesForSet: setName) do: [:attr | all at: attr name put: attr]].
	self xslElements do: 
		[:attr | 
		attr class == AttributeCommand 
		    ifFalse: [self error: 'Attribute sets only contain attributes'].
		all at: attr name put: attr].
	^all asOrderedCollection
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	aDB addAttributeSet: self
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| list |
	list := self xslElements.
	1 to: list size
	    do: 
		[:i | 
		| elm |
		elm := list at: i.
		elm process: aNodeContext into: aProxy]
    ]

    purgeUnimportant [
	<category: 'initialize'>
	elements := self children reject: [:i | i isBlankText].
	elements do: 
		[:elm | 
		elm generatesAttributes 
		    ifFalse: 
			[self error: 'xsl:attribute-set can contain only xsl:attribute and xsl:use']]
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readAttribute: 'name'.
	useAttrs := self readTagList: 'use-attribute-sets' default: [#()]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CounterScopeCommand [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    CounterScopeCommand class >> tag [
	<category: 'accessing'>
	^'counter-scope'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| tempProxy |
	tempProxy := aProxy countingProxy.
	self xslElements do: [:elm | elm process: aNodeContext into: tempProxy]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CommentCommand [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    CommentCommand class >> tag [
	<category: 'accessing'>
	^'comment'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| oc str |
	oc := aProxy childProxy.
	self xslElements do: [:elm | elm process: aNodeContext into: oc].
	oc attributes isEmpty 
	    ifFalse: [self error: 'Comments do not support attributes'].
	str := (String new: 128) writeStream.
	oc children do: 
		[:nd | 
		nd isText 
		    ifFalse: 
			[self 
			    error: 'Comments can only contain text, not elements, pi''s, or other comments'].
		str nextPutAll: nd characterData].
	str := str contents.
	"Need to do this twice to handle comments with a long run of -----"
	str := str copyReplaceAll: '--' with: '- -'.
	str := str copyReplaceAll: '--' with: '- -'.
	str last = $- ifTrue: [str := str copyWith: $ ].
	aProxy addNode: (Comment new text: str)
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ForEachCommand [
    | selectPattern sortList variables |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    ForEachCommand class >> tag [
	<category: 'accessing'>
	^'for-each'
    ]

    addSortBlock: aSortCommand [
	<category: 'accessing'>
	sortList == nil ifTrue: [sortList := #()].
	sortList := sortList copyWith: aSortCommand
    ]

    defineVariable: aVariable [
	<category: 'accessing'>
	variables add: aVariable.
	self parent defineVariable: aVariable
    ]

    selectPattern [
	<category: 'accessing'>
	self testPatternInitialized.
	^selectPattern
    ]

    sortList [
	<category: 'accessing'>
	^sortList
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	elements := nil.
	variables := OrderedCollection new: 0
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	selectPattern := self readSelectPattern: 'select'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| list elms listCopy |
	elms := self xslElements.
	list := self selectAll: aNodeContext withPattern: self selectPattern.
	self sortList == nil 
	    ifTrue: 
		[list
		    documentOrder;
		    ensureSorted]
	    ifFalse: 
		[listCopy := list shallowCopy.
		list sort: 
			[:n1 :n2 | 
			self 
			    collate: n1
			    to: n2
			    within: listCopy]].
	list reset.
	[list atEnd] whileFalse: 
		[list next.
		1 to: elms size
		    do: 
			[:i | 
			| elm |
			elm := elms at: i.
			elm process: list into: aProxy]]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: SortCommand [
    | selectPattern order lang dataType caseOrder |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    SortCommand class >> tag [
	<category: 'accessing'>
	^'sort'
    ]

    caseOrder [
	<category: 'accessing'>
	self testPatternInitialized.
	^caseOrder
    ]

    dataType [
	<category: 'accessing'>
	self testPatternInitialized.
	^dataType
    ]

    lang [
	<category: 'accessing'>
	self testPatternInitialized.
	^lang
    ]

    order [
	<category: 'accessing'>
	self testPatternInitialized.
	^order
    ]

    selectPattern [
	<category: 'accessing'>
	self testPatternInitialized.
	^selectPattern
    ]

    normalize [
	<category: 'initialize'>
	super normalize.
	(self parent respondsTo: #addSortBlock:) 
	    ifFalse: 
		[self error: self tag asString , ' can''t be a child element of ' 
			    , self parent tag asString].
	self parent addSortBlock: self
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	selectPattern := self readSelectPattern: 'select' default: ['.'].
	order := self readAttribute: 'order' default: ['ascending'].
	lang := self readAttribute: 'lang' default: [nil].
	dataType := self readAttribute: 'data-type' default: ['text'].
	caseOrder := self readAttribute: 'case-order' default: ['upper-first']
    ]

    collate: node1 to: node2 within: aNodeContext [
	<category: 'processing'>
	| v1 v2 result collate |
	collate := aNodeContext.
	collate indexForNode: node1.
	v1 := self selectPattern xpathValueIn: collate.
	collate indexForNode: node2.
	v2 := self selectPattern xpathValueIn: collate.
	dataType = 'number' 
	    ifTrue: [result := (v1 xpathAsNumber - v2 xpathAsNumber) sign]
	    ifFalse: [result := v1 xpathAsString < v2 xpathAsString].
	order = 'descending' ifTrue: [result := result negated].
	^result
    ]

    process: aNodeContext into: aProxy [
	"Do nothing. I am only present as a modifier on for-each or apply-templates"

	<category: 'processing'>
	^self
    ]

    process: aNodeContext intoArgs: aDictionary [
	"Do nothing. I am only present as a modifier on for-each or apply-templates.
	 For compatibility with <with-parm>"

	<category: 'processing'>
	^self
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: DecimalFormat [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    DecimalFormat class >> tag [
	<category: 'accessing'>
	^'decimal-format'
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self notYetImplemented
    ]

    purgeUnimportant [
	<category: 'accessing'>
	elements == nil 
	    ifFalse: [self error: 'Format declarations should not have contents']
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ElementCommand [
    | name useAttrs |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    ElementCommand class >> tag [
	<category: 'accessing'>
	^'element'
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    useAttrs [
	<category: 'accessing'>
	self testPatternInitialized.
	^useAttrs
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readTag: 'name'.
	useAttrs := self readTagList: 'use-attribute-sets' default: [#()]
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| oc nm list |
	oc := aProxy childProxy.
	self processAttributeSets: aNodeContext into: oc.
	list := self xslElements.
	1 to: list size
	    do: 
		[:i | 
		| elm |
		elm := list at: i.
		elm process: aNodeContext into: oc].
	nm := self processAttributeValue: self name for: aNodeContext.
	nm := self resolveComputedTag: nm.
	aProxy addNode: (Element 
		    tag: nm
		    attributes: oc attributes
		    elements: oc children)
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CountingCommand [
    | format prefix postfix lang letterValue digitGroupSep digitsPerGroup sequenceSrc |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    digitGroupSep [
	<category: 'accessing'>
	self testPatternInitialized.
	^digitGroupSep
    ]

    digitsPerGroup [
	<category: 'accessing'>
	self testPatternInitialized.
	^digitsPerGroup
    ]

    format [
	<category: 'accessing'>
	self testPatternInitialized.
	^format
    ]

    lang [
	<category: 'accessing'>
	self testPatternInitialized.
	^lang
    ]

    letterValue [
	<category: 'accessing'>
	self testPatternInitialized.
	^letterValue
    ]

    sequenceSrc [
	<category: 'accessing'>
	self testPatternInitialized.
	^sequenceSrc
    ]

    format: number by: aFormat [
	<category: 'private'>
	| n s |
	aFormat size = 1 
	    ifFalse: [self error: 'Unrecognized number format = "%1"' % {aFormat}].
	aFormat = 'a' 
	    ifTrue: 
		[n := self radix: number base: 26.
		s := n collect: [:i | (i + $a asInteger) asCharacter].
		^String withAll: s].
	aFormat = 'A' 
	    ifTrue: 
		[n := self radix: number base: 26.
		s := n collect: [:i | (i + $A asInteger) asCharacter].
		^String withAll: s].
	aFormat = 'i' ifTrue: [^self romanNumeral: number].
	aFormat = 'I' ifTrue: [^(self romanNumeral: number) asUppercase].
	aFormat = '1' ifTrue: [^number printString].
	self error: 'Unrecognized format'
    ]

    radix: number base: b [
	<category: 'private'>
	| out n |
	n := number - 1.
	n < b ifTrue: [^Array with: n].
	out := OrderedCollection new.
	n := number.
	[n < b] whileFalse: 
		[out addFirst: n \\ b.
		n := n // b].
	out addFirst: n - 1.
	^out
    ]

    romanNumeral: number [
	<category: 'private'>
	| n cycle output idx letters digit |
	n := number.
	cycle := #('ivx' 'xlc' 'cdm').
	output := OrderedCollection new.
	idx := 0.
	[n = 0] whileFalse: 
		[letters := cycle at: (idx := idx + 1).
		digit := n \\ 10.
		digit := #(#() #(1) #(1 1) #(1 1 1) #(1 2) #(2) #(2 1) #(2 1 1) #(2 1 1 1) #(1 3)) 
			    at: digit + 1.
		output addAllFirst: (digit collect: [:i | letters at: i]).
		n := n // 10].
	^String withAll: output
    ]

    tokenizeFormat: aString [
	<category: 'private'>
	| str isFormat tok tokens t resultFormat |
	str := aString readStream.
	tokens := OrderedCollection new.
	isFormat := [:ch | ch isDigit or: [ch isLetter]].
	[str atEnd] whileFalse: 
		[tok := ''.
		(isFormat value: str peek) 
		    ifTrue: 
			[[str atEnd or: [(isFormat value: str peek) not]] 
			    whileFalse: [tok := tok copyWith: str next]]
		    ifFalse: 
			[[str atEnd or: [isFormat value: str peek]] 
			    whileFalse: [tok := tok copyWith: str next]].
		tokens add: tok].
	(tokens isEmpty or: [isFormat value: tokens first first]) 
	    ifFalse: [prefix := tokens removeFirst].
	(tokens isEmpty or: [isFormat value: tokens last first]) 
	    ifFalse: [postfix := tokens removeLast].
	tokens size = 0 
	    ifTrue: [resultFormat := nil]
	    ifFalse: 
		[tokens size = 1 
		    ifTrue: 
			[resultFormat := (NumberFormat new)
				    format: tokens first;
				    separator: '.'.
			resultFormat nextLink: resultFormat]
		    ifFalse: 
			[t := (1 to: tokens size by: 2) collect: 
					[:i | 
					(NumberFormat new)
					    format: (tokens at: i);
					    separator: (tokens at: (i + 1 min: tokens size - 1))].
			1 to: t size do: [:i | (t at: i) nextLink: (t at: (i + 1 min: t size))].
			resultFormat := t first]].
	^resultFormat
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	format := self readAttribute: 'format' default: ['1'].
	lang := self readAttribute: 'xml:lang' default: [nil].
	letterValue := self readAttribute: 'letter-value' default: [nil].
	digitGroupSep := self readAttribute: 'digit-group-sep' default: [nil].
	digitsPerGroup := self readInteger: 'n-digits-per-group' default: [3].
	sequenceSrc := self readAttribute: 'sequence-src' default: [nil]
    ]

    format: countList for: aNodeContext [
	<category: 'processing'>
	| str fmt |
	str := String new writeStream.
	fmt := self processAttributeValue: self format for: aNodeContext.
	fmt := self tokenizeFormat: fmt.
	prefix == nil ifFalse: [str nextPutAll: prefix].
	1 to: countList size
	    do: 
		[:i | 
		str nextPutAll: (self format: (countList at: i) by: fmt format).
		i = countList size ifFalse: [str nextPutAll: fmt separator].
		fmt := fmt nextLink].
	postfix == nil ifFalse: [str nextPutAll: postfix].
	^str contents
    ]
]

]



Namespace current: XSL [

CountingCommand subclass: CountersCommand [
    | name |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    CountersCommand class >> tag [
	<category: 'accessing'>
	^'counters'
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	super testPatternInitialized.
	name := self readAttribute: 'name'.
	userData := true
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| list |
	list := OrderedCollection new.
	aProxy counterValuesNamed: self name into: list.
	aProxy add: (Text new text: (self format: list for: aNodeContext))
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: ParamDefinition [
    | name expression |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    ParamDefinition class >> tag [
	<category: 'accessing'>
	^'param'
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	aDB addVariable: self
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self shouldNotImplement
    ]

    process: aNodeContext into: aProxy takeArgumentsFrom: arguments [
	<category: 'processing'>
	| val |
	val := arguments at: self name ifAbsent: [].
	val == nil ifTrue: [val := self valueAsVariableIn: aNodeContext].
	aNodeContext variables at: self name put: val
    ]

    expression [
	<category: 'accessing'>
	self testPatternInitialized.
	^expression
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    purgeUnimportant [
	<category: 'accessing'>
	^self
    ]

    normalize [
	<category: 'initialize'>
	super normalize.
	self parent defineParameter: self
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readAttribute: 'name'.
	expression := self readSelectPattern: 'select' default: [].
	(expression notNil and: [self children isEmpty not]) 
	    ifTrue: 
		[self error: 'A parameter cannot have both content and a select attribute']
    ]

    isStylesheetEntry [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ChooseWhenCommand [
    | testPattern |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    ChooseWhenCommand class >> tag [
	<category: 'accessing'>
	^'when'
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	testPattern := self readSelectPattern: 'test'
    ]

    testPattern [
	<category: 'accessing'>
	self testPatternInitialized.
	^testPattern
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self shouldNotImplement
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: WithParamCommand [
    | name expression |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    WithParamCommand class >> tag [
	<category: 'accessing'>
	^'with-param'
    ]

    expression [
	<category: 'accessing'>
	self testPatternInitialized.
	^expression
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readAttribute: 'name'.
	expression := self readSelectPattern: 'select' default: [].
	(expression notNil and: [self children isEmpty not]) 
	    ifTrue: 
		[self error: 'A parameter cannot have both content and a select attribute']
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self shouldNotImplement
    ]

    process: aNodeContext intoArgs: aDictionary [
	<category: 'processing'>
	| val |
	val := self valueAsVariableIn: aNodeContext.
	aDictionary at: self name put: val
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: Import [
    | href |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Top Level'>

    Import class >> tag [
	<category: 'accessing'>
	^'import'
    ]

    href [
	<category: 'accessing'>
	self testPatternInitialized.
	^href
    ]

    purgeUnimportant [
	<category: 'accessing'>
	| idx |
	elements == nil ifFalse: [self error: 'Imports should not have contents.'].
	(self parent isKindOf: RuleSet) 
	    ifFalse: 
		[self error: self tag asString , ' can only be used at the top level'].
	idx := self parent children indexOf: self.
	(idx = 1 or: [(self parent children at: idx - 1) class == self class]) 
	    ifFalse: [self error: 'All imports must come first in the stylesheet']
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	href := self readAttribute: 'href'
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	| uri |
	uri := aDB uriStack last resolveRelativePath: self href.
	aDB uriStack addLast: uri.
	aDB readStream: uri resource topLevel: false.
	aDB uriStack removeLast.
	aDB raiseImportance
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: Template [
    | hasStripped |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    importanceHolder: dummy [
	<category: 'accessing'>
	
    ]

    purgeUnimportant [
	<category: 'accessing'>
	^self
    ]

    importance [
	"Really only needs to be > 0 to beat the builtin rule that matches
	 against the root of the document, but we throw in a bit of paranoia."

	<category: 'testing'>
	^1000
    ]

    match: aNodeContext [
	<category: 'testing'>
	^aNodeContext node isDocument
    ]

    modeIsLike: aMode [
	<category: 'testing'>
	^aMode isNil
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| oc list |
	oc := aProxy childProxy.
	oc attributes: (self processAttributes: self attributes for: aNodeContext).
	list := self xslElements.
	1 to: list size
	    do: 
		[:i | 
		| elm |
		elm := list at: i.
		elm process: aNodeContext into: oc].
	aProxy addNode: (Element 
		    tag: tag
		    attributes: oc attributes
		    elements: oc children)
    ]

    process: aNodeContext into: aProxy arguments: arguments [
	"The arguments are ignored because, if I am being used
	 as a top-level stylesheet, there's no place to declare the
	 top-level <xsl:param> definitions."

	<category: 'processing'>
	self process: aNodeContext into: aProxy
    ]

    processAttributes: attList for: aNodeContext [
	<category: 'processing'>
	| newList substitution newAtt |
	newList := OrderedCollection new.
	attList do: 
		[:att | 
		att tag namespace = XSL_URI 
		    ifTrue: 
			[newAtt := self processXSLAttribute: att for: aNodeContext.
			newAtt == nil ifFalse: [newList add: newAtt]]].
	attList do: 
		[:att | 
		att tag namespace = XSL_URI 
		    ifFalse: 
			[substitution := self processAttributeValue: att value for: aNodeContext.
			newAtt := Attribute name: att key value: substitution.
			newList add: newAtt]].
	^newList isEmpty ifTrue: [nil] ifFalse: [newList asArray]
    ]

    processXSLAttribute: att for: aNodeContext [
	<category: 'processing'>
	att tag type = 'version' 
	    ifTrue: 
		["aNodeContext db version: att value."

		^nil].
	att tag type = 'use-attribute-set' ifTrue: [^self notYetImplementedError].
	^self notYetImplementedError
    ]

    topLevelAddToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self tag namespace = XSL_URI 
	    ifTrue: 
		[self error: '"%1" not recognized as an XSL command' % {self tag asString}].
	aDB addRule: self
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: VariableDefinition [
    | name expression |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    VariableDefinition class >> tag [
	<category: 'accessing'>
	^'variable'
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	aDB addVariable: self
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| val |
	val := self valueAsVariableIn: aNodeContext.
	aNodeContext variables at: name put: val
    ]

    expression [
	<category: 'accessing'>
	self testPatternInitialized.
	^expression
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    purgeUnimportant [
	<category: 'accessing'>
	^self
    ]

    normalize [
	<category: 'initialize'>
	super normalize.
	self parent defineVariable: self
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readAttribute: 'name'.
	expression := self readSelectPattern: 'select' default: [].
	(expression notNil and: [self children isEmpty not]) 
	    ifTrue: 
		[self error: 'A parameter cannot have both content and a select attribute']
    ]

    isStylesheetEntry [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CounterIncrementCommand [
    | name amount |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    CounterIncrementCommand class >> tag [
	<category: 'accessing'>
	^'counter-increment'
    ]

    amount [
	<category: 'accessing'>
	self testPatternInitialized.
	^amount
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	super testPatternInitialized.
	name := self readAttribute: 'name'.
	amount := self readInteger: 'amount' default: [1].
	userData := true
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| c |
	c := aProxy counterNamed: self name.
	c == nil ifTrue: [c := aProxy root resetCounter: self name].
	c value: c value + 1
    ]
]

]



Namespace current: XSL [

Array subclass: Rank [
    
    <shape: #pointer>
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    rankAgainst: aRank [
	"Assume two Ranks, of sizes M and N, where M >= N.
	 If they have the same elements in the first N elements, the
	 shorter Rank has higher priority.
	 If there is a difference in the first N elements, assume
	 that the first difference occurs at slot S. The Rank
	 whose value at S is greater has higher priority."

	<category: 'comparing'>
	| min r ranks |
	ranks := #(#higher #same #lower).
	min := self size min: aRank size.
	1 to: min
	    do: 
		[:i | 
		r := ((aRank at: i) - (self at: i)) sign.
		r = 0 ifFalse: [^ranks at: r + 2]].
	^ranks at: (self size - aRank size) sign + 2
    ]
]

]



Namespace current: XSL [

Link subclass: NumberFormat [
    | format separator |
    
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    format [
	<category: 'accessing'>
	^format
    ]

    format: s [
	<category: 'accessing'>
	format := s
    ]

    separator [
	<category: 'accessing'>
	^separator
    ]

    separator: s [
	<category: 'accessing'>
	separator := s
    ]

    printOn: aStream [
	<category: 'printing'>
	format == nil ifFalse: [aStream nextPutAll: format].
	separator == nil ifFalse: [aStream nextPutAll: separator].
	(nextLink == nil or: [nextLink == self]) 
	    ifFalse: [nextLink printOn: aStream]
    ]
]

]



Namespace current: XSL [

XML.Text subclass: TextTemplate [
    | hasStripped |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    normalize [
	<category: 'initialize'>
	^self
    ]

    stripSpace [
	<category: 'initialize'>
	^self
    ]

    isStylesheetEntry [
	<category: 'testing'>
	| s |
	s := text readStream.
	s skipSeparators.
	s atEnd 
	    ifFalse: [self error: 'Text contains something other than whitespace.'].
	^false
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self text isEmpty ifFalse: [aProxy addNode: (Text new text: self text)]
    ]
]

]



Namespace current: XSL [

CountingCommand subclass: NumberCommand [
    | level count from |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    NumberCommand class >> tag [
	<category: 'accessing'>
	^'number'
    ]

    countFor: aNode [
	<category: 'accessing'>
	aNode isElement 
	    ifFalse: 
		[self halt: 'Counting things other than elements is not supported yet'].
	self testPatternInitialized.
	^count == nil 
	    ifTrue: 
		[(XPathChildNode new)
		    axisName: 'child';
		    baseTest: ((XPathTaggedNodeTest new)
				namespace: aNode tag namespace;
				type: aNode tag type)]
	    ifFalse: [count]
    ]

    from [
	<category: 'accessing'>
	self testPatternInitialized.
	^from
    ]

    level [
	<category: 'accessing'>
	self testPatternInitialized.
	^level
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	super testPatternInitialized.
	level := (self readAttribute: 'level' default: [#single]) asSymbol.
	count := self readMatchPattern: 'count' default: [nil].
	from := self readMatchPattern: 'from' default: [nil].
	userData := true
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self level == #single 
	    ifTrue: [^self processSingle: aNodeContext into: aProxy].
	self level == #multi 
	    ifTrue: [^self processMulti: aNodeContext into: aProxy].
	self level == #any ifTrue: [^self processAny: aNodeContext into: aProxy].
	^self error: 'Unsupported numbering mode'
    ]

    processAny: aNodeContext into: aProxy [
	<category: 'processing'>
	| n countP |
	n := 0.
	countP := self countFor: aNodeContext node.
	(NodeIterator new)
	    node: aNodeContext node;
	    reverseDo: 
		    [:nd | 
		    (countP match: ((aNodeContext copy)
				add: nd;
				index: 1)) 
			ifTrue: [n := n + 1]]
		until: 
		    [:nd | 
		    self from notNil 
			and: [self from match: ((aNodeContext copy)
					add: nd;
					index: 1)]].
	aProxy 
	    addNode: (Text new text: (self format: (Array with: n) for: aNodeContext))
    ]

    processMulti: aNodeContext into: aProxy [
	<category: 'processing'>
	| allNodes n counts countP sibSelect cnt sibs |
	countP := self countFor: aNodeContext node.
	allNodes := aNodeContext copy.
	n := aNodeContext node.
	[n == nil or: [self from notNil and: [self from match: n]]] whileFalse: 
		[allNodes add: n.
		n := n parent].
	allNodes := allNodes selectMatch: countP.
	allNodes
	    documentOrder;
	    index: 1.
	sibSelect := XPathParser parse: '../node()' as: #expression.
	counts := OrderedCollection new.
	allNodes reset.
	[allNodes atEnd] whileFalse: 
		[allNodes next.
		cnt := 1.
		sibs := sibSelect xpathValueIn: allNodes.
		sibs
		    reset;
		    next.
		[sibs node == allNodes node] whileFalse: 
			[(countP match: sibs) ifTrue: [cnt := cnt + 1].
			sibs next].
		counts add: cnt].
	aProxy 
	    addNode: (Text new text: (self format: counts asArray for: aNodeContext))
    ]

    processSingle: aNodeContext into: aProxy [
	<category: 'processing'>
	| allNodes n cnt countP sibSelect sibs |
	countP := self countFor: aNodeContext node.
	allNodes := aNodeContext copy.
	n := aNodeContext node.
	[n == nil or: [self from notNil and: [self from match: n]]] whileFalse: 
		[allNodes add: n.
		n := n parent].
	allNodes := allNodes selectMatch: countP.
	allNodes size = 0 ifTrue: [^self].
	allNodes
	    inverseDocumentOrder;
	    index: 1.
	sibSelect := XPathParser parse: '../node()' as: #expression.
	sibs := sibSelect xpathValueIn: allNodes.
	sibs
	    reset;
	    next.
	cnt := 1.
	[sibs node == allNodes node] whileFalse: 
		[(countP match: sibs) ifTrue: [cnt := cnt + 1].
		sibs next].
	aProxy 
	    addNode: (Text new text: (self format: (Array with: cnt) for: aNodeContext))
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: OutputCommand [
    | method version encoding omitXmlDeclaration standalone doctypePublic doctypeSystem cdataSectionElements indent mediaType |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    OutputCommand class >> tag [
	<category: 'accessing'>
	^'output'
    ]

    method [
	<category: 'accessing'>
	method == nil 
	    ifTrue: [method := self readAttribute: 'method' default: [#auto]].
	^method
    ]

    purgeUnimportant [
	<category: 'accessing'>
	elements == nil 
	    ifFalse: [self error: 'Output declarations should not have contents']
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	aDB setOutput: self
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CopyCommand [
    | useAttrs |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    CopyCommand class >> tag [
	<category: 'accessing'>
	^'copy'
    ]

    useAttrs [
	<category: 'accessing'>
	self testPatternInitialized.
	^useAttrs
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	aNodeContext node isAttribute 
	    ifTrue: 
		[self useAttrs isEmpty 
		    ifFalse: 
			[self error: '<xsl:copy> is attempting to add attributes to an Attribute'].
		^self processAttribute: aNodeContext into: aProxy].
	aNodeContext node isElement 
	    ifTrue: [^self processElement: aNodeContext into: aProxy].
	(aNodeContext node isComment or: [aNodeContext node isText]) 
	    ifTrue: 
		[self useAttrs isEmpty 
		    ifFalse: 
			[self error: '<xsl:copy> is attempting to add attributes to a non-Element'].
		^aProxy add: aNodeContext node copy].
	^self error: 'Copying of this node type is not yet implemented'
    ]

    processAttribute: aNodeContext into: aProxy [
	<category: 'processing'>
	aProxy addAttribute: (Attribute new name: aNodeContext node tag
		    value: aNodeContext node value)
    ]

    processElement: aNodeContext into: aProxy [
	<category: 'processing'>
	| oc list |
	oc := aProxy childProxy.
	self processAttributeSets: aNodeContext into: oc.
	list := self xslElements.
	1 to: list size
	    do: 
		[:i | 
		| elm |
		elm := list at: i.
		elm process: aNodeContext into: oc].
	aProxy addNode: (Element 
		    tag: aNodeContext node tag
		    attributes: oc attributes
		    elements: oc children)
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	useAttrs := self readTagList: 'use-attribute-sets' default: [#()]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ValueOfCommand [
    | expression |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    ValueOfCommand class >> tag [
	<category: 'accessing'>
	^'value-of'
    ]

    expression [
	<category: 'accessing'>
	self testPatternInitialized.
	^expression
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	expression := self readSelectPattern: 'select'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| elm |
	elm := self expression xpathValueIn: aNodeContext.
	(elm == nil or: [(elm := elm xpathAsString) isEmpty]) 
	    ifFalse: [aProxy addNode: (Text new text: elm)]
    ]
]

]



Namespace current: XSL [

XSLDefinition subclass: Rule [
    | pattern name specific priority mode variables |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Top Level'>

    Rule class >> formatText: aNode [
	<category: 'formatting'>
	| text tab a nbsp |
	a := Attribute new name: 'CLASS' value: 'body'.
	text := aNode characterData.
	nbsp := (Character codePoint: 160) asString.
	tab := nbsp , nbsp , nbsp , nbsp.
	text := text copyReplaceAll: 9 asCharacter asString with: tab.
	text := text substrings: Character nl.
	^text collect: 
		[:t | 
		t isEmpty 
		    ifTrue: [Element tag: 'BR']
		    ifFalse: 
			[Element 
			    tag: 'P'
			    attributes: (Array with: a copy)
			    elements: (Array with: (Text new text: t))]]
    ]

    Rule class >> tag [
	<category: 'accessing'>
	^'template'
    ]

    defineParameter: aVariable [
	<category: 'accessing'>
	| old |
	old := variables detect: [:var | var name = aVariable name] ifNone: [].
	(old == nil or: [old == aVariable]) 
	    ifFalse: 
		[self error: 'The parameter "' , aVariable name 
			    , '" is shadowing another variable in the same template'].
	old == nil ifTrue: [variables add: aVariable]
    ]

    defineVariable: aVariable [
	<category: 'accessing'>
	| old |
	old := variables detect: [:var | var name = aVariable name] ifNone: [].
	(old == nil or: [old == aVariable]) 
	    ifFalse: 
		[self error: 'The variable "' , aVariable name 
			    , '" is shadowing another variable in the same template'].
	old == nil ifTrue: [variables add: aVariable]
    ]

    mode [
	<category: 'accessing'>
	self testPatternInitialized.
	^mode
    ]

    mode: aMode [
	<category: 'accessing'>
	mode := aMode
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    pattern [
	<category: 'accessing'>
	self testPatternInitialized.
	^pattern
    ]

    priority [
	<category: 'accessing'>
	self testPatternInitialized.
	^priority
    ]

    priority: aNumber [
	<category: 'accessing'>
	priority := aNumber
    ]

    purgeUnimportant [
	<category: 'accessing'>
	^self
    ]

    isStylesheetEntry [
	<category: 'testing'>
	^true
    ]

    match: aNodeContext [
	<category: 'testing'>
	^self pattern notNil and: [self pattern match: aNodeContext]
    ]

    modeIsLike: aMode [
	"We can use #any as the 'accept any mode', because
	 normal modes are strings. If this is changed, the marker
	 for 'any mode' would need to be changed."

	<category: 'testing'>
	^mode = aMode or: [mode == #any]
    ]

    computeDefaultPriority: expr [
	<category: 'initialize'>
	| list |
	^expr class == XPathUnion 
	    ifTrue: 
		[list := Set new.
		expr arguments 
		    do: [:expr2 | list add: (self computeDefaultPriority: expr2)].
		list size = 1 ifTrue: [list asArray first] ifFalse: [#notKnown]]
	    ifFalse: 
		[((expr class == XPathChildNode or: [expr class == XPathAttributeNode]) 
		    and: [expr child isTerminator and: [expr predicates isEmpty]]) 
			ifTrue: 
			    [expr baseTest class == XPathTaggedNodeTest 
				ifTrue: 
				    [expr baseTest type == #* 
					ifTrue: [expr baseTest namespace == nil ifTrue: [-0.5] ifFalse: [-0.25]]
					ifFalse: [0.0]]
				ifFalse: 
				    [('processing-instruction(*)' match: expr printString) 
					ifTrue: [self halt]
					ifFalse: [-0.5]]]
			ifFalse: [0.5]]
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	priority := 0.
	variables := OrderedCollection new
    ]

    normalize [
	<category: 'initialize'>
	super normalize.
	(self parent == nil or: [self parent isKindOf: RuleSet]) 
	    ifFalse: 
		[self error: self tag asString , ' can only be used at the top level']
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readAttribute: 'name' default: [nil].
	pattern := self readMatchPattern: 'match' default: [nil].
	priority := self readInteger: 'priority'
		    default: [self computeDefaultPriority: self pattern].
	mode := self readAttribute: 'mode' default: [nil]
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self pattern == nil ifFalse: [aDB addRule: self].
	self name == nil ifFalse: [aDB addNamedTemplate: self].
	(self pattern == nil and: [self name == nil]) 
	    ifTrue: 
		[self error: 'Templates must have either a name or match attribute or both']
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self shouldNotImplement
    ]

    process: aNodeContext into: aProxy arguments: arguments [
	<category: 'processing'>
	| list |
	list := self xslElements.
	1 to: list size
	    do: 
		[:i | 
		| elm |
		elm := list at: i.
		elm 
		    process: aNodeContext
		    into: aProxy
		    takeArgumentsFrom: arguments]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CounterResetCommand [
    | name |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    CounterResetCommand class >> tag [
	<category: 'accessing'>
	^'counter-reset'
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	super testPatternInitialized.
	name := self readAttribute: 'name'.
	userData := true
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	aProxy resetCounter: self name
    ]
]

]



Namespace current: XSL [

XML.SAXWriter subclass: SAXHtmlWriter [
    | htmlSpecialEmptyTags |
    
    <comment: nil>
    <category: 'XSL-XSL-Output'>

    endElement: namespaceURI localName: localName qName: name [
	<category: 'content handler'>
	namespaceURI isEmpty 
	    ifFalse: 
		[^super 
		    endElement: namespaceURI
		    localName: localName
		    qName: name].
	hasOpenTag 
	    ifTrue: 
		[(self htmlSpecialEmptyTags includes: name asLowercase) 
		    ifTrue: [output nextPutAll: '>']
		    ifFalse: [output nextPutAll: '/>']]
	    ifFalse: [output nextPutAll: '</' , name asLowercase , '>'].
	hasOpenTag := false
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	namespaceURI isEmpty 
	    ifFalse: 
		[^super 
		    startElement: namespaceURI
		    localName: localName
		    qName: name
		    attributes: attributes].
	self closeOpenTag.
	output nextPutAll: '<'.
	output nextPutAll: name asLowercase.
	(self sort: attributes) do: 
		[:att | 
		output space.
		output nextPutAll: att tag asString asLowercase.
		(self isBoolean: att in: name) 
		    ifFalse: 
			[output nextPutAll: '="'.
			1 to: att value size
			    do: 
				[:i | 
				| ch mapped |
				ch := att value at: i.
				mapped := attrMap at: ch ifAbsent: [nil].
				mapped == nil 
				    ifTrue: [output nextPut: ch]
				    ifFalse: [output nextPutAll: mapped]]].
		output nextPutAll: '"'].
	hasOpenTag := true.
	name asLowercase = 'head' 
	    ifTrue: 
		[| atts |
		atts := OrderedCollection new.
		atts add: ((Attribute new)
			    tag: (NodeTag new 
					qualifier: ''
					ns: ''
					type: 'http-equiv');
			    value: 'Content-Type').
		atts add: ((Attribute new)
			    tag: (NodeTag new 
					qualifier: ''
					ns: ''
					type: 'content');
			    value: 'text/html; charset=utf-8').
		atts := atts asArray.
		self 
		    startElement: ''
		    localName: 'meta'
		    qName: 'meta'
		    attributes: atts.
		self 
		    endElement: ''
		    localName: 'meta'
		    qName: 'meta']
    ]

    htmlSpecialEmptyTags [
	<category: 'accessing'>
	htmlSpecialEmptyTags == nil 
	    ifTrue: 
		[htmlSpecialEmptyTags := #('area' 'base' 'basefont' 'br' 'col' 'frame' 'hr' 'img' 'input' 'isindex' 'link' 'meta' 'param')].
	^htmlSpecialEmptyTags
    ]

    htmlSpecialEmptyTags: aList [
	<category: 'accessing'>
	htmlSpecialEmptyTags := aList
    ]

    isBoolean: attribute in: elementTag [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ChooseCommand [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    ChooseCommand class >> tag [
	<category: 'accessing'>
	^'choose'
    ]

    elements: aList [
	<category: 'private'>
	| newList hasOtherwise |
	newList := aList select: [:i | i isContent and: [i isBlankText not]].
	hasOtherwise := false.
	newList do: 
		[:elm | 
		elm class = ChooseOtherwiseCommand 
		    ifTrue: 
			[hasOtherwise 
			    ifTrue: [self error: 'xsl:choose with multiple xsl:otherwise commands'].
			hasOtherwise := true]
		    ifFalse: 
			[elm class = ChooseWhenCommand 
			    ifFalse: 
				[self error: 'xsl:choose can only contain xsl:when and xsl:otherwise']]].
	super elements: newList
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| alt match list |
	alt := match := nil.
	elements do: 
		[:elm | 
		elm class == ChooseOtherwiseCommand 
		    ifTrue: [alt := elm]
		    ifFalse: 
			[(match == nil 
			    and: [(elm testPattern xpathValueIn: aNodeContext) xpathAsBoolean]) 
				ifTrue: [match := elm]]].
	match == nil ifTrue: [match := alt].
	match notNil 
	    ifTrue: 
		[list := match xslElements.
		1 to: list size
		    do: 
			[:i | 
			| elm |
			elm := list at: i.
			elm process: aNodeContext into: aProxy]]
    ]
]

]



Namespace current: XSL [

Dictionary subclass: ChainedDictionary [
    | parent |
    
    <shape: #pointer>
    <category: 'XSL-XSL-Nodes-Top Level'>
    <comment: nil>

    associationAt: anIndex ifAbsent: aBlock [
	<category: 'accessing'>
	^super associationAt: anIndex
	    ifAbsent: [parent associationAt: anIndex ifAbsent: aBlock]
    ]

    at: anIndex ifAbsent: aBlock [
	<category: 'accessing'>
	^super at: anIndex ifAbsent: [parent at: anIndex ifAbsent: aBlock]
    ]

    clone [
	<category: 'accessing'>
	^self class new parent: parent
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aParent [
	<category: 'accessing'>
	aParent == nil ifTrue: [self halt].
	parent := aParent
    ]

    size [
	<category: 'accessing'>
	| s |
	s := Set new.
	self keysAndValuesDo: [:k :v | s add: k].
	^s size
    ]

    associationsDo: aBlock [
	"Evaluate aBlock for each of the receiver's key/value associations."

	<category: 'dictionary enumerating'>
	self keysAndValuesDo: [:k :v | aBlock value: k -> v]
    ]

    includesKey: key [
	"Answer whether the receiver has a key equal to the argument, key."

	<category: 'dictionary testing'>
	^(super includesKey: key) or: [parent includesKey: key]
    ]

    do: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the
	 argument."

	<category: 'enumerating'>
	self keysDo: [:k | aBlock value: (self at: k)]
    ]

    keysAndValuesDo: aBlock [
	"Evaluate aBlock with each of the receiver's key/value pairs as the
	 arguments."

	<category: 'enumerating'>
	| keys |
	keys := Set new.
	super keysAndValuesDo: [:k :v | keys add: k].
	parent keysAndValuesDo: [:k :v | keys add: k].
	keys do: [:k | aBlock value: k value: (self at: k)]
    ]

    changeCapacityTo: newCapacity [
	<category: 'private'>
	| newSelf |
	newSelf := self copyEmpty: newCapacity.
	newSelf parent: parent.
	super associationsDo: [:each | newSelf noCheckAdd: each].
	self become: newSelf
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: IfCommand [
    | testPattern |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    IfCommand class >> tag [
	<category: 'accessing'>
	^'if'
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	testPattern := self readSelectPattern: 'test'
    ]

    testPattern [
	<category: 'accessing'>
	self testPatternInitialized.
	^testPattern
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| list |
	(self testPattern xpathValueIn: aNodeContext) xpathAsBoolean 
	    ifTrue: 
		[list := self xslElements.
		1 to: list size
		    do: 
			[:i | 
			| elm |
			elm := list at: i.
			elm process: aNodeContext into: aProxy]]
    ]
]

]



Namespace current: XSL [

XML.PI subclass: XSL_PI [
    | block |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    stripSpace [
	<category: 'accessing'>
	^self
    ]

    isContent [
	<category: 'testing'>
	^name = 'vwst_xsl'
    ]

    isStylesheetEntry [
	<category: 'testing'>
	^name = 'vwst_xsl'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	block == nil ifTrue: [block := Behavior evaluate: text].
	(block class == BlockClosure and: [block numArgs = 1]) 
	    ifFalse: 
		[self 
		    error: '"' , text , '" is not a legal Smalltalk processing instruction'].
	aProxy addAll: (block value: aNodeContext)
    ]

    normalize [
	<category: 'initialize'>
	^self
    ]
]

]



Namespace current: XSL [

Link subclass: GeneralCountingProxy [
    | counters |
    
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    childProxy [
	<category: 'accessing'>
	^(ElementProxy new)
	    nextLink: self;
	    yourself
    ]

    counterNamed: nm [
	<category: 'accessing'>
	| c |
	counters == nil 
	    ifTrue: [c := nil]
	    ifFalse: [c := counters at: nm ifAbsent: []].
	^c == nil 
	    ifTrue: [nextLink == nil ifTrue: [nil] ifFalse: [nextLink counterNamed: nm]]
	    ifFalse: [c]
    ]

    counterValuesNamed: nm into: list [
	<category: 'accessing'>
	| c |
	self nextLink == nil 
	    ifFalse: [self nextLink counterValuesNamed: nm into: list].
	counters == nil 
	    ifTrue: [c := nil]
	    ifFalse: [c := counters at: nm ifAbsent: []].
	c == nil ifFalse: [list add: c value]
    ]

    countingProxy [
	<category: 'accessing'>
	^(CountingProxy new)
	    nextLink: self;
	    yourself
    ]

    resetCounter: nm [
	<category: 'accessing'>
	counters == nil ifTrue: [counters := Dictionary new].
	counters at: nm put: 0 asValue.
	^counters at: nm
    ]

    root [
	<category: 'accessing'>
	| n |
	n := self.
	[n nextLink == nil] whileFalse: [n := n nextLink].
	^n
    ]
]

]



Namespace current: XSL [

GeneralCountingProxy subclass: ElementProxy [
    | contents attributes |
    
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    addAttribute: attribute [
	<category: 'building'>
	self attributes: (self attributes copyWith: attribute)
    ]

    addNode: element [
	<category: 'building'>
	self children: (self children copyWith: element)
    ]

    attributes [
	<category: 'accessing'>
	attributes == nil ifTrue: [attributes := #()].
	^attributes
    ]

    attributes: list [
	<category: 'accessing'>
	attributes := list
    ]

    children [
	<category: 'accessing'>
	contents == nil ifTrue: [contents := #()].
	^contents
    ]

    children: list [
	<category: 'accessing'>
	contents := list
    ]

    xpathAsBoolean [
	<category: 'coercing'>
	^self xpathAsString xpathAsBoolean
    ]

    xpathAsNumber [
	<category: 'coercing'>
	^self xpathAsString xpathAsNumber
    ]

    xpathAsString [
	<category: 'coercing'>
	| result |
	self children isEmpty ifTrue: [^''].
	self children size = 1 ifTrue: [^self children first xpathStringData].
	result := (String new: 40) writeStream.
	1 to: self children size
	    do: [:i | result nextPutAll: (self children at: i) xpathStringData].
	^result contents
    ]

    addToXPathHolder: anAssociation for: aNodeContext [
	<category: 'enumerating'>
	anAssociation value == nil ifTrue: [^anAssociation value: self].
	anAssociation value xpathIsNodeSet 
	    ifTrue: 
		[^self 
		    error: 'An XPath expression is answering a combination of Nodes and non-Nodes'].
	self 
	    error: 'An XPath expression is answering more than one non-Node value'
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: PICommand [
    | name |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    PICommand class >> tag [
	<category: 'accessing'>
	^'pi'
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readTag: 'name'
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| oc str |
	oc := aProxy childProxy.
	self xslElements do: [:elm | elm process: aNodeContext into: oc].
	oc attributes isEmpty 
	    ifFalse: [self error: 'Comments do not support attributes'].
	str := (String new: 128) writeStream.
	oc children do: 
		[:nd | 
		nd isText 
		    ifFalse: 
			[self 
			    error: 'Comments can only contain text, not elements, pi''s, or other comments'].
		str nextPutAll: nd characterData].
	str := str contents.
	str := str copyReplaceAll: '?>' with: '? >'.
	aProxy addNode: (PI new name: self name text: str)
    ]
]

]



Namespace current: XSL [

CountingCommand subclass: CounterCommand [
    | name |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Counting'>

    CounterCommand class >> tag [
	<category: 'accessing'>
	^'counter'
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	super testPatternInitialized.
	name := self readAttribute: 'name'.
	userData := true
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| c |
	c := aProxy counterNamed: self name.
	c == nil 
	    ifFalse: 
		[aProxy 
		    add: (Text new text: (self format: (Array with: c value) for: aNodeContext))]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ApplyTemplatesCommand [
    | selectPattern sortList mode |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    ApplyTemplatesCommand class >> tag [
	<category: 'accessing'>
	^'apply-templates'
    ]

    addSortBlock: aSortCommand [
	<category: 'accessing'>
	sortList == nil ifTrue: [sortList := #()].
	sortList := sortList copyWith: aSortCommand
    ]

    mode [
	<category: 'accessing'>
	self testPatternInitialized.
	^mode
    ]

    selectPattern [
	<category: 'accessing'>
	self testPatternInitialized.
	^selectPattern
    ]

    sortList [
	<category: 'accessing'>
	^sortList
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	selectPattern := self readSelectPattern: 'select' default: [nil].
	mode := self readAttribute: 'mode' default: [nil]
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| list rule arguments argList listCopy |
	self selectPattern == nil 
	    ifTrue: [list := self xslNodesFrom: aNodeContext]
	    ifFalse: 
		[list := self selectAll: aNodeContext withPattern: self selectPattern].
	self sortList == nil 
	    ifTrue: 
		[list
		    documentOrder;
		    ensureSorted]
	    ifFalse: 
		[listCopy := list shallowCopy.
		list sort: 
			[:n1 :n2 | 
			self 
			    collate: n1
			    to: n2
			    within: listCopy]].
	arguments := Dictionary new.
	argList := self xslElements.
	1 to: argList size
	    do: [:i | (argList at: i) process: aNodeContext intoArgs: arguments].
	list reset.
	[list atEnd] whileFalse: 
		[list variables: list variables clone.
		rule := list db ruleMatching: list next mode: self mode.
		rule == nil 
		    ifFalse: 
			[rule 
			    process: list
			    into: aProxy
			    arguments: arguments]]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: RuleSet [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Top Level'>

    RuleSet class >> tag [
	<category: 'accessing'>
	^'stylesheet'
    ]

    defineParameter: aVariable [
	<category: 'accessing'>
	^self
    ]

    defineVariable: aVariable [
	<category: 'accessing'>
	^self
    ]

    purgeUnimportant [
	<category: 'accessing'>
	elements := self children 
		    select: [:i | i isElement and: [i isStylesheetEntry]].
	elements do: [:i | i purgeUnimportant]
    ]

    addToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self children do: [:elm | elm addToRuleDB: aDB]
    ]

    topLevelAddToRuleDB: aDB [
	"This is only understood by a small subset of commands."

	<category: 'loading'>
	self children do: [:elm | elm addToRuleDB: aDB]
    ]
]

]



Namespace current: XSL [

Object subclass: NodeIterator [
    | stack current |
    
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    reverseDo: aBlock until: testBlock [
	<category: 'enumeration'>
	| t |
	[testBlock value: current] whileFalse: 
		[aBlock value: current.
		stack isEmpty ifTrue: [^self].
		
		[stack last value = 1 
		    ifTrue: [current := stack removeLast key]
		    ifFalse: 
			[t := stack last.
			t value: t value - 1.
			current := t key children at: t value.
			[current isElement not or: [current children size = 0]] whileFalse: 
				[stack add: current -> current children size.
				current := current children last]].
		current isContent and: [current isText not]] 
			whileFalse]
    ]

    node: aNode [
	<category: 'accessing'>
	| nd |
	nd := current := aNode.
	stack := OrderedCollection new.
	[nd parent == nil] whileFalse: 
		[stack addFirst: nd parent -> (nd parent children indexOf: nd).
		nd := nd parent]
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: AttributeCommand [
    | name |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    AttributeCommand class >> tag [
	<category: 'accessing'>
	^'attribute'
    ]

    generatesAttributes [
	<category: 'testing'>
	^true
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	name := self readTag: 'name'
    ]

    name [
	<category: 'accessing'>
	self testPatternInitialized.
	^name
    ]

    generateFrom: aNode into: aProxy [
	<category: 'processing'>
	| oc computedValue nm |
	oc := aProxy childProxy.
	self xslElements do: [:elm | elm process: aNode into: oc].
	oc attributes isEmpty 
	    ifFalse: [self error: 'Attributes cannot have attributes'].
	computedValue := (String new: 32) writeStream.
	oc children do: 
		[:elm | 
		elm isText 
		    ifFalse: [self error: 'Attribute values can only contain text data'].
		computedValue nextPutAll: elm characterData].
	nm := self processAttributeValue: self name for: aNode.
	nm := self resolveComputedTag: nm.
	^Attribute new name: nm value: computedValue contents
    ]

    process: aNode into: aProxy [
	<category: 'processing'>
	| oc computedValue nm |
	aProxy children size = 0 
	    ifFalse: [self error: 'Attributes must all be added before content'].
	oc := aProxy childProxy.
	self xslElements do: [:elm | elm process: aNode into: oc].
	oc attributes isEmpty 
	    ifFalse: [self error: 'Attributes cannot have attributes'].
	computedValue := (String new: 32) writeStream.
	oc children do: 
		[:elm | 
		elm isText 
		    ifFalse: [self error: 'Attribute values can only contain text data'].
		computedValue nextPutAll: elm characterData].
	nm := self processAttributeValue: self name for: aNode.
	nm := self resolveComputedTag: nm.
	aProxy 
	    addAttribute: (Attribute new name: nm value: computedValue contents)
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: TextCommand [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    TextCommand class >> tag [
	<category: 'accessing'>
	^'text'
    ]

    shouldStrip [
	<category: 'testing'>
	^false
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	(self readAttribute: 'disable-output-escaping' default: ['no']) = 'yes' 
	    ifTrue: [aProxy addNode: (DenormalizedText new text: self characterData)]
	    ifFalse: [aProxy addNode: (Text new text: self characterData)]
    ]
]

]



Namespace current: XSL [

XML.SAXWriter subclass: SAXTextWriter [
    
    <comment: nil>
    <category: 'XSL-XSL-Output'>

    characters: aString from: start to: stop [
	<category: 'content handler'>
	output 
	    next: stop + 1 - start
	    putAll: aString
	    startingAt: start
    ]

    endElement: namespaceURI localName: localName qName: name [
	<category: 'content handler'>
	^self
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	^self
    ]
]

]



Namespace current: XSL [

GeneralCountingProxy subclass: CountingProxy [
    
    <category: 'XSL-XSL-Support'>
    <comment: nil>

    add: element [
	<category: 'building'>
	nextLink add: element
    ]

    addAttribute: attribute [
	<category: 'building'>
	nextLink addAttribute: attribute
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: CopyOfCommand [
    | expression |
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes'>

    CopyOfCommand class >> tag [
	<category: 'accessing'>
	^'copy-of'
    ]

    copyNode: n to: aContainer [
	<category: 'processing'>
	| new |
	n isDocument ifTrue: [^self copyNode: n root to: aContainer].
	n isAttribute ifTrue: [^aContainer addAttribute: n copy].
	n isElement ifFalse: [^aContainer addNode: n copy].
	new := n class 
		    tag: n tag
		    attributes: (n attributes collect: [:a | a copy])
		    elements: nil.
	n children do: [:c | self copyNode: c to: new].
	aContainer addNode: new
    ]

    copyNodes: sortedNodes into: aProxy [
	<category: 'processing'>
	sortedNodes do: [:n | self copyNode: n to: aProxy]
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	| elm |
	elm := self expression xpathValueIn: aNodeContext.
	elm xpathIsNodeSet 
	    ifTrue: [self copyNodes: elm sortedNodes into: aProxy]
	    ifFalse: 
		[(elm isKindOf: ElementProxy) 
		    ifTrue: [self copyNodes: elm children into: aProxy]
		    ifFalse: [aProxy add: (Text new text: elm xpathAsString value)]]
    ]

    expression [
	<category: 'accessing'>
	self testPatternInitialized.
	^expression
    ]

    testPatternInitialized [
	<category: 'initialize'>
	userData ifTrue: [^self].
	userData := true.
	expression := self readSelectPattern: 'select'
    ]
]

]



Namespace current: XSL [

XSLCommand subclass: ChooseOtherwiseCommand [
    
    <comment: nil>
    <category: 'XSL-XSL-Nodes-Control'>

    ChooseOtherwiseCommand class >> tag [
	<category: 'accessing'>
	^'otherwise'
    ]

    process: aNodeContext into: aProxy [
	<category: 'processing'>
	self shouldNotImplement
    ]
]

]



Namespace current: XSL [
    XSL at: #XSL_URI put: 'http://www.w3.org/1999/XSL/Transform'.
    XSL XSLCommand initialize
]

