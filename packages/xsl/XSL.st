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



Smalltalk addSubspace: #XSL!

Namespace current: XSL!

XML.NodeBuilder subclass: #XSLNodeBuilder
    instanceVariableNames: 'nodeNameMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

XML.XPathNodeContext subclass: #XSLNodeContext
    instanceVariableNames: 'db mode '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-XSL'!

Object subclass: #RuleDatabase
    instanceVariableNames: 'rules variables normalized namedTemplates attributeSets currentImportance uriStack output '
    classVariableNames: ''
    poolDictionaries: 'XML'
    category: 'XSL-XSL-Support'!

XML.Text subclass: #DenormalizedText
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XML.Element subclass: #XSLCommand
    instanceVariableNames: ''
    classVariableNames: 'XPathExtensionFunctions'
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #CallTemplateCommand
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XSLCommand subclass: #XSLDefinition
    instanceVariableNames: 'importance '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLDefinition subclass: #Include
    instanceVariableNames: 'href '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Top Level'!

XSLDefinition subclass: #AttributeSet
    instanceVariableNames: 'name useAttrs '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Top Level'!

XSLCommand subclass: #CounterScopeCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

XSLCommand subclass: #CommentCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #ForEachCommand
    instanceVariableNames: 'selectPattern sortList variables '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XSLCommand subclass: #SortCommand
    instanceVariableNames: 'selectPattern order lang dataType caseOrder '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XSLDefinition subclass: #DecimalFormat
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #ElementCommand
    instanceVariableNames: 'name useAttrs '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #CountingCommand
    instanceVariableNames: 'format prefix postfix lang letterValue digitGroupSep digitsPerGroup sequenceSrc '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

CountingCommand subclass: #CountersCommand
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

XSLDefinition subclass: #ParamDefinition
    instanceVariableNames: 'name expression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #ChooseWhenCommand
    instanceVariableNames: 'testPattern '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XSLCommand subclass: #WithParamCommand
    instanceVariableNames: 'name expression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLDefinition subclass: #Import
    instanceVariableNames: 'href '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Top Level'!

XSLCommand subclass: #Template
    instanceVariableNames: 'hasStripped '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLDefinition subclass: #VariableDefinition
    instanceVariableNames: 'name expression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #CounterIncrementCommand
    instanceVariableNames: 'name amount '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

Array variableSubclass: #Rank
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

Link subclass: #NumberFormat
    instanceVariableNames: 'format separator '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

XML.Text subclass: #TextTemplate
    instanceVariableNames: 'hasStripped '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

CountingCommand subclass: #NumberCommand
    instanceVariableNames: 'level count from '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

XSLDefinition subclass: #OutputCommand
    instanceVariableNames: 'method version encoding omitXmlDeclaration standalone doctypePublic doctypeSystem cdataSectionElements indent mediaType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #CopyCommand
    instanceVariableNames: 'useAttrs '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #ValueOfCommand
    instanceVariableNames: 'expression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLDefinition subclass: #Rule
    instanceVariableNames: 'pattern name specific priority mode variables '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Top Level'!

XSLCommand subclass: #CounterResetCommand
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

XML.SAXWriter subclass: #SAXHtmlWriter
    instanceVariableNames: 'htmlSpecialEmptyTags '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Output'!

XSLCommand subclass: #ChooseCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

Dictionary variableSubclass: #ChainedDictionary
    instanceVariableNames: 'parent '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Top Level'!

XSLCommand subclass: #IfCommand
    instanceVariableNames: 'testPattern '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XML.PI subclass: #XSL_PI
    instanceVariableNames: 'block '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

Link subclass: #GeneralCountingProxy
    instanceVariableNames: 'counters '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

GeneralCountingProxy subclass: #ElementProxy
    instanceVariableNames: 'contents attributes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

XSLCommand subclass: #PICommand
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

CountingCommand subclass: #CounterCommand
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Counting'!

XSLCommand subclass: #ApplyTemplatesCommand
    instanceVariableNames: 'selectPattern sortList mode '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XSLCommand subclass: #RuleSet
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Top Level'!

Object subclass: #NodeIterator
    instanceVariableNames: 'stack current '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

XSLCommand subclass: #AttributeCommand
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #TextCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XML.SAXWriter subclass: #SAXTextWriter
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Output'!

GeneralCountingProxy subclass: #CountingProxy
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Support'!

XSLCommand subclass: #CopyOfCommand
    instanceVariableNames: 'expression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes'!

XSLCommand subclass: #ChooseOtherwiseCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XSL-XSL-Nodes-Control'!

XSL at: #'XSL_URI' put: 'http://www.w3.org/1999/XSL/Transform' !

!XSLNodeBuilder methodsFor: 'building'!

makeText: text
    ^TextTemplate text: text!

pi: nm text: text
    ^XSL_PI new name: nm text: text!

tag: tag attributes: attributes elements: elements position: p stream: stream
    | elementClass |
    elementClass := tag namespace = XSL_URI
    	ifTrue: [self nodeNameMap
    				at: tag type
    				ifAbsent: [self error: 'The action ', tag asString, ' is not yet implemented']]
    	ifFalse: [Template].
    ^elementClass tag: tag attributes: attributes elements: elements! !

!XSLNodeBuilder methodsFor: 'private'!

nodeNameMap
    nodeNameMap == nil
    	ifTrue:
    		[nodeNameMap := Dictionary new.
    		XSLCommand withAllSubclasses do: [:beh |
    			beh tag == nil ifFalse: [nodeNameMap at: beh tag put: beh]]].
    ^nodeNameMap! !

!XSLNodeContext methodsFor: 'accessing'!

db
    ^db!

db: aRuleDatabase
    db := aRuleDatabase!

mode
    ^mode!

mode: aSymbol
    mode := aSymbol! !

!RuleDatabase methodsFor: 'importance'!

importance
    ^currentImportance!

importance: aValueHolder
    currentImportance := aValueHolder!

raiseImportance
    currentImportance := (currentImportance value + 1) asValue!

replaceImportance: oldValue
    variables do: [:clist |
    	clist do: [:c |
    		c replaceImportance: oldValue with: currentImportance]].
    namedTemplates do: [:mlist |
    	mlist do: [:m |
    		m replaceImportance: oldValue with: currentImportance]].
    rules do: [:r |
    	r replaceImportance: oldValue with: currentImportance]! !

!RuleDatabase methodsFor: 'loading'!

addAttributeSet: anAttributeSet
    | all |
    anAttributeSet importanceHolder: currentImportance.
    all := attributeSets at: anAttributeSet name
    		ifAbsentPut: [OrderedCollection new].
    all add: anAttributeSet!

addNamedTemplate: aRule
    | all |
    aRule importanceHolder: currentImportance.
    all := namedTemplates at: aRule name
    		ifAbsentPut: [OrderedCollection new].
    (all contains: [:c | c importance = currentImportance value])
    	ifTrue: [self error: ('There are two named templates named %1 with the same importance' % { aRule name })].
    all add: aRule!

addRule: aRule
    aRule importanceHolder: currentImportance.
    rules add: aRule!

addRuleSet: anXSLCommand topLevel: isTopLevel
    anXSLCommand purgeUnimportant.
    isTopLevel
    	ifTrue: [anXSLCommand topLevelAddToRuleDB: self]
    	ifFalse: [anXSLCommand addToRuleDB: self].!

addVariable: aVariable
    | all |
    aVariable importanceHolder: currentImportance.
    all := variables at: aVariable name
    		ifAbsentPut: [OrderedCollection new].
    (all contains: [:c | c importance = currentImportance value])
    	ifTrue: [self error: ('There are two variables named %1 with the same importance' % { aVariable name })].
    all add: aVariable!

attributesForSet: setName
    | list map |
    list := attributeSets at: setName
    	ifAbsent: [self error: ('No attribute set named "%1".' % { setName asString })].
    map := Dictionary new.
    list do: [:as |
    	(as allAttributesFrom: self) do: [:attr |
    		(map at: attr name ifAbsentPut: [SortedCollection sortBlock: [:a1 :a2 | a1 key > a2 key]])
    			add: as importance->attr]].
    list := OrderedCollection new.
    map do: [:singleList |
    	(singleList size > 1 and: [(singleList at: 1) key = (singleList at: 2) key])
    		ifTrue: [self error: ('Attribute set "%1" includes more than one definition of the attribute "%2".'
    					% { setName asString.
    					    singleList first name asString })].
    	list add: singleList first value].
    ^list!

bindVariableValues: aNodeContext arguments: argDictionary
    variables do: [:var |
    	var process: aNodeContext into: nil takeArgumentsFrom: argDictionary]!

normalizeRules
    normalized ifTrue: [^self].
    normalized := true.
    self normalizeVariables.
    namedTemplates keys do: [:nm || clist |
    	clist := namedTemplates at: nm.
    	(clist collect: [:c | c importance]) asSet size = clist size
    		ifFalse: [self error: 'Named template named "',nm,'" has more than one definition with the same importance'].
    	namedTemplates at: nm put: (clist asSortedCollection: [:c1 :c2 | c1 importance < c2 importance]) last].
    namedTemplates do: [:m | m normalize].
    rules do: [:r | r normalize].!

normalizeVariables
    | unsorted sorted lastSize list |
    variables class == Dictionary ifFalse: [^self].
    variables keys do: [:nm || clist |
    	clist := variables at: nm.
    	(clist collect: [:c | c importance]) asSet size = clist size
    		ifFalse: [self error: 'Variable named "',nm,'" has more than one definition with the same importance'].
    	variables at: nm put: (clist asSortedCollection: [:c1 :c2 | c1 importance < c2 importance]) last].
    variables do: [:c | c normalize].
    unsorted := variables asOrderedCollection.
    sorted := OrderedCollection new.
    lastSize := -1.
    [sorted size = lastSize] whileFalse:
    	[lastSize := sorted size.
    	unsorted copy do: [:var |
    		list := var expression xpathUsedVarNames.
    		list := list reject: [:nm | sorted includes: nm].
    		list isEmpty
    			ifTrue:
    				[sorted add: var name.
    				unsorted remove: var]]].
    unsorted isEmpty ifFalse: [self error: 'There is a cycle of reference between the variables'].
    variables := sorted collect: [:v | variables at: v].!

