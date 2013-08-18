"======================================================================
|
|   ParseTreeRewriter tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2007,2013 Free Software Foundation, Inc.
| Written by Stephen Compall.
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



Namespace current: STInST.Tests [

TestCase subclass: TestStandardRewrites [
    
    <comment: 'I test the ParseTreeRewriter with string rewrites provided directly
by PTR''s methods.

This is a series of unit tests written with SUnit to check the
functionality of STInST.ParseTreeRewriter and its
helper classes.  It was written based on the original functionality,
so that one could perform a radical rewrite and ensure that its
behavior stayed the same, at least as much as I care it to stay so.'>
    <category: 'Refactory-Tests'>

    testExpressions [
	"Basic testing of proper descent"

	<category: 'testing'>
	self 
	    rewrite: '(self foo: (one isNil ifTrue: [self uhOh. two]
					 ifFalse: [one]))
		       isNil ifTrue: [three isNil ifFalse: [three]
						  ifTrue: [four]]
			     ifFalse: [self foo: (one isNil ifTrue: [self uhOh. two] ifFalse: [one])]'
	    from: '``@receiver isNil ifTrue: [|`@otherVars| ``@.other]
				  ifFalse: [``@receiver]'
	    to: '``@receiver ifNil: [|`@otherVars| ``@.other]'
	    shouldBe: '(self foo: (one ifNil: [self uhOh. two]))
			ifNil: [three isNil ifFalse: [three]
					    ifTrue: [four]]'.
	"descent and simple replacement behavior with cascades"
	self 
	    rewrite: '| temp |
		   temp := self one at: two put: three.
		   (self qqq at: temp put: dict)
		       at: four put: (five at: half put: quarter);
		       at: (six at: q put: r) put: 7;
		       w: (1 at: 2 put: 3).
		   ^42'
	    from: '`@receiver at: ``@key put: `@value'
	    to: '`@receiver set: ``@key to: `@value'
	    shouldBe: '| temp |
		    temp := self one set: two to: three.
		    (self qqq at: temp put: dict)
			set: four to: (five at: half put: quarter);
			set: (six set: q to: r) to: 7;
			w: (1 set: 2 to: 3).
		    ^42'
	"``@receiver it was, until I found that a cascade corner
	 described below causes the w: send below to have the wrong
	 receiver.  After all, it just doesn't make sense to descend
	 to the receiver for some cascade messages but not others!"
    ]

    testCascadeCornerCases [
	"Issue non-messages-are-found: If replacement isn't a cascade or
	 message, it drops.  Oddly, PTR didn't count this as a 'not
	 found'; it doesn't descend into arguments of the original node in
	 this case, and, as a result, it won't descend to the receiver.  This
	 behavior was changed, the original implementation needed this
	 shouldBe: content:
	 
	 obj.
	 (stream display: z) display: (stream display: x);
	 display: y; nextPut: $q"

	<category: 'testing'>
	self 
	    rewrite: 'stream display: obj.
		   (stream display: z) display: (stream display: x);
		       display: y; nextPut: $q'
	    from: '``@receiver display: ``@object'
	    to: '``@object'
	    shouldBe: 'obj.
		    z display: x;
			display: y; nextPut: $q'.

	"Cascades within cascades are flattened."
	self 
	    rewrite: 'stream nextPut: $r; display: (what display: qqq); tab'
	    from: '``@recv display: ``@obj'
	    to: '``@recv display: ``@obj; nl'
	    shouldBe: 'stream nextPut: $r;
			display: (what display: qqq; nl);
			nl; tab'.

	"Issue rsic-doesnt-copy: lookForMoreMatchesInContext: doesn't copy
	 its values.  As a result, replacement in successful replacements
	 later rejected by acceptCascadeNode: (after
	 lookForMoreMatchesInContext: is already sent, after all) depends
	 on where in the subtree a match happened.  This is why selective
	 recursion into successful matches before giving outer contexts
	 the opportunity to reject them isn't so great.  It can be 'fixed'
	 by #copy-ing each value in the context before descending into it.
	 I would prefer removing that 'feature' altogether, and my own
	 'trampoline' rewriter does just this.
	 
	 This replacement test depends on the non-message rejection oddity
	 described above, though fixing that won't entirely fix this
	 issue.  If that issue is not, this test will need this shouldBe:
	 qqq display: (qqq display: sss);
	 display: [[sss]]'"
	self 
	    rewrite: 'qqq display: (qqq display: sss);
		       display: [qqq display: sss]'
	    from: '``@recv display: ``@obj'
	    to: '[``@obj]'
	    shouldBe: 'qqq display: [sss];
			display: [[sss]]'.
	
	[| rsicCopiesPRewriter sourceExp |
	rsicCopiesPRewriter := (self rewriterClass new)
		    replace: '``@recv display: ``@obj' with: '[``@obj]';
		    replace: '`@recv value' with: '`@recv';
		    yourself.
	sourceExp := RBParser 
		    parseExpression: 'qqq display: (qqq display: sss value value);
	      display: [qqq display: sss value value]'.
	self deny: (self 
		    rewriting: sourceExp
		    with: rsicCopiesPRewriter
		    yields: 'qqq display: (qqq display: sss value value);
			      display: [[sss value]]')
	    description: 'neither non-messages-are-found nor rsic-doesnt-copy fixed'.
	self deny: (self 
		    rewriting: sourceExp
		    with: rsicCopiesPRewriter
		    yields: 'qqq display: [sss value];
			    display: [[sss]]')
	    description: 'non-messages-are-found fixed, but not rsic-doesnt-copy'.
	self assert: (self 
		    rewriting: sourceExp
		    with: rsicCopiesPRewriter
		    yields: 'qqq display: [sss value];
			    display: [[sss value]]')
	    description: 'both non-messages-are-found and rsic-doesnt-copy fixed'] 
		value.

	"Unmatched messages in a cascade get their arguments rewritten,
	 but not the receiver, provided that some other message in the
	 cascade was rewritten.  This can lead to unreal trees if that
	 message had a recurseInto receiver."
	self 
	    assert: ((RBCascadeNode 
		    messages: (RBParser parseExpression: '(1 b) b. (1 a) c') statements) 
			match: (self rewriterClass 
				replace: '``@recv a'
				with: '``@recv b'
				in: (RBParser parseExpression: '(1 a) a; c'))
			inContext: RBSmallDictionary new)
	    description: 'Don''t rewrite cascade receivers unless no submessages matched'
    ]

    testMultiRewrite [
	<category: 'testing'>
	| rewriter origTree match1 match2 |
	match1 := RBParser parseExpression: 'x value'.
	match2 := RBParser parseExpression: 'x'.
	origTree := RBParser parseExpression: 'x value value'.
	#(#('`' '') #('' '`')) do: 
		[:prefixes | 
		| prefix1 prefix2 rewriter |
		prefix1 := prefixes at: 1.
		prefix2 := prefixes at: 2.
		rewriter := ParseTreeRewriter new.
		rewriter
		    replace: prefix1 , '`@x value' with: prefix1 , '`@x';
		    replace: prefix2 , '`@x value' with: prefix2 , '`@x'.
		rewriter executeTree: origTree copy.
		self assert: (
			{match1.
			match2} 
				contains: [:matchTree | matchTree match: rewriter tree inContext: RBSmallDictionary new])
		    description: 'Rewrite one or the other']
    ]

    rewriterClass [
	<category: 'rewriting'>
	^ParseTreeRewriter
    ]

    rewriting: codeTree with: rewriter yields: newCodeString [
	"Answer whether rewriting codeTree (untouched) with rewriter
	 yields newCodeString."

	<category: 'rewriting'>
	^(RBParser parseExpression: newCodeString) match: (rewriter
		    executeTree: codeTree copy;
		    tree)
	    inContext: RBSmallDictionary new
    ]

    rewrite: codeString from: pattern to: replacement shouldBe: newCodeString [
	"Assert that replacing pattern with replacement in codeString
	 yields newCodeString."

	<category: 'rewriting'>
	^self assert: ((RBParser parseRewriteExpression: newCodeString) 
		    match: (self rewriterClass 
			    replace: pattern
			    with: replacement
			    in: (RBParser parseExpression: codeString))
		    inContext: Dictionary new)
	    description: ((WriteStream on: (String new: 50))
		    display: codeString;
		    nl;
		    nextPutAll: '    ==| (';
		    print: pattern;
		    nextPutAll: ' => ';
		    print: replacement;
		    nextPut: $);
		    nl;
		    nextPutAll: '    ==> ';
		    display: newCodeString;
		    contents)
    ]
]

TestCase subclass: TestFormat [
    <comment: 'I test aspects of the RBFormatter class.'>

    testNumberLiteralRewrite [
	| inp res |
	inp := RBParser parseExpression: '2r01'.
	self assert: inp value = 1.

	res := RBFormatter new formatAll: (Array with: inp).
	self assert: res = '2r01'.
    ]

    testNumberLiteralHexRewrite [
	| inp res |
	inp := RBParser parseExpression: '16r01 '.
	self assert: inp value = 1.

	res := RBFormatter new formatAll: (Array with: inp).
	self assert: res = '16r01'.
    ]

    testArrayRewrite [
	| inp res |
	inp := RBParser parseExpression: '#(16r01 2r01 16rFF )'.
	self assert: inp value = (Array with: 1 with: 1 with: 255).

	res := RBFormatter new formatAll: (Array with: inp).
	self assert: res = '#(16r01 2r01 16rFF)'.
    ]

    testParanthesis [
        | inp |
        inp := RBParser parseExpression: '(2r1)'.
        self assert: inp formattedCode = '2r1'.
    ]

    testNumberLiteralFloatRewrite [
        | inp |
        inp := RBParser parseExpression: '2q'.
        self
            assert: inp value = 2.0;
            assert: inp formattedCode = '2q'.

        inp := RBParser parseExpression: '2d'.
        self
            assert: inp value = 2.0;
            assert: inp formattedCode = '2d'.

        inp := RBParser parseExpression: '2e'.
        self
            assert: inp value = 2.0;
            assert: inp formattedCode = '2e'.

        inp := RBParser parseExpression: '2q-'.
        self
            assert: inp value = 2.0;
            assert: inp formattedCode = '2q-'.

        inp := RBParser parseExpression: '20q-1'.
        self
            assert: inp value = 2.0;
            assert: inp formattedCode = '20q-1'.
    ]

    testNegativeNumbers [
        | inp |
        inp := RBParser parseExpression: '-3'.
        self assert: inp value = -3.
        self assert: inp token source = '-3'.
        self assert: inp formattedCode = '-3'.
    ]

    testNumberExpressionParsing [
        | inp |
        inp := RBParser parseExpression: '2-2'.
        self
            assert: inp receiver value = 2;
            assert: inp selector = #-;
            assert: inp arguments first value = 2.
    ]
]

TestCase subclass: TestScanner [
    <comment: 'Test aspects of the RBScanner'>

    testScanner [
        | scanner num |
        scanner := RBScanner on: '3' readStream.
        num := scanner next.
        self assert: num value = 3.
    ]

    testScannerConcatStream [
        | scanner num |
        "This is different to >>#testScanner by using a different kind of stream with
        a different species."

        scanner := RBScanner on: (Kernel.ConcatenatedStream with: '3' readStream).
        num := scanner next.
        self assert: num value = 3.
    ]
]

TestCase subclass: TestParser [
    <comment: 'Test aspects of the RBParser'>

    testNumberParsing [

        | node |
        node := RBParser parseExpression: '3'.
        self assert: node value = 3.
        node := RBParser parseExpression: '-3'.
        self assert: node value = -3.
        node := RBParser parseExpression: '-16r3'.
        self assert: node value = -3.
        node := RBParser parseExpression: '16r-3'.
        self assert: node value = -3.
        node := RBParser parseExpression: '- 16r3'.
        self assert: node value = -3.
        node := RBParser parseExpression: '16r-3.23'.
        self assert: node value = 16r-3.23.
        node := RBParser parseExpression: '16r-3s23_0'.
        self assert: node value = 16r-3s23_0.
        node := RBParser parseExpression: '3_000_000'.
        self assert: node value = 3_000_000.
        node := RBParser parseExpression: '3_000_000e1233'.
        self assert: node value = 3_000_000e1233.
        node := RBParser parseExpression: '3_000_000d1233'.
        self assert: node value = 3_000_000d1233.
        node := RBParser parseExpression: '3_000_000q1233'.
        self assert: node value = 3_000_000q1233.
    ]

    testLiteralArrayParsing [
        | node |

        node := RBParser parseExpression: '#(-3 -2 -16r1)'.
        self assert: node value first = -3.
        self assert: node value second = -2.
        self assert: node value third = -1.

        node := RBParser parseExpression: '#(16r-1)'.
        self assert: node value first = -1.
    ]
]

TestCase subclass: TestRewrite [
    <comment: 'I test that rewriting a method for the OldSyntaxExport and
    SqueakExporter will pick up the new code.'>

    testNamespaceRewrite [
        | class tree rule rewriter res out|

        tree := RBParser parseRewriteExpression: 'Osmo.LogManager -> LogManager'.
        rule := RBStringReplaceRule
                    searchForTree: tree receiver
                    replaceWith: tree arguments first.
        rewriter := ParseTreeRewriter new
                        addRule: rule; yourself.

        class := (STClassLoader new
                    parseSmalltalkStream: 'Object subclass: TestData [
                        logManager [
                            ^Osmo.LogManager default
                        ]
                    ]' readStream with: GSTFileInParser) first.

        "Rewrite the method. This will modify the code on inside the class"
        res := rewriter executeTree: (class >> #logManager) node; tree.
        self assert: (class >> #logManager) node == res.

        "Now generate the code"
        out := WriteStream on: (String new).
        (SqueakSyntaxExporter on: class to: out)
            completeFileOut: false;
            fileOutSelectors: (Array with: #logManager) classSelectors: #().
        self assert: (out contents indexOfSubCollection: 'Osmo.LogManager') = 0.
    ]


    testOldSyntaxSymbolParsing [
        | res |
        res := (STClassLoader new
            parseSmalltalkStream:
'Object subclass: #PhexMatcher
	instanceVariableNames: ''value state''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''Phexample-Core''!

!PhexMatcher methodsFor: ''expecting'' stamp: ''JoeExample 10/27/2009 18:35''!
< expected
	^self expect: expected using: #<! !' readStream with: SqueakFileInParser) first.

	"Compare..."
	self assert: (res >> #<) methodSourceString = '< expected
	^self expect: expected using: #<'.

	(res >> #<) methodFormattedSourceString printNl.
    ]

    testOldSyntaxNamespaceRewrite [
        | class tree rule rewriter res out|

        tree := RBParser parseRewriteExpression: 'Osmo.LogManager -> LogManager'.
        rule := RBStringReplaceRule
                    searchForTree: tree receiver
                    replaceWith: tree arguments first.
        rewriter := ParseTreeRewriter new
                        addRule: rule; yourself.

        "Load the old code"
        class := (STClassLoader new
                    parseSmalltalkStream:
'SystemOrganization addCategory: #''osmo-logging-core''!
Object subclass: #LogManager
    instanceVariableNames: ''target filter areas''
    classVariableNames: ''Log''
    poolDictionaries: ''''
    category: ''osmo-logging-core''!

!LogManager methodsFor: ''as yet unclassified''!

logManager
    ^Osmo.LogManager default
! !' readStream with: SqueakFileInParser) first.


        "Rewrite the method. This will modify the code on inside the class"
        res := rewriter executeTree: (class >> #logManager) node; tree.
        self assert: (class >> #logManager) node == res.
        self assert: (class >> #logManager) isOldSyntax.

        "Now generate the code"
        out := WriteStream on: (String new).
        (SqueakSyntaxExporter on: class to: out)
            completeFileOut: false;
            fileOutSelectors: (Array with: #logManager) classSelectors: #().
        self assert: (out contents indexOfSubCollection: 'Osmo.LogManager') = 0.
    ]
]

]