readFileNamed: aFilename
    | doc |
    self initURI: 'file' name: aFilename asString.
    doc := XMLParser
    	processDocumentInFilename: aFilename
    	beforeScanDo:
    		[:parser |
    		parser builder: XSLNodeBuilder new.
    		parser validate: false].
    self addRuleSet: doc root topLevel: true!

readStream: aStream
    self readStream: aStream topLevel: true!

readStream: aStream topLevel: isTopLevel
    | doc parser |
    parser := XMLParser on: aStream.
    parser builder: XSLNodeBuilder new.
    parser validate: false.
    doc := parser scanDocument.
    self addRuleSet: doc root topLevel: isTopLevel!

readString: aString
    | doc |
    self initURI: 'file' name: (Directory append: 'xxx' to: Directory working).
    doc := XMLParser
    	processDocumentString: aString
    	beforeScanDo:
    		[:parser |
    		parser builder: XSLNodeBuilder new.
    		parser validate: false].
    self addRuleSet: doc root topLevel: true!

resolveAttributesForSet: setName
    | list |
    list := attributeSets at: setName
    	ifAbsent: [self error: ('No attribute set named "%1".' % { setName asString })].!

setOutput: anOutputCommand
    output := anOutputCommand!

uriStack
    ^uriStack! !

!RuleDatabase methodsFor: 'processing'!

chooseBestRule: ruleList for: aNodeContext
    | best |
    ruleList size = 1 ifTrue: [^ruleList first].
    best := ruleList asSortedCollection:
    				[:r1 :r2 | r1 importance >= r2 importance].
    best := best asOrderedCollection select: [:r1 | r1 importance = best first importance].
    best size = 1 ifTrue: [^best first].
    best := best collect: [:r1 | r1 priority -> r1].
    best := best asSortedCollection: [:a1 :a2 | a1 > a2].
    best := best asOrderedCollection select: [:a1 | a1 key = best first key].
    best := best collect: [:a | a value].
    best size = 1 ifTrue: [^best first].
    best size = 0 ifFalse:
    	[self halt: 'Conflicting rules for ', aNodeContext node simpleDescription, ', use priority to rank the rules.'.
    	^best last].
    ^nil!

process: aDocument
    ^self process: aDocument arguments: Dictionary new!

process: aDocument arguments: passedArguments
    | doc baseDoc baseVars |
    self normalizeRules.
    doc := DocumentFragment new.
    baseVars := Dictionary new.
    baseDoc := XSLNodeContext new
    		add: aDocument;
    		index: 1;
    		variables: baseVars;
    		db: self.
    self bindVariableValues: baseDoc arguments: passedArguments.
    baseDoc variables: (ChainedDictionary new parent: baseVars).
    (self process: baseDoc into: ElementProxy new mode: nil) children do: [:elm |
    	doc addNode: elm].
    doc addNamespaceDefinitions.
    ^doc!

process: aNodeContext into: aProxy mode: mode
    | rule list |
    list := rules select: [:r | r match: aNodeContext].
    list := list select: [:r | r modeIsLike: mode].
    rule := self chooseBestRule: list for: aNodeContext.
    rule == nil ifFalse: [rule process: aNodeContext into: aProxy arguments: #()].
    ^aProxy!

ruleMatching: aNodeContext mode: mode
    | rule list |
    list := OrderedCollection new: 5.
    1 to: rules size do: [:i |
    	rule := rules at: i.
    	((rule modeIsLike: mode) and: [rule match: aNodeContext])
    		ifTrue: [list add: rule]].
"	list := rules select: [:r | r match: aNodeContext].
    list := list select: [:r | r modeIsLike: mode]."
    rule := self chooseBestRule: list for: aNodeContext.
    ^rule!

ruleNamed: aName
    ^namedTemplates at: aName ifAbsent: []! !

!RuleDatabase methodsFor: 'initialize'!

initialize
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
    baseRule attributes: (Array with: (Attribute name: 'match' value: 'text()')).
    baseRule elements: (Array with: action).
    baseRule importanceHolder: builtinImportance.
    rules add: baseRule!

initURI: aProtocol name: aName
    uriStack == nil
    	ifTrue: [uriStack := OrderedCollection with: aProtocol->(aName copy asString replaceAll: Directory pathSeparator with: $/)].! !

!RuleDatabase methodsFor: 'accessing'!

output
    output == nil ifTrue: [output := OutputCommand new].
    ^output!

outputMethodFor: aDocument
    | rt |
    self output method = #auto ifFalse: [^self output method].
    rt := aDocument root.
    (rt notNil and: [rt tag namespace isEmpty and: [rt tag type asLowercase = 'html']])
    	ifTrue: [^'html'].
    ^'xml'! !

!RuleDatabase class methodsFor: 'XML for examples'!

constructXML
    "RuleDatabase constructXML"

    ^'<doc a="1" b="2">
    <title c="3" d="4">An example</title>
    <p k="xyz">This is a test.</p>
    <p>This is <emph>another</emph> test.</p>
    </doc>'!

constructXSL
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
    </xsl:stylesheet>'!

macroXML
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
    </doc>'!

macroXSL
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

    </xsl:stylesheet>'!

numberedSourceData
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
'!

numberedXML
    "RuleDatabase numberedXML"

    | src stack str depth parent title tag |
    stack := OrderedCollection new.
    stack add: (Element tag: 'doc').
    src := self numberedSourceData readStream.
    [src atEnd] whileFalse:
    	[str := src upTo: Character nl.
    	depth := str occurrencesOf: Character tab.
    	str := str copyFrom: depth + 1 to: str size.
    	tag := depth = 0
    		ifTrue: [str first isDigit
    			ifTrue: ['chapter']
    			ifFalse: ['appendix']]
    		ifFalse: [#('section' 'subsection') at: depth].
    	str := str copyFrom: (str indexOf: $ )+1 to: str size.
    	[depth + 1 = stack size] whileFalse: [stack removeLast].
    	parent := stack last.
    	title := Text text: str.
    	title := Element tag: 'title' elements: (Array with: title).
    	title := Element tag: tag elements: (Array with: title).
    	stack addLast: title.
    	parent elements: (parent children copyWith: title)].
    ^stack first printString!

numberedXML2
    "RuleDatabase numberedXML2"

    | src stack str depth title tag |
    stack := OrderedCollection new.
    stack add: (Element tag: 'doc').
    src := self numberedSourceData readStream.
    [src atEnd] whileFalse:
    	[str := src upTo: Character nl.
    	depth := str occurrencesOf: Character tab.
    	str := str copyFrom: depth + 1 to: str size.
    	tag := depth = 0
    		ifTrue: ['H1']
    		ifFalse: [#('H2' 'H3' 'H4') at: depth].
    	str := str copyFrom: (str indexOf: $ )+1 to: str size.
    	title := Text text: str.
    	title := Element tag: tag elements: (Array with: title).
    	stack last elements: (stack last children copyWith: title)].
    ^stack first printString!

numberedXSL
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
    </xsl:stylesheet>'!

numberedXSL1
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
    </xsl:stylesheet>'!

numberedXSL2
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

    </xsl:stylesheet>'!

patternsXML
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
    </a>'!

patternsXSL
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

    </xsl:stylesheet>'!

sampleXML
    ^'<doc>
    <title>An example</title>
    <p>This is a test.</p>
    <p>This is <emph>another</emph> test.</p>
    </doc>'!

sampleXSL
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

    </xsl:stylesheet>'! !

!RuleDatabase class methodsFor: 'examples'!

allTest
    "XSL.RuleDatabase allTest"

    | sel |
    sel := self class selectors select: [:s | 'test*' match: s].
    sel asSortedCollection do:
    	[:s |
    	self perform: s].!

examplesDirectory
    ^Directory append: 'xml' to: Directory image!

store: document on: filename
    (FileStream open: filename mode: FileStream write)
    	print: document;
    	close!

test
    "RuleDatabase test"

    | test doc |
    test := self new.
    test readString: self sampleXSL.
    doc := XMLParser
    		processDocumentString: self sampleXML
    		beforeScanDo: [:parser | parser validate: false].
    ^test process: doc!

test2
    "RuleDatabase test2"

    | test doc default result |
    default := self examplesDirectory.
    test := self new.
    test readFileNamed: (default nameAt: 'activityinfo.xsl').
    doc := XMLParser
    		processDocumentInFilename: (default nameAt: 'activityinfo.xml')
    		beforeScanDo: [:parser | parser validate: false].
    result := test process: doc.
    self store: result on: 'activityinfo.html'!

test2a
    "RuleDatabase test2a"

    | test doc default result |
    default := self examplesDirectory.
    test := self new.
    test readFileNamed: (default nameAt: 'activityinfo2.xsl').
    doc := XMLParser
    		processDocumentInFilename: (default nameAt: 'activityinfo.xml')
    		beforeScanDo: [:parser | parser validate: false].
    result := test process: doc.
    self store: result on: 'activityinfo2.html'.!

test2b
    "RuleDatabase test2b"

    | test doc default result |
    default := self examplesDirectory.
    test := self new.
    test readFileNamed: (default nameAt: 'activityinfo3.xsl').
    doc := XMLParser
    		processDocumentInFilename: (default nameAt: 'activityinfo.xml')
    		beforeScanDo: [:parser | parser validate: false].
    result := test process: doc.
    self store: result on: 'activityinfo3.html'.!

test3
    "RuleDatabase test3"

    | test doc default result |
    default := self examplesDirectory.
    test := self new.
    test readFileNamed: (default nameAt: 'listgen.xsl').
    doc := XMLParser
    		processDocumentInFilename: (default nameAt: 'listgen.xml')
    		beforeScanDo: [:parser | parser validate: false].
    result := test process: doc.
    self store: result on: 'listgen.html'.!

test4
    "RuleDatabase test4"

    | test doc |
    test := self new.
    test readString: self numberedXSL.
    doc := XMLParser
    		processDocumentString: self numberedXML
    		beforeScanDo: [:parser | parser validate: false].
    ^test process: doc!

test4a
    "RuleDatabase test4a"

    | test doc |
    test := self new.
    test readString: self numberedXSL1.
    doc := XMLParser
    		processDocumentString: self numberedXML
    		beforeScanDo: [:parser | parser validate: false].
    ^test process: doc!

test4b
    "RuleDatabase test4b"

    | test doc |
    test := self new.
    test readString: self numberedXSL2.
    doc := XMLParser
    		processDocumentString: self numberedXML2
    		beforeScanDo: [:parser | parser validate: false].
    ^test process: doc!

test5
    "RuleDatabase test5"

    | test doc |
    test := self new.
    test readString: self constructXSL.
    doc := XMLParser
    		processDocumentString: self constructXML
    		beforeScanDo: [:parser | parser validate: false].
    ^test process: doc!

test6
    "RuleDatabase test6"

    | test doc |
    test := self new.
    test readString: self patternsXSL.
    doc := XMLParser
    		processDocumentString: self patternsXML.
    ^test process: doc!

test7
    "RuleDatabase test7"

    | test doc |
    test := self new.
    test readString: self macroXSL.
    doc := XMLParser
    		processDocumentString: self macroXML
    		beforeScanDo: [:parser | parser validate: false].
    ^test process: doc! !

!RuleDatabase class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!DenormalizedText methodsFor: 'enumerating'!

saxDo: aDriver
    [aDriver normalizeText: false] on: Error do: [:dummy | ].
    super saxDo: aDriver.
    [aDriver normalizeText: true] on: Error do: [:dummy | ].! !

!XSLCommand methodsFor: 'private'!

checkQNameSyntax: aString
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
    		ifFalse: [ch = $:
    			ifTrue:
    				[valid := true.
    				colons := colons + 1.
    				mode := #colon]
    			ifFalse:
    				[valid := ch isLetter or: [ch isDigit or: ['.-_' includes: ch]].
    				mode := #letterOrDigit]].
    	valid ifFalse: [self error: 'Syntax error in qualified name.']].
    (mode = #colon or: [colons > 1])
    	ifTrue: [self error: 'Syntax error in qualified name.'].!

checkURISyntax: aString
    | n type ch |
    n := aString findLast: [:c | c = $#].
    n = aString size
    	ifTrue: [self error: 'The name for an attribute or element, using the x#y syntax, has no type following the #.'].
    type := aString copyFrom: n + 1 to: aString size.
    ch := type at: 1.
    (ch = $_ or: [ch isLetter])
    	ifFalse: [self error: ('Type name syntax error in "%1".' % { type })].
    2 to: type size do: [:i |
    	ch := type at: i.
    	(ch isLetter or: [ch isDigit or: ['.-_' includes: ch]])
    		ifFalse: [self error: ('Type name syntax error in "%1".' % { type })]]!

collate: node1 to: node2 within: aNodeContext
    | list sign |
    (list := self sortList) == nil
    	ifFalse:
    		[1 to: list size do: [:i |
    			sign := (list at: i) collate: node1 to: node2 within: aNodeContext.
    			sign = 0 ifFalse: [^sign = -1]]].
    ^node1 precedes: node2!

readAttribute: attName
    ^self readAttribute: attName
    	default: [self error: ('%1 needs to have an attribute named %2'
    				% { self tag asString. attName })]!

readAttribute: attName default: def
    | att |
    att := self valueOfAttribute: attName ifAbsent: [nil].
    ^att == nil
    	ifTrue: [def value]
    	ifFalse: [att]!

readInteger: attName default: def
    | att val |
    att := self valueOfAttribute: attName ifAbsent: [nil].
    ^att == nil
    	ifTrue: [def value]
    	ifFalse:
    		[att isEmpty ifTrue: [self error: ('The %1 attribute is empty' % { attName })].
    		att := att readStream.
    		val := Number readFrom: att.
    		val = 0 ifTrue: [self error: 'Bad number format, ', (att instVarAt: 1)].
    		att atEnd ifFalse: [self error: ('The %1 attribute is not a legal integer value' % { attName })].
    		val]!

readMatchPattern: attName
    ^self readMatchPattern: attName
    	default: [self error: ('%1 needs to have an attribute named %2'
    				% { self tag asString. attName })]!

readMatchPattern: attName default: def
    | att |
    att := self valueOfAttribute: attName ifAbsent: [nil].
    ^att == nil
    	ifTrue: [def value]
    	ifFalse: [XPathParser new xmlNode: self;
    							functions: self class xslFunctions;
    							parse: att as: #expression]!

readSelectPattern: attName
    ^self readSelectPattern: attName
    	default: [self error: ('%1 needs to have an attribute named %2'
    				% { self tag asString. attName })]!

readSelectPattern: attName default: def
    | att d |
    att := self valueOfAttribute: attName ifAbsent: [nil].
    ^att == nil
    	ifTrue:
    		[d := def value.
    		d == nil ifFalse: [d := XPathParser new xmlNode: self;
    							functions: self class xslFunctions;
    							parse: d as: #expression].
    		d]
    	ifFalse: [XPathParser new xmlNode: self;
    							functions: self class xslFunctions;
    							parse: att as: #expression]!

readTag: attName
    | att |
    att := self valueOfAttribute: attName ifAbsent: [nil].
    ^att == nil
    	ifTrue: [self error: ('%1 needs to have an attribute named %2'
    				% { self tag asString. attName })]
    	ifFalse: [att]!

readTagList: attName default: defaultBlock
    | att str output buffer ch |
    att := self valueOfAttribute: attName ifAbsent: [nil].
    ^att == nil
    	ifTrue: [defaultBlock value]
    	ifFalse:
    		[str := att readStream.
    		output := OrderedCollection new.
    		buffer := String new writeStream.
    		[str skipSeparators; atEnd]
    			whileFalse:
    				[[(ch := str next) notNil and: [ch isSeparator not]]
    					whileTrue: [buffer nextPut: ch].
    				output add: buffer contents.
    				buffer reset].
    		output asArray]!

xslNodesFrom: aNodeContext
    | list nc |
    list := aNodeContext node
    	selectNodes: [:nd | nd isAttribute not or: [nd tag qualifier ~= 'xmlns']].
    nc := aNodeContext copy documentOrder.
    nc addAll: list.
    ^nc! !

!XSLCommand methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self shouldNotImplement! !

!XSLCommand methodsFor: 'accessing'!

defaultTag
    ^'xsl:', self class tag!

defineVariable: aVariable
    self parent defineVariable: aVariable!

purgeUnimportant
    self subclassResponsibility!

sortList
    "Answer a list of sort blocks that take two arguments,
    and return -1 if the arguments are in order, 1 if they
    are in reversed order, and 0 if that particular sort block
    cannot order them."

    ^nil!

xslElements
    ^self children select: [:i | i isContent]! !

!XSLCommand methodsFor: 'testing'!

generatesAttributes
    ^false!

isStylesheetEntry
    Transcript nl; tab; show: ('Stylesheet contains a top-level element that is not permitted (%1)'
    		% { self tag }).
    Transcript nl; tab; show: 'It has been ignored'.
    ^false!

shouldStrip
    ^true! !

!XSLCommand methodsFor: 'initialize'!

initialize
    super initialize.
    elements := #().
    userData := false!

normalize
    self stripSpace.
    self xslElements do: [:elm | elm normalize].!

stripSpace
    self shouldStrip
    	ifTrue: [self elements: (self children select: [:t | t isBlankText not])].!

testPatternInitialized
    userData := true.! !

!XSLCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self subclassResponsibility!

process: aNodeContext into: aProxy takeArgumentsFrom: arguments
    self process: aNodeContext into: aProxy!

processAttributeSets: aNodeContext into: aProxy
    | list vars |
    self useAttrs isEmpty ifTrue: [^self].
    vars := aNodeContext variables.
    aNodeContext variables: vars parent.
    self useAttrs do: [:attSetName |
    	list := aNodeContext db attributesForSet: attSetName.
    	list do: [:att | att process: aNodeContext into: aProxy]].
    aNodeContext variables: vars.!

processAttributeValue: aString for: aNodeContext
    | source ch output elm p expr |
    source := XPathReadStream on: aString.
    output := (String new: 64) writeStream.
    [source atEnd]
    	whileFalse:
    		[ch := source next.
    		ch = ${
    			ifTrue:
    				[(source peekFor: ${)
    					ifTrue: [output nextPut: ${]
    					ifFalse:
    						[p := XPathParser new.
    						p initScanner;
    							xmlNode: self;
    							functions: self class xslFunctions;
    							init: source notifying: nil failBlock: nil.
    						p expression.
    						p atEndOfExpression ifFalse: [self error: 'Syntax error in: ', aString storeString].
    						expr := p result.
    						elm := expr xpathValueIn: aNodeContext.
    						output nextPutAll: elm xpathAsString.

    						"Not needed with our XPath parser!"
						"p pastEnd ifFalse: [source skip: -1]" ]]
    			ifFalse: [ch = $}
    				ifTrue:
    					[source next = $} ifFalse: [self error: 'Expected doubled }'].
    					output nextPut: $}]
    				ifFalse: [output nextPut: ch]]].
    ^output contents!

resolveComputedTag: nm
    | n type ns qualifier |
    ^(nm includes: $#)
    	ifTrue:
    		[self checkURISyntax: nm.
    		n := nm findLast: [:c | c = $#].
    		type := nm copyFrom: n + 1 to: nm size.
    		ns := nm copyFrom: 1 to: n - 1.
    		qualifier := self findQualifierAtNamespace: 'quote:', ns.
    		qualifier == nil
    			ifTrue: [qualifier := self findQualifierAtNamespace: ns].
    		qualifier == nil ifTrue: [self error: ('The namespace %1 has not been bound to a qualifier in this stylesheet, and automatic creation of qualifiers has not been implemented.' % { ns })].
    		NodeTag new qualifier: qualifier ns: ns type: type]
    	ifFalse:
    		[self checkQNameSyntax: nm.
    		self resolveTag: nm].!

resolveTag: aTagString
    | c qual ns |
    c := aTagString occurrencesOf: $:.
    ^c = 0
    	ifTrue: [NodeTag new qualifier: '' ns: '' type: aTagString]
    	ifFalse: [c > 1
    		ifTrue: [self error: 'A qualified name has too many colons.']
    		ifFalse:
    			[c := aTagString indexOf: $:.
    			(c = 1 or: [c = aTagString size])
    				ifTrue: [self error: 'A qualified name cannot begin or end with a colon.'].
    			qual := aTagString copyFrom: 1 to: c - 1.
    			ns := self findNamespaceAt: qual.
    			ns == nil ifTrue: [self error: ('The namespace qualifier %1 has not been bound to a namespace in this stylesheet' % { qual })].
    			"Use a # in the match to make sure there's at least one more character"
    			('quote:#*' match: ns)
    				ifTrue: [ns := ns copyFrom: 'quote:' size + 1 to: ns size].
    			NodeTag new qualifier: qual ns: ns type: (aTagString copyFrom: c + 1 to: aTagString size)]]!

selectAll: startNode withPattern: pattern
    ^pattern xpathValueIn: startNode!

valueAsVariableIn: aNodeContext
    | new list |
    ^self expression == nil
    	ifTrue:
    		[new := ElementProxy new.
    		list := self xslElements.
    		1 to: list size do: [:i || elm |
    			elm := list at: i.
    			elm process: aNodeContext into: new].
    		new]
    	ifFalse: [self expression xpathValueIn: aNodeContext]! !

!XSLCommand class methodsFor: 'accessing'!

tag
    ^nil!

xslFunctions
    ^XPathExtensionFunctions! !

!XSLCommand class methodsFor: 'xpath'!

formatNumber: aNumber pattern: pattern formatName: formatName in: aNodeContext
    ^aNumber xpathAsString! !

!XSLCommand class methodsFor: 'class initialization'!

initialize
    "XSLCommand initialize"

    | functions |
    functions := ChainedDictionary new.
    functions parent: XPathFunction baseFunctions.
    functions at: 'format-number' put: (XPathFunction new
    		name: 'format-number';
    		valueBlock: [:fn :ns || n s1 s2 |
    				(fn arguments size between: 2 and: 3)
    					ifFalse: [self error: 'format-number() takes two or three arguments.'].
    				n := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsNumber.
    				s1 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
    				fn arguments size = 3
    					ifTrue: [s2 := ((fn arguments at: 3) xpathEvalIn: ns) xpathAsString]
    					ifFalse: [s2 := nil].
    				self formatNumber: n pattern: s1 formatName: s2 in: ns]).
    XPathExtensionFunctions := functions.! !

!CallTemplateCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | rule arguments list vars |
    rule := aNodeContext db ruleNamed: self name.
    arguments := Dictionary new.
    list := self xslElements.
    1 to: list size do: [:i |
    	(list at: i) process: aNodeContext intoArgs: arguments].
    rule == nil
    	ifTrue: [self error: 'Named template not found']
    	ifFalse:
    		[vars := aNodeContext variables.
    		aNodeContext variables: vars clone.
    		rule process: aNodeContext into: aProxy arguments: arguments.
    		aNodeContext variables: vars]! !

!CallTemplateCommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name! !

!CallTemplateCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readAttribute: 'name' default: [nil]! !

!CallTemplateCommand class methodsFor: 'accessing'!

tag
    ^'call-template'! !

!XSLDefinition methodsFor: 'accessing'!

importance
    ^importance value!

importanceHolder: aValueHolder
    importance := aValueHolder!

replaceImportance: oldValue with: currentImportance
    importance == oldValue
    	ifTrue: [importance := currentImportance]! !

!XSLDefinition methodsFor: 'testing'!

isStylesheetEntry
    ^true! !

!XSLDefinition methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self subclassResponsibility! !

!Include methodsFor: 'accessing'!

href
    self testPatternInitialized.
    ^href!

purgeUnimportant
    elements == nil ifFalse: [self error: 'Includes should not have contents.'].
    (self parent isKindOf: RuleSet)
    	ifFalse: [self error: self tag asString, ' can only be used at the top level'].! !

!Include methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    href := self readAttribute: 'href'.! !

!Include methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    | uri save |
    save := aDB importance.
    aDB importance: save copy.
    uri := aDB uriStack last resolveRelativePath: self href.
    aDB uriStack addLast: uri.
    aDB readStream: uri resource topLevel: false.
    aDB uriStack removeLast.
    aDB replaceImportance: save! !

!Include class methodsFor: 'accessing'!

tag
    ^'include'! !

!AttributeSet methodsFor: 'accessing'!

allAttributesFrom: aDB
    | all |
    all := Dictionary new.
    useAttrs do: [:setName |
    	(aDB attributesForSet: setName)
    		do: [:attr | all at: attr name put: attr]].
    self xslElements do: [:attr |
    	attr class == AttributeCommand ifFalse: [self error: 'Attribute sets only contain attributes'].
    	all at: attr name put: attr].
    ^all asOrderedCollection!

name
    self testPatternInitialized.
    ^name! !

!AttributeSet methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    aDB addAttributeSet: self! !

!AttributeSet methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | list |
    list := self xslElements.
    1 to: list size do: [:i || elm |
    	elm := list at: i.
    	elm process: aNodeContext into: aProxy].! !

!AttributeSet methodsFor: 'initialize'!

purgeUnimportant
    elements := self children reject: [:i | i isBlankText].
    elements do: [:elm |
    	elm generatesAttributes
    		ifFalse: [self error: 'xsl:attribute-set can contain only xsl:attribute and xsl:use']]!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readAttribute: 'name'.
    useAttrs := self readTagList: 'use-attribute-sets' default: [#()].! !

!AttributeSet class methodsFor: 'accessing'!

tag
    ^'attribute-set'! !

!CounterScopeCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | tempProxy |
    tempProxy := aProxy countingProxy.
    self xslElements do: [:elm |
    	elm process: aNodeContext into: tempProxy].! !

!CounterScopeCommand class methodsFor: 'accessing'!

tag
    ^'counter-scope'! !

!CommentCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | oc str |
    oc := aProxy childProxy.
    self xslElements do: [:elm |
    	elm process: aNodeContext into: oc].
    oc attributes isEmpty ifFalse: [self error: 'Comments do not support attributes'].
    str := (String new: 128) writeStream.
    oc children do: [:nd |
    	nd isText ifFalse: [self error: 'Comments can only contain text, not elements, pi''s, or other comments'].
    	str nextPutAll: nd characterData].
    str := str contents.
    	"Need to do this twice to handle comments with a long run of -----"
    str := str copyReplaceAll: '--' with: '- -'.
    str := str copyReplaceAll: '--' with: '- -'.
    str last = $- ifTrue: [str := str copyWith: $ ].
    aProxy addNode: (Comment new text: str)! !

!CommentCommand class methodsFor: 'accessing'!

tag
    ^'comment'! !

!ForEachCommand methodsFor: 'accessing'!

addSortBlock: aSortCommand
    sortList == nil ifTrue: [sortList := #()].
    sortList := sortList copyWith: aSortCommand!

defineVariable: aVariable
    variables add: aVariable.
    self parent defineVariable: aVariable!

selectPattern
    self testPatternInitialized.
    ^selectPattern!

sortList
    ^sortList! !

!ForEachCommand methodsFor: 'initialize'!

initialize
    super initialize.
    elements := nil.
    variables := OrderedCollection new: 0.!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    selectPattern := self readSelectPattern: 'select'! !

!ForEachCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | list elms listCopy |
    elms := self xslElements.
    list := self selectAll: aNodeContext withPattern: self selectPattern.
    self sortList == nil
    	ifTrue: [list documentOrder; ensureSorted]
    	ifFalse:
    		[listCopy := list shallowCopy.
    		list sort: [:n1 :n2 | self collate: n1 to: n2 within: listCopy]].
    list reset.
    [list atEnd]
    	whileFalse:
    		[list next.
    		1 to: elms size do: [:i || elm |
    			elm := elms at: i.
    			elm process: list into: aProxy]]! !

!ForEachCommand class methodsFor: 'accessing'!

tag
    ^'for-each'! !

!SortCommand methodsFor: 'accessing'!

caseOrder
    self testPatternInitialized.
    ^caseOrder!

dataType
    self testPatternInitialized.
    ^dataType!

lang
    self testPatternInitialized.
    ^lang!

order
    self testPatternInitialized.
    ^order!

selectPattern
    self testPatternInitialized.
    ^selectPattern! !

!SortCommand methodsFor: 'initialize'!

normalize
    super normalize.
    (self parent respondsTo: #addSortBlock:)
    	ifFalse: [self error: self tag asString, ' can''t be a child element of ', self parent tag asString].
    self parent addSortBlock: self!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    selectPattern := self readSelectPattern: 'select' default: ['.'].
    order := self readAttribute: 'order' default: ['ascending'].
    lang := self readAttribute: 'lang' default: [nil].
    dataType := self readAttribute: 'data-type' default: ['text'].
    caseOrder := self readAttribute: 'case-order' default: ['upper-first'].! !

!SortCommand methodsFor: 'processing'!

collate: node1 to: node2 within: aNodeContext
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
    ^result!

process: aNodeContext into: aProxy
    "Do nothing. I am only present as a modifier on for-each or apply-templates"
    ^self!

process: aNodeContext intoArgs: aDictionary
    "Do nothing. I am only present as a modifier on for-each or apply-templates.
    For compatibility with <with-parm>"
    ^self! !

!SortCommand class methodsFor: 'accessing'!

tag
    ^'sort'! !

!DecimalFormat methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self notYetImplemented! !

!DecimalFormat methodsFor: 'accessing'!

purgeUnimportant
    elements == nil ifFalse: [self error: 'Format declarations should not have contents']! !

!DecimalFormat class methodsFor: 'accessing'!

tag
    ^'decimal-format'! !

!ElementCommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name!

useAttrs
    self testPatternInitialized.
    ^useAttrs! !

!ElementCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readTag: 'name'.
    useAttrs := self readTagList: 'use-attribute-sets' default: [#()].! !

!ElementCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | oc nm list |
    oc := aProxy childProxy.
    self processAttributeSets: aNodeContext into: oc.
    list := self xslElements.
    1 to: list size do: [:i || elm |
    	elm := list at: i.
    	elm process: aNodeContext into: oc].
    nm := self processAttributeValue: self name for: aNodeContext.
    nm := self resolveComputedTag: nm.
    aProxy addNode: (Element tag: nm attributes: oc attributes elements: oc children)! !

!ElementCommand class methodsFor: 'accessing'!

tag
    ^'element'! !

!CountingCommand methodsFor: 'accessing'!

digitGroupSep
    self testPatternInitialized.
    ^digitGroupSep!

digitsPerGroup
    self testPatternInitialized.
    ^digitsPerGroup!

format
    self testPatternInitialized.
    ^format!

lang
    self testPatternInitialized.
    ^lang!

letterValue
    self testPatternInitialized.
    ^letterValue!

sequenceSrc
    self testPatternInitialized.
    ^sequenceSrc! !

!CountingCommand methodsFor: 'private'!

format: number by: aFormat
    | n s |
    aFormat size = 1
    	ifFalse: [self error: ('Unrecognized number format = "%1"' % { aFormat })].
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
    aFormat = 'i'
    	ifTrue:
    		[^self romanNumeral: number].
    aFormat = 'I'
    	ifTrue:
    		[^(self romanNumeral: number) asUppercase].
    aFormat = '1'
    	ifTrue:
    		[^number printString].
    self error: 'Unrecognized format'!

radix: number base: b
    | out n |
    n := number - 1.
    n < b ifTrue: [^Array with: n].
    out := OrderedCollection new.
    n := number.
    [n < b]
    	whileFalse:
    		[out addFirst: n\\b.
    		n := n//b].
    out addFirst: n - 1.
    ^out!

romanNumeral: number
    | n cycle output idx letters digit |
    n := number.
    cycle := #('ivx' 'xlc' 'cdm').
    output := OrderedCollection new.
    idx := 0.
    [n = 0]
    	whileFalse:
    		[letters := cycle at: (idx := idx + 1).
    		digit := n\\10.
    		digit := #(#() #(1) #(1 1) #(1 1 1) #(1 2) #(2) #(2 1) #(2 1 1) #(2 1 1 1) #(1 3))
    				at: digit + 1.
    		output addAllFirst: (digit collect: [:i | letters at: i]).
    		n := n//10].
    ^String withAll: output!

tokenizeFormat: aString
    | str isFormat tok tokens t resultFormat |
    str := aString readStream.
    tokens := OrderedCollection new.
    isFormat := [:ch | ch isDigit or: [ch isLetter]].
    [str atEnd] whileFalse:
    	[tok := ''.
    	(isFormat value: str peek)
    		ifTrue: [[str atEnd or: [(isFormat value: str peek) not]]
    			whileFalse: [tok := tok copyWith: str next]]
    		ifFalse: [[str atEnd or: [isFormat value: str peek]]
    			whileFalse: [tok := tok copyWith: str next]].
    	tokens add: tok].
    (tokens isEmpty or: [isFormat value: tokens first first])
    	ifFalse: [prefix := tokens removeFirst].
    (tokens isEmpty or: [isFormat value: tokens last first])
    	ifFalse: [postfix := tokens removeLast].
    tokens size = 0
    	ifTrue: [resultFormat := nil]
    	ifFalse: [tokens size = 1
    		ifTrue:
    			[resultFormat := NumberFormat new format: tokens first; separator: '.'.
    			resultFormat nextLink: resultFormat]
    		ifFalse:
    			[t := (1 to: tokens size by: 2) collect:
    				[:i | NumberFormat new
    						format: (tokens at: i);
    						separator: (tokens at: (i + 1 min: tokens size - 1))].
    			1 to: t size do: [:i | (t at: i) nextLink: (t at: (i + 1 min: t size))].
    			resultFormat := t first]].
    ^resultFormat! !

!CountingCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    format := self readAttribute: 'format' default: ['1'].
    lang := self readAttribute: 'xml:lang' default: [nil].
    letterValue := self readAttribute: 'letter-value' default: [nil].
    digitGroupSep := self readAttribute: 'digit-group-sep' default: [nil].
    digitsPerGroup := self readInteger: 'n-digits-per-group' default: [3].
    sequenceSrc := self readAttribute: 'sequence-src' default: [nil].! !

!CountingCommand methodsFor: 'processing'!

format: countList for: aNodeContext
    | str fmt |
    str := String new writeStream.
    fmt := self processAttributeValue: self format for: aNodeContext.
    fmt := self tokenizeFormat: fmt.
    prefix == nil ifFalse: [str nextPutAll: prefix].
    1 to: countList size do: [:i |
    	str nextPutAll: (self format: (countList at: i) by: fmt format).
    	i = countList size ifFalse: [str nextPutAll: fmt separator].
    	fmt := fmt nextLink].
    postfix == nil ifFalse: [str nextPutAll: postfix].
    ^str contents! !

!CountersCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    super testPatternInitialized.
    name := self readAttribute: 'name'.
    userData := true.! !

!CountersCommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name! !

!CountersCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | list |
    list := OrderedCollection new.
    aProxy counterValuesNamed: self name into: list.
    aProxy add: (Text new text: (self format: list for: aNodeContext))! !

!CountersCommand class methodsFor: 'accessing'!

tag
    ^'counters'! !

!ParamDefinition methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    aDB addVariable: self! !

!ParamDefinition methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self shouldNotImplement!

process: aNodeContext into: aProxy takeArgumentsFrom: arguments
    | val |
    val := arguments at: self name ifAbsent: [].
    val == nil
    	ifTrue: [val := self valueAsVariableIn: aNodeContext].
    aNodeContext variables at: self name put: val.! !

!ParamDefinition methodsFor: 'accessing'!

expression
    self testPatternInitialized.
    ^expression!

name
    self testPatternInitialized.
    ^name!

purgeUnimportant
    ^self! !

!ParamDefinition methodsFor: 'initialize'!

normalize
    super normalize.
    self parent defineParameter: self!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readAttribute: 'name'.
    expression := self readSelectPattern: 'select' default: [].
    (expression notNil and: [self children isEmpty not])
    	ifTrue: [self error: 'A parameter cannot have both content and a select attribute'].! !

!ParamDefinition methodsFor: 'testing'!

isStylesheetEntry
    ^true! !

!ParamDefinition class methodsFor: 'accessing'!

tag
    ^'param'! !

!ChooseWhenCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    testPattern := self readSelectPattern: 'test'! !

!ChooseWhenCommand methodsFor: 'accessing'!

testPattern
    self testPatternInitialized.
    ^testPattern! !

!ChooseWhenCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self shouldNotImplement! !

!ChooseWhenCommand class methodsFor: 'accessing'!

tag
    ^'when'! !

!WithParamCommand methodsFor: 'accessing'!

expression
    self testPatternInitialized.
    ^expression!

name
    self testPatternInitialized.
    ^name! !

!WithParamCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readAttribute: 'name'.
    expression := self readSelectPattern: 'select' default: [].
    (expression notNil and: [self children isEmpty not])
    	ifTrue: [self error: 'A parameter cannot have both content and a select attribute'].! !

!WithParamCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self shouldNotImplement!

process: aNodeContext intoArgs: aDictionary
    | val |
    val := self valueAsVariableIn: aNodeContext.
    aDictionary at: self name put: val.! !

!WithParamCommand class methodsFor: 'accessing'!

tag
    ^'with-param'! !

!Import methodsFor: 'accessing'!

href
    self testPatternInitialized.
    ^href!

purgeUnimportant
    | idx |
    elements == nil ifFalse: [self error: 'Imports should not have contents.'].
    (self parent isKindOf: RuleSet)
    	ifFalse: [self error: self tag asString, ' can only be used at the top level'].
    idx := self parent children indexOf: self.
    (idx = 1 or: [(self parent children at: idx - 1) class == self class])
    	ifFalse: [self error: 'All imports must come first in the stylesheet'].! !

!Import methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    href := self readAttribute: 'href'.! !

!Import methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    | uri |
    uri := aDB uriStack last resolveRelativePath: self href.
    aDB uriStack addLast: uri.
    aDB readStream: uri resource topLevel: false.
    aDB uriStack removeLast.
    aDB raiseImportance! !

!Import class methodsFor: 'accessing'!

tag
    ^'import'! !

!Template methodsFor: 'accessing'!

importanceHolder: dummy!
purgeUnimportant
    ^self! !

!Template methodsFor: 'testing'!

importance
    "Really only needs to be > 0 to beat the builtin rule that matches
    against the root of the document, but we throw in a bit of paranoia."

    ^1000!

match: aNodeContext
    ^aNodeContext node isDocument!

modeIsLike: aMode
    ^aMode isNil! !

!Template methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | oc list |
    oc := aProxy childProxy.
    oc attributes: (self processAttributes: self attributes for: aNodeContext).
    list := self xslElements.
    1 to: list size do: [:i || elm |
    	elm := list at: i.
    	elm process: aNodeContext into: oc].
    aProxy addNode: (Element tag: tag attributes: oc attributes elements: oc children)!

process: aNodeContext into: aProxy arguments: arguments
    "The arguments are ignored because, if I am being used
    as a top-level stylesheet, there's no place to declare the
    top-level <xsl:param> definitions."

    self process: aNodeContext into: aProxy!

processAttributes: attList for: aNodeContext
    | newList substitution newAtt |
    newList := OrderedCollection new.
    attList do: [:att |
    	(att tag namespace = XSL_URI)
    		ifTrue:
    			[newAtt := self processXSLAttribute: att for: aNodeContext.
    			newAtt == nil ifFalse: [newList add: newAtt]]].
    attList do: [:att |
    	(att tag namespace = XSL_URI)
    		ifFalse:
    			[substitution := self processAttributeValue: att value for: aNodeContext.
    			newAtt := Attribute name: att key value: substitution.
    			newList add: newAtt]].
    ^newList isEmpty
    	ifTrue: [nil]
    	ifFalse: [newList asArray]!

processXSLAttribute: att for: aNodeContext
    att tag type = 'version'
    	ifTrue:
    		[" aNodeContext db version: att value. "
    		^nil].
    att tag type = 'use-attribute-set'
    	ifTrue:
    		[^self notYetImplementedError].
    ^self notYetImplementedError! !

!Template methodsFor: 'loading'!

topLevelAddToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self tag namespace = XSL_URI
    	ifTrue: [self error: ('"%1" not recognized as an XSL command'
    		% { self tag asString })].
    aDB addRule: self! !

!VariableDefinition methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    aDB addVariable: self! !

!VariableDefinition methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | val |
    val := self valueAsVariableIn: aNodeContext.
    aNodeContext variables at: name put: val! !

!VariableDefinition methodsFor: 'accessing'!

expression
    self testPatternInitialized.
    ^expression!

name
    self testPatternInitialized.
    ^name!

purgeUnimportant
    ^self! !

!VariableDefinition methodsFor: 'initialize'!

normalize
    super normalize.
    self parent defineVariable: self!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readAttribute: 'name'.
    expression := self readSelectPattern: 'select' default: [].
    (expression notNil and: [self children isEmpty not])
    	ifTrue: [self error: 'A parameter cannot have both content and a select attribute'].! !

!VariableDefinition methodsFor: 'testing'!

isStylesheetEntry
    ^true! !

!VariableDefinition class methodsFor: 'accessing'!

tag
    ^'variable'! !

!CounterIncrementCommand methodsFor: 'accessing'!

amount
    self testPatternInitialized.
    ^amount!

name
    self testPatternInitialized.
    ^name! !

!CounterIncrementCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    super testPatternInitialized.
    name := self readAttribute: 'name'.
    amount := self readInteger: 'amount' default: [1].
    userData := true.! !

!CounterIncrementCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | c |
    c := aProxy counterNamed: self name.
    c == nil
    	ifTrue: [c := aProxy root resetCounter: self name].
    c value: c value + 1.! !

!CounterIncrementCommand class methodsFor: 'accessing'!

tag
    ^'counter-increment'! !

!Rank methodsFor: 'comparing'!

rankAgainst: aRank
    "Assume two Ranks, of sizes M and N, where M >= N.
    If they have the same elements in the first N elements, the
    	shorter Rank has higher priority.
    If there is a difference in the first N elements, assume
    	that the first difference occurs at slot S. The Rank
    	whose value at S is greater has higher priority."

    | min r ranks |
    ranks := #(#higher #same #lower).
    min := self size min: aRank size.
    1 to: min do: [:i |
    	r := ((aRank at: i) - (self at: i)) sign.
    	r = 0 ifFalse: [^ranks at: r + 2]].
    ^ranks at: (self size - aRank size) sign + 2! !

!NumberFormat methodsFor: 'accessing'!

format
    ^format!

format: s
    format := s!

separator
    ^separator!

separator: s
    separator := s! !

!NumberFormat methodsFor: 'printing'!

printOn: aStream
    format == nil ifFalse: [aStream nextPutAll: format].
    separator == nil ifFalse: [aStream nextPutAll: separator].
    (nextLink == nil or: [nextLink == self])
    	ifFalse: [nextLink printOn: aStream].! !

!TextTemplate methodsFor: 'initialize'!

normalize
    ^self!

stripSpace
    ^self! !

!TextTemplate methodsFor: 'testing'!

isStylesheetEntry
    | s |
    s := text readStream.
    s skipSeparators.
    s atEnd ifFalse: [self error: 'Text contains something other than whitespace.'].
    ^false! !

!TextTemplate methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self text isEmpty
    	ifFalse: [aProxy addNode: (Text new text: self text)]! !

!NumberCommand methodsFor: 'accessing'!

countFor: aNode
    aNode isElement ifFalse: [self halt: 'Counting things other than elements is not supported yet'].
    self testPatternInitialized.
    ^count == nil
    	ifTrue: [XPathChildNode new axisName: 'child'; baseTest: (XPathTaggedNodeTest new namespace: aNode tag namespace; type: aNode tag type)]
    	ifFalse: [count]!

from
    self testPatternInitialized.
    ^from!

level
    self testPatternInitialized.
    ^level! !

!NumberCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    super testPatternInitialized.
    level := (self readAttribute: 'level' default: [#single]) asSymbol.
    count := self readMatchPattern: 'count' default: [nil].
    from := self readMatchPattern: 'from' default: [nil].
    userData := true.! !

!NumberCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self level == #single
    	ifTrue: [^self processSingle: aNodeContext into: aProxy].
    self level == #multi
    	ifTrue: [^self processMulti: aNodeContext into: aProxy].
    self level == #any
    	ifTrue: [^self processAny: aNodeContext into: aProxy].
    ^self error: 'Unsupported numbering mode'!

processAny: aNodeContext into: aProxy
    | n countP |
    n := 0.
    countP := self countFor: aNodeContext node.
    NodeIterator new
    	node: aNodeContext node;
    	reverseDo: [:nd | (countP match: (aNodeContext copy add: nd; index: 1)) ifTrue: [n := n + 1]]
    		until: [:nd | self from notNil and: [self from match: (aNodeContext copy add: nd; index: 1)]].
    aProxy addNode: (Text new text: (self format: (Array with: n) for: aNodeContext))!

processMulti: aNodeContext into: aProxy
    | allNodes n counts countP sibSelect cnt sibs |
    countP := self countFor: aNodeContext node.
    allNodes := aNodeContext copy.
    n := aNodeContext node.
    [n == nil or: [self from notNil and: [self from match: n]]] whileFalse:
    	[allNodes add: n.
    	n := n parent].
    allNodes := allNodes selectMatch: countP.
    allNodes documentOrder; index: 1.
    sibSelect := XPathParser parse: '../node()' as: #expression.
    counts := OrderedCollection new.
    allNodes reset.
    [allNodes atEnd] whileFalse:
    	[allNodes next.
    	cnt := 1.
    	sibs := sibSelect xpathValueIn: allNodes.
    	sibs reset; next.
    	[sibs node == allNodes node]
    		whileFalse:
    			[(countP match: sibs) ifTrue: [cnt := cnt + 1].
    			sibs next].
    	counts add: cnt].
    aProxy addNode: (Text new text: (self format: counts asArray for: aNodeContext))!

processSingle: aNodeContext into: aProxy
    | allNodes n cnt countP sibSelect sibs |
    countP := self countFor: aNodeContext node.
    allNodes := aNodeContext copy.
    n := aNodeContext node.
    [n == nil or: [self from notNil and: [self from match: n]]] whileFalse:
    	[allNodes add: n.
    	n := n parent].
    allNodes := allNodes selectMatch: countP.
    allNodes size = 0 ifTrue: [^self].
    allNodes inverseDocumentOrder; index: 1.
    sibSelect := XPathParser parse: '../node()' as: #expression.
    sibs := sibSelect xpathValueIn: allNodes.
    sibs reset; next.
    cnt := 1.
    [sibs node == allNodes node]
    	whileFalse:
    		[(countP match: sibs) ifTrue: [cnt := cnt + 1].
    		sibs next].
    aProxy addNode: (Text new text: (self format: (Array with: cnt) for: aNodeContext))! !

!NumberCommand class methodsFor: 'accessing'!

tag
    ^'number'! !

!OutputCommand methodsFor: 'accessing'!

method
    method == nil
    	ifTrue: [method := self readAttribute: 'method' default: [#auto]].
    ^method!

purgeUnimportant
    elements == nil ifFalse: [self error: 'Output declarations should not have contents']! !

!OutputCommand methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    aDB setOutput: self! !

!OutputCommand class methodsFor: 'accessing'!

tag
    ^'output'! !

!CopyCommand methodsFor: 'accessing'!

useAttrs
    self testPatternInitialized.
    ^useAttrs! !

!CopyCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    aNodeContext node isAttribute
    	ifTrue:
    		[self useAttrs isEmpty ifFalse: [self error: '<xsl:copy> is attempting to add attributes to an Attribute'].
    		^self processAttribute: aNodeContext into: aProxy].
    aNodeContext node isElement
    	ifTrue: [^self processElement: aNodeContext into: aProxy].
    (aNodeContext node isComment or: [aNodeContext node isText])
    	ifTrue:
    		[self useAttrs isEmpty ifFalse: [self error: '<xsl:copy> is attempting to add attributes to a non-Element'].
    		^aProxy add: aNodeContext node copy].
    ^self error: 'Copying of this node type is not yet implemented'!

processAttribute: aNodeContext into: aProxy
    aProxy addAttribute: (Attribute new name: aNodeContext node tag value: aNodeContext node value)!

processElement: aNodeContext into: aProxy
    | oc list |
    oc := aProxy childProxy.
    self processAttributeSets: aNodeContext into: oc.
    list := self xslElements.
    1 to: list size do: [:i || elm |
    	elm := list at: i.
    	elm process: aNodeContext into: oc].
    aProxy addNode: (Element tag: aNodeContext node tag attributes: oc attributes elements: oc children)! !

!CopyCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    useAttrs := self readTagList: 'use-attribute-sets' default: [#()].! !

!CopyCommand class methodsFor: 'accessing'!

tag
    ^'copy'! !

!ValueOfCommand methodsFor: 'accessing'!

expression
    self testPatternInitialized.
    ^expression! !

!ValueOfCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    expression := self readSelectPattern: 'select'! !

!ValueOfCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | elm |
    elm := self expression xpathValueIn: aNodeContext.
    (elm == nil or: [(elm := elm xpathAsString) isEmpty])
    	ifFalse: [aProxy addNode: (Text new text: elm)]! !

!ValueOfCommand class methodsFor: 'accessing'!

tag
    ^'value-of'! !

!Rule methodsFor: 'accessing'!

defineParameter: aVariable
    | old |
    old := variables detect: [:var | var name = aVariable name] ifNone: [].
    (old == nil or: [old == aVariable])
    	ifFalse: [self error: 'The parameter "', aVariable name, '" is shadowing another variable in the same template'].
    old == nil ifTrue: [variables add: aVariable].!

defineVariable: aVariable
    | old |
    old := variables detect: [:var | var name = aVariable name] ifNone: [].
    (old == nil or: [old == aVariable])
    	ifFalse: [self error: 'The variable "', aVariable name, '" is shadowing another variable in the same template'].
    old == nil ifTrue: [variables add: aVariable].!

mode
    self testPatternInitialized.
    ^mode!

mode: aMode
    mode := aMode!

name
    self testPatternInitialized.
    ^name!

pattern
    self testPatternInitialized.
    ^pattern!

priority
    self testPatternInitialized.
    ^priority!

priority: aNumber
    priority := aNumber!

purgeUnimportant
    ^self! !

!Rule methodsFor: 'testing'!

isStylesheetEntry
    ^true!

match: aNodeContext
    ^self pattern notNil and: [self pattern match: aNodeContext]!

modeIsLike: aMode
    "We can use #any as the 'accept any mode', because
    normal modes are strings. If this is changed, the marker
    for 'any mode' would need to be changed."

    ^mode = aMode or: [mode == #any]! !

!Rule methodsFor: 'initialize'!

computeDefaultPriority: expr
    | list |
    ^expr class == XPathUnion
    	ifTrue:
    		[list := Set new.
    		expr arguments do: [:expr2 | list add: (self computeDefaultPriority: expr2)].
    		list size = 1
    			ifTrue: [list asArray first]
    			ifFalse: [#notKnown]]
    	ifFalse: [((expr class == XPathChildNode or: [expr class == XPathAttributeNode])
    				and: [expr child isTerminator and: [expr predicates isEmpty]])
    		ifTrue: [expr baseTest class == XPathTaggedNodeTest
    			ifTrue: [expr baseTest type == #*
    				ifTrue: [expr baseTest namespace == nil ifTrue: [-0.5d] ifFalse: [-0.25d]]
    				ifFalse: [0.0d]]
    			ifFalse: [('processing-instruction(*)' match: expr printString)
    				ifTrue: [self halt]
    				ifFalse: [-0.5d]]]
    		ifFalse: [0.5]]!

initialize
    super initialize.
    priority := 0.
    variables := OrderedCollection new.!

normalize
    super normalize.
    (self parent == nil or: [self parent isKindOf: RuleSet])
    	ifFalse: [self error: self tag asString, ' can only be used at the top level'].!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readAttribute: 'name' default: [nil].
    pattern := self readMatchPattern: 'match' default: [nil].
    priority := self readInteger: 'priority' default: [self computeDefaultPriority: self pattern].
    mode := self readAttribute: 'mode' default: [nil]! !

!Rule methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self pattern == nil ifFalse: [aDB addRule: self].
    self name == nil ifFalse: [aDB addNamedTemplate: self].
    (self pattern == nil and: [self name == nil])
    	ifTrue: [self error: 'Templates must have either a name or match attribute or both'].! !

!Rule methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self shouldNotImplement!

process: aNodeContext into: aProxy arguments: arguments
    | list |
    list := self xslElements.
    1 to: list size do: [:i || elm |
    	elm := list at: i.
    	elm process: aNodeContext into: aProxy takeArgumentsFrom: arguments]! !

!Rule class methodsFor: 'formatting'!

formatText: aNode
    | text tab a nbsp |
    a := Attribute new name: 'CLASS' value: 'body'.
    text := aNode characterData.
    nbsp := (Character codePoint: 160) asString.
    tab := nbsp, nbsp, nbsp, nbsp.
    text := text copyReplaceAll: 9 asCharacter asString with: tab.
    text := text substrings: Character nl.
    ^text collect: [:t |
    	t isEmpty
    		ifTrue: [Element tag: 'BR']
    		ifFalse:
    			[Element tag: 'P' attributes: (Array with: a copy)
    				elements: (Array with: (Text new text: t))]]! !

!Rule class methodsFor: 'accessing'!

tag
    ^'template'! !

!CounterResetCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    super testPatternInitialized.
    name := self readAttribute: 'name'.
    userData := true.! !

!CounterResetCommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name! !

!CounterResetCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    aProxy resetCounter: self name! !

!CounterResetCommand class methodsFor: 'accessing'!

tag
    ^'counter-reset'! !

!SAXHtmlWriter methodsFor: 'content handler'!

endElement: namespaceURI localName: localName qName: name
    namespaceURI isEmpty
    	ifFalse: [^super endElement: namespaceURI
    			localName: localName
    			qName: name].
    hasOpenTag
    	ifTrue: [(self htmlSpecialEmptyTags includes: name asLowercase)
    		ifTrue: [output nextPutAll: '>']
    		ifFalse: [output nextPutAll: '/>']]
    	ifFalse: [output nextPutAll: '</', name asLowercase, '>'].
    hasOpenTag := false.!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    namespaceURI isEmpty
    	ifFalse: [^super startElement: namespaceURI
    			localName: localName
    			qName: name
    			attributes: attributes].
    self closeOpenTag.
    output nextPutAll: '<'.
    output nextPutAll: name asLowercase.
    (self sort: attributes) do: [:att |
    	output space.
    	output nextPutAll: att tag asString asLowercase.
    	(self isBoolean: att in: name)
    		ifFalse:
    			[output nextPutAll: '="'.
    			1 to: att value size do: [:i || ch mapped |
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
    		atts add: (Attribute new
    			tag: (NodeTag new qualifier: '' ns: '' type: 'http-equiv');
    			value: 'Content-Type').
    		atts add: (Attribute new
    			tag: (NodeTag new qualifier: '' ns: '' type: 'content');
    			value: 'text/html; charset=utf-8').
    		atts := atts asArray.
    		self startElement: '' localName: 'meta' qName: 'meta' attributes: atts.
    		self endElement: '' localName: 'meta' qName: 'meta'].! !

!SAXHtmlWriter methodsFor: 'accessing'!

htmlSpecialEmptyTags
    htmlSpecialEmptyTags == nil
    	ifTrue: [htmlSpecialEmptyTags := #('area' 'base' 'basefont' 'br' 'col' 'frame' 'hr' 'img' 'input' 'isindex' 'link' 'meta' 'param')].
    ^htmlSpecialEmptyTags!

htmlSpecialEmptyTags: aList
    htmlSpecialEmptyTags := aList! !

!SAXHtmlWriter methodsFor: 'testing'!

isBoolean: attribute in: elementTag
    ^false! !

!ChooseCommand methodsFor: 'private'!

elements: aList
    | newList hasOtherwise |
    newList := aList select: [:i | i isContent and: [i isBlankText not]].
    hasOtherwise := false.
    newList do: [:elm |
    	elm class = ChooseOtherwiseCommand
    		ifTrue:
    			[hasOtherwise ifTrue: [self error: 'xsl:choose with multiple xsl:otherwise commands'].
    			hasOtherwise := true]
    		ifFalse: [elm class = ChooseWhenCommand
    			ifFalse: [self error: 'xsl:choose can only contain xsl:when and xsl:otherwise']]].
    super elements: newList! !

!ChooseCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | alt match list |
    alt := match := nil.
    elements do: [:elm |
    	elm class == ChooseOtherwiseCommand
    		ifTrue: [alt := elm]
    		ifFalse: [(match == nil and: [(elm testPattern xpathValueIn: aNodeContext) xpathAsBoolean])
    			ifTrue: [match := elm]]].
    match == nil ifTrue: [match := alt].
    match notNil
    	ifTrue:
    		[list := match xslElements.
    		1 to: list size do: [:i || elm |
    			elm := list at: i.
    			elm process: aNodeContext into: aProxy]]! !

!ChooseCommand class methodsFor: 'accessing'!

tag
    ^'choose'! !

!ChainedDictionary methodsFor: 'accessing'!

associationAt: anIndex ifAbsent: aBlock
    ^super associationAt: anIndex ifAbsent: [parent associationAt: anIndex ifAbsent: aBlock]!

at: anIndex ifAbsent: aBlock
    ^super at: anIndex ifAbsent: [parent at: anIndex ifAbsent: aBlock]!

clone
    ^self class new parent: parent!

parent
    ^parent!

parent: aParent
    aParent == nil ifTrue: [self halt].
    parent := aParent!

size
    | s |
    s := Set new.
    self keysAndValuesDo: [:k :v |
    	s add: k].
    ^s size! !

!ChainedDictionary methodsFor: 'dictionary enumerating'!

associationsDo: aBlock 
    "Evaluate aBlock for each of the receiver's key/value associations."

    self keysAndValuesDo: [:k :v |
    	aBlock value: k -> v]! !

!ChainedDictionary methodsFor: 'dictionary testing'!

includesKey: key 
    "Answer whether the receiver has a key equal to the argument, key."

    ^(super includesKey: key) or: [parent includesKey: key]! !

!ChainedDictionary methodsFor: 'enumerating'!

do: aBlock 
    "Evaluate aBlock with each of the receiver's elements as the 
    argument."

    self keysDo: [:k | aBlock value: (self at: k)]!

keysAndValuesDo: aBlock 
    "Evaluate aBlock with each of the receiver's key/value pairs as the 
    arguments."

    | keys |
    keys := Set new.
    super keysAndValuesDo: [:k :v | keys add: k].
    parent keysAndValuesDo: [:k :v | keys add: k].
    keys do: [:k |
    	aBlock value: k value: (self at: k)].! !

!ChainedDictionary methodsFor: 'private'!

changeCapacityTo: newCapacity
    | newSelf |
    newSelf := self copyEmpty: newCapacity.
    newSelf parent: parent.
    super associationsDo: [:each | newSelf noCheckAdd: each].
    self become: newSelf.! !

!IfCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    testPattern := self readSelectPattern: 'test'! !

!IfCommand methodsFor: 'accessing'!

testPattern
    self testPatternInitialized.
    ^testPattern! !

!IfCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | list |
    (self testPattern xpathValueIn: aNodeContext) xpathAsBoolean
    	ifTrue:
    		[list := self xslElements.
    		1 to: list size do: [:i || elm |
    			elm := list at: i.
    			elm process: aNodeContext into: aProxy]]! !

!IfCommand class methodsFor: 'accessing'!

tag
    ^'if'! !

!XSL_PI methodsFor: 'accessing'!

stripSpace
    ^self! !

!XSL_PI methodsFor: 'testing'!

isContent
    ^name = 'vwst_xsl'!

isStylesheetEntry
    ^name = 'vwst_xsl'! !

!XSL_PI methodsFor: 'processing'!

process: aNodeContext into: aProxy
    block == nil
    	ifTrue: [block := Behavior evaluate: text].
    (block class == BlockClosure and: [block numArgs = 1])
    	ifFalse: [self error: '"', text, '" is not a legal Smalltalk processing instruction'].
    aProxy addAll: (block value: aNodeContext)! !

!XSL_PI methodsFor: 'initialize'!

normalize
    ^self! !

!GeneralCountingProxy methodsFor: 'accessing'!

childProxy
    ^ElementProxy new nextLink: self; yourself!

counterNamed: nm
    | c |
    counters == nil
    	ifTrue: [c := nil]
    	ifFalse: [c := counters at: nm ifAbsent: []].
    ^c == nil
    	ifTrue: [nextLink == nil
    		ifTrue: [nil]
    		ifFalse: [nextLink counterNamed: nm]]
    	ifFalse: [c]!

counterValuesNamed: nm into: list
    | c |
    self nextLink == nil
    	ifFalse: [self nextLink counterValuesNamed: nm into: list].
    counters == nil
    	ifTrue: [c := nil]
    	ifFalse: [c := counters at: nm ifAbsent: []].
    c == nil
    	ifFalse: [list add: c value]!

countingProxy
    ^CountingProxy new nextLink: self; yourself!

resetCounter: nm
    counters == nil ifTrue: [counters := Dictionary new].
    counters at: nm put: 0 asValue.
    ^counters at: nm!

root
    | n |
    n := self.
    [n nextLink == nil]
    	whileFalse: [n := n nextLink].
    ^n! !

!ElementProxy methodsFor: 'building'!

addAttribute: attribute
    self attributes: (self attributes copyWith: attribute)!

addNode: element
    self children: (self children copyWith: element)! !

!ElementProxy methodsFor: 'accessing'!

attributes
    attributes == nil
    	ifTrue: [attributes := #()].
    ^attributes!

attributes: list
    attributes := list!

children
    contents == nil
    	ifTrue: [contents := #()].
    ^contents!

children: list
    contents := list! !

!ElementProxy methodsFor: 'coercing'!

xpathAsBoolean
    ^self xpathAsString xpathAsBoolean!

xpathAsNumber
    ^self xpathAsString xpathAsNumber!

xpathAsString
    | result |
    self children isEmpty ifTrue: [^''].
    self children size = 1 ifTrue: [^self children first xpathStringData].
    result := (String new: 40) writeStream.
    1 to: self children size do: [:i |
    	result nextPutAll: (self children at: i) xpathStringData].
    ^result contents! !

!ElementProxy methodsFor: 'enumerating'!

addToXPathHolder: anAssociation for: aNodeContext
    anAssociation value == nil
    	ifTrue: [^anAssociation value: self].
    anAssociation value xpathIsNodeSet
    	ifTrue: [^self error: 'An XPath expression is answering a combination of Nodes and non-Nodes'].
    self error: 'An XPath expression is answering more than one non-Node value'! !

!PICommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readTag: 'name'! !

!PICommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name! !

!PICommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | oc str |
    oc := aProxy childProxy.
    self xslElements do: [:elm |
    	elm process: aNodeContext into: oc].
    oc attributes isEmpty ifFalse: [self error: 'Comments do not support attributes'].
    str := (String new: 128) writeStream.
    oc children do: [:nd |
    	nd isText ifFalse: [self error: 'Comments can only contain text, not elements, pi''s, or other comments'].
    	str nextPutAll: nd characterData].
    str := str contents.
    str := str copyReplaceAll: '?>' with: '? >'.
    aProxy addNode: (PI new name: self name text: str)! !

!PICommand class methodsFor: 'accessing'!

tag
    ^'pi'! !

!CounterCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    super testPatternInitialized.
    name := self readAttribute: 'name'.
    userData := true.! !

!CounterCommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name! !

!CounterCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | c |
    c := aProxy counterNamed: self name.
    c == nil
    	ifFalse:
    		[aProxy add: (Text new text: (self format: (Array with: c value) for: aNodeContext))].! !

!CounterCommand class methodsFor: 'accessing'!

tag
    ^'counter'! !

!ApplyTemplatesCommand methodsFor: 'accessing'!

addSortBlock: aSortCommand
    sortList == nil ifTrue: [sortList := #()].
    sortList := sortList copyWith: aSortCommand!

mode
    self testPatternInitialized.
    ^mode!

selectPattern
    self testPatternInitialized.
    ^selectPattern!

sortList
    ^sortList! !

!ApplyTemplatesCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    selectPattern := self readSelectPattern: 'select' default: [nil].
    mode := self readAttribute: 'mode' default: [nil]! !

!ApplyTemplatesCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    | list rule arguments argList listCopy |
    self selectPattern == nil
    	ifTrue: [list := self xslNodesFrom: aNodeContext]
    	ifFalse: [list := self selectAll: aNodeContext withPattern: self selectPattern].
    self sortList == nil
    	ifTrue: [list documentOrder; ensureSorted]
    	ifFalse:
    		[listCopy := list shallowCopy.
    		list sort: [:n1 :n2 | self collate: n1 to: n2 within: listCopy]].
    arguments := Dictionary new.
    argList := self xslElements.
    1 to: argList size do: [:i |
    	(argList at: i) process: aNodeContext intoArgs: arguments].
    list reset.
    [list atEnd]
    	whileFalse:
    		[list variables: list variables clone.
    		rule := list db ruleMatching: list next mode: self mode.
    		rule == nil ifFalse: [rule process: list into: aProxy arguments: arguments]]! !

!ApplyTemplatesCommand class methodsFor: 'accessing'!

tag
    ^'apply-templates'! !

!RuleSet methodsFor: 'accessing'!

defineParameter: aVariable
    ^self!

defineVariable: aVariable
    ^self!

purgeUnimportant
    elements := self children select: [:i | i isElement and: [i isStylesheetEntry]].
    elements do: [:i | i purgeUnimportant]! !

!RuleSet methodsFor: 'loading'!

addToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self children do:
    	[:elm | elm addToRuleDB: aDB].!

topLevelAddToRuleDB: aDB
    "This is only understood by a small subset of commands."

    self children do:
    	[:elm | elm addToRuleDB: aDB].! !

!RuleSet class methodsFor: 'accessing'!

tag
    ^'stylesheet'! !

!NodeIterator methodsFor: 'enumeration'!

reverseDo: aBlock until: testBlock
    | t |
    [testBlock value: current]
    	whileFalse:
    		[aBlock value: current.
    		stack isEmpty ifTrue: [^self].
    		[stack last value = 1
    			ifTrue: [current := stack removeLast key]
    			ifFalse:
    				[t := stack last.
    				t value: t value - 1.
    				current := t key children at: t value.
    				[current isElement not or: [current children size = 0]]
    					whileFalse:
    						[stack add: current->current children size.
    						current := current children last]].
    		current isContent and: [current isText not]] whileFalse]! !

!NodeIterator methodsFor: 'accessing'!

node: aNode
    | nd |
    nd := current := aNode.
    stack := OrderedCollection new.
    [nd parent == nil] whileFalse:
    	[stack addFirst: nd parent -> (nd parent children indexOf: nd).
    	nd := nd parent]! !

!AttributeCommand methodsFor: 'testing'!

generatesAttributes
    ^true! !

!AttributeCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    name := self readTag: 'name'! !

!AttributeCommand methodsFor: 'accessing'!

name
    self testPatternInitialized.
    ^name! !

!AttributeCommand methodsFor: 'processing'!

generateFrom: aNode into: aProxy
    | oc computedValue nm |
    oc := aProxy childProxy.
    self xslElements do: [:elm |
    	elm process: aNode into: oc].
    oc attributes isEmpty ifFalse: [self error: 'Attributes cannot have attributes'].
    computedValue := (String new: 32) writeStream.
    oc children do: [:elm |
    	elm isText ifFalse: [self error: 'Attribute values can only contain text data'].
    	computedValue nextPutAll: elm characterData].
    nm := self processAttributeValue: self name for: aNode.
    nm := self resolveComputedTag: nm.
    ^Attribute new name: nm value: computedValue contents!

process: aNode into: aProxy
    | oc computedValue nm |
    aProxy children size = 0
    	ifFalse: [self error: 'Attributes must all be added before content'].
    oc := aProxy childProxy.
    self xslElements do: [:elm |
    	elm process: aNode into: oc].
    oc attributes isEmpty ifFalse: [self error: 'Attributes cannot have attributes'].
    computedValue := (String new: 32) writeStream.
    oc children do: [:elm |
    	elm isText ifFalse: [self error: 'Attribute values can only contain text data'].
    	computedValue nextPutAll: elm characterData].
    nm := self processAttributeValue: self name for: aNode.
    nm := self resolveComputedTag: nm.
    aProxy addAttribute: (Attribute new name: nm value: computedValue contents)! !

!AttributeCommand class methodsFor: 'accessing'!

tag
    ^'attribute'! !

!TextCommand methodsFor: 'testing'!

shouldStrip
    ^false! !

!TextCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    (self readAttribute: 'disable-output-escaping' default: ['no']) = 'yes'
    	ifTrue: [aProxy addNode: (DenormalizedText new text: self characterData)]
    	ifFalse: [aProxy addNode: (Text new text: self characterData)]! !

!TextCommand class methodsFor: 'accessing'!

tag
    ^'text'! !

!SAXTextWriter methodsFor: 'content handler'!

characters: aString from: start to: stop
    output next: stop + 1 - start putAll: aString startingAt: start!

endElement: namespaceURI localName: localName qName: name
    ^self!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    ^self! !

!CountingProxy methodsFor: 'building'!

add: element
    nextLink add: element!

addAttribute: attribute
    nextLink addAttribute: attribute! !

!CopyOfCommand methodsFor: 'processing'!

copyNode: n to: aContainer
    | new |
    n isDocument
    	ifTrue: [^self copyNode: n root to: aContainer].
    n isAttribute
    	ifTrue: [^aContainer addAttribute: n copy].
    n isElement
    	ifFalse: [^aContainer addNode: n copy].
    new := n class tag: n tag attributes: (n attributes collect: [:a | a copy]) elements: nil.
    n children do: [:c | self copyNode: c to: new].
    aContainer addNode: new.!

copyNodes: sortedNodes into: aProxy
    sortedNodes do: [:n | self copyNode: n to: aProxy].!

process: aNodeContext into: aProxy
    | elm |
    elm := self expression xpathValueIn: aNodeContext.
    elm xpathIsNodeSet
    	ifTrue: [self copyNodes: elm sortedNodes into: aProxy]
    	ifFalse: [(elm isKindOf: ElementProxy)
    		ifTrue: [self copyNodes: elm children into: aProxy]
    		ifFalse: [aProxy add: (Text new text: elm xpathAsString value)]]! !

!CopyOfCommand methodsFor: 'accessing'!

expression
    self testPatternInitialized.
    ^expression! !

!CopyOfCommand methodsFor: 'initialize'!

testPatternInitialized
    userData ifTrue: [^self].
    userData := true.
    expression := self readSelectPattern: 'select'! !

!CopyOfCommand class methodsFor: 'accessing'!

tag
    ^'copy-of'! !

!ChooseOtherwiseCommand methodsFor: 'processing'!

process: aNodeContext into: aProxy
    self shouldNotImplement! !

!ChooseOtherwiseCommand class methodsFor: 'accessing'!

tag
    ^'otherwise'! !

XSL XSLCommand initialize!

Namespace current: Smalltalk!
