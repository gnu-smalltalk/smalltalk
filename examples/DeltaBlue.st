"======================================================================
|
|   The Richards Benchmark in Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1996 John Maloney and Mario Wolczko
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"

Object subclass: #Planner
	instanceVariableNames: 'currentMark '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-DeltaBlue'!

Planner class
	instanceVariableNames: 'currentPlanner '!

Planner comment:
'This benchmark is an implementation of the DeltaBlue Constraint Solver
described in `The DeltaBlue Algorithm: An Incremental Constraint
Hierarchy Solver'', by Bjorn N. Freeman-Benson and John Maloney,
Communications of the ACM, January 1990 (also as University of
Washington TR 89-08-06). 

To run the benchmark, execute the expression `Planner standardBenchmark''.'!

Object subclass: #Strength
	instanceVariableNames: 'symbolicValue arithmeticValue '
	classVariableNames: 'AbsoluteStrongest AbsoluteWeakest Required StrengthConstants StrengthTable '
	poolDictionaries: ''
	category: 'DB-DeltaBlue'!

Strength comment:
'Strengths are used to measure the relative importance of constraints. The
hierarchy of available strengths is determined by the class variable
StrengthTable (see my class initialization method). Because Strengths are
invariant, references to Strength instances are shared (i.e. all references to
"Strength of: #required" point to a single, shared instance). New strengths may
be inserted in the strength hierarchy without disrupting current constraints.

Instance variables:
	symbolicValue		symbolic strength name (e.g. #required) <Symbol>
	arithmeticValue		index of the constraint in the hierarchy, used for comparisons <Number>
'!

Object subclass: #AbstractConstraint
	instanceVariableNames: 'strength '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-DeltaBlue'!

AbstractConstraint comment:
'I am an abstract class representing a system-maintainable relationship (or
"constraint") between a set of variables. I supply a strength instance
variable; concrete subclasses provide a means of storing the constrained
variables and other information required to represent a constraint.

Instance variables:
	strength			the strength of this constraint <Strength>
'!
Object subclass: #Variable
	instanceVariableNames: 'value constraints determinedBy walkStrength stay mark '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-DeltaBlue'!

Variable comment:
'I represent a constrained variable. In addition to my value, I maintain the
structure of the constraint graph, the current dataflow graph, and various
parameters of interest to the DeltaBlue incremental constraint solver.

Instance variables:
	value			my value; changed by constraints, read by client <Object>
	constraints		normal constraints that reference me <Array of Constraint>
	determinedBy	the constraint that currently determines
					my value (or nil if there isn''t one) <Constraint>
	walkStrength		my walkabout strength <Strength>
	stay			true if I am a planning-time constant <Boolean>
	mark			used by the planner to mark constraints <Number>'!


AbstractConstraint subclass: #UnaryConstraint
	instanceVariableNames: 'output satisfied '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-Constraints'!

UnaryConstraint comment:
'I am an abstract superclass for constraints having a single possible output
variable.

Instance variables:
	output		possible output variable <Variable>
	satisfied		true if I am currently satisfied <Boolean>'!

UnaryConstraint subclass: #EditConstraint
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-Constraints'!

EditConstraint comment:
'I am a unary input constraint used to mark a variable that the client
wishes to change.'!

UnaryConstraint subclass: #StayConstraint
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-Constraints'!

StayConstraint comment:
'I mark variables that should, with some level of preference, stay the same.
I have one method with zero inputs and one output, which does nothing. Planners
may exploit the fact that, if I am satisfied, my output will not change during
plan execution. This is called "stay optimization."'!

AbstractConstraint subclass: #BinaryConstraint
	instanceVariableNames: 'v1 v2 direction '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-Constraints'!

BinaryConstraint comment:
'I am an abstract superclass for constraints having two possible output
variables.

Instance variables:
	v1, v2		possible output variables <Variable>
	direction		one of:
					#forward (v2 is output)
					#backward (	v1 is output)
					nil (not satisfied)'!

BinaryConstraint subclass: #ScaleConstraint
	instanceVariableNames: 'scale offset '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-Constraints'!

ScaleConstraint comment:
'I relate two variables by the linear scaling relationship:
"v2 = (v1 * scale) + offset". Either v1 or v2 may be changed to maintain this
relationship but the scale factor and offset are considered read-only.

Instance variables:
	scale		scale factor input variable <Variable>
	offset		offset input variable <Variable>'!

BinaryConstraint subclass: #EqualityConstraint
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-Constraints'!

EqualityConstraint comment:
'I constrain two variables to have the same value: "v1 = v2".'!

OrderedCollection variableSubclass: #Plan
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DB-DeltaBlue'!

Plan comment:
'A Plan is an ordered list of constraints to be executed in sequence to
resatisfy all currently satisfiable constraints in the face of one or more
changing inputs.'!


!UnaryConstraint methodsFor: 'initialize-release'!

var: aVariable strength: strengthSymbol
	"Initialize myself with the given variable and strength."

	strength := Strength of: strengthSymbol.
	output := aVariable.
	satisfied := false.
	self addConstraint.! !

!UnaryConstraint methodsFor: 'queries'!

isSatisfied
	"Answer true if this constraint is satisfied in the current solution."

	^satisfied! !

!UnaryConstraint methodsFor: 'add/remove'!

addToGraph
	"Add myself to the constraint graph."

	output addConstraint: self.
	satisfied := false.!

removeFromGraph
	"Remove myself from the constraint graph."

	(output == nil) ifFalse: [output removeConstraint: self].
	satisfied := false.! !

!UnaryConstraint methodsFor: 'planning'!

chooseMethod: mark
	"Decide if I can be satisfied and record that decision."

	satisfied :=
		(output mark ~= mark) and:
		[strength stronger: output walkStrength].!

execute
	"Enforce this constraint. Assume that it is satisfied."

	self subclassResponsibility!

inputsDo: aBlock
	"I have no input variables."!

markUnsatisfied
	"Record the fact that I am unsatisfied."

	satisfied := false.!

output
	"Answer my current output variable."

	^output!

recalculate
	"Calculate the walkabout strength, the stay flag, and, if it is 'stay',
	 the value for the current output of this constraint. Assume this
	 constraint is satisfied."

	output walkStrength: strength.
	output stay: (self isInput not).
	(output stay) ifTrue: [self execute].	"stay optimization"! !


!EditConstraint methodsFor: 'queries'!

isInput
	"I indicate that a variable is to be changed by imperative code."

	^true! !

!EditConstraint methodsFor: 'execution'!

execute
	"Edit constraints do nothing."! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EditConstraint class
	instanceVariableNames: ''!


!EditConstraint class methodsFor: 'instance creation'!

var: aVariable strength: strengthSymbol
	"Install an edit constraint with the given strength on the given
	 variable."

	^(self new) var: aVariable strength: strengthSymbol! !


!StayConstraint methodsFor: 'execution'!

execute
	"Stay constraints do nothing."! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

StayConstraint class
	instanceVariableNames: ''!


!StayConstraint class methodsFor: 'instance creation'!

var: aVariable strength: strengthSymbol
	"Install a stay constraint with the given strength on the given variable."

	^(self new) var: aVariable strength: strengthSymbol! !


!BinaryConstraint methodsFor: 'initialize-release'!

var: variable1 var: variable2 strength: strengthSymbol
	"Initialize myself with the given variables and strength."

	strength := Strength of: strengthSymbol.
	v1 := variable1.
	v2 := variable2.
	direction := nil.
	self addConstraint.! !

!BinaryConstraint methodsFor: 'queries'!

isSatisfied
	"Answer true if this constraint is satisfied in the current solution."

	^direction notNil! !

!BinaryConstraint methodsFor: 'add/remove'!

addToGraph
	"Add myself to the constraint graph."

	v1 addConstraint: self.
	v2 addConstraint: self.
	direction := nil.!

removeFromGraph
	"Remove myself from the constraint graph."

	(v1 == nil) ifFalse: [v1 removeConstraint: self].
	(v2 == nil) ifFalse: [v2 removeConstraint: self].
	direction := nil.! !

!BinaryConstraint methodsFor: 'planning'!

chooseMethod: mark
	"Decide if I can be satisfied and which way I should flow based on
	 the relative strength of the variables I relate, and record that
	 decision."

	(v1 mark == mark) ifTrue:		"forward or nothing"
		[((v2 mark ~= mark) and: [strength stronger: v2 walkStrength])
			ifTrue: [^direction := #forward]
			ifFalse: [^direction := nil]].

	(v2 mark == mark) ifTrue:		"backward or nothing"
		[((v1 mark ~= mark) and: [strength stronger: v1 walkStrength])
			ifTrue: [^direction := #backward]
			ifFalse: [^direction := nil]].

	"if we get here, neither variable is marked, so we have choice"
	(v1 walkStrength weaker: v2 walkStrength)
		ifTrue:
			[(strength stronger: v1 walkStrength)
				ifTrue: [^direction := #backward]
				ifFalse: [^direction := nil]]
		ifFalse:
			[(strength stronger: v2 walkStrength)
				ifTrue: [^direction := #forward]
				ifFalse: [^direction := nil]].!

execute
	"Enforce this constraint. Assume that it is satisfied."

	self subclassResponsibility!

inputsDo: aBlock
	"Evaluate the given block on my current input variable."

	(direction == #forward)
		ifTrue: [aBlock value: v1]
		ifFalse: [aBlock value: v2].!

markUnsatisfied
	"Record the fact that I am unsatisfied."

	direction := nil.!

output
	"Answer my current output variable."

	(direction == #forward)
		ifTrue: [^v2]
		ifFalse: [^v1]!

recalculate
	"Calculate the walkabout strength, the stay flag, and, if it is 'stay',
         the value for the current output of this constraint. Assume this
	 constraint is satisfied."

	| in out |
	(direction == #forward)
		ifTrue: [in := v1. out := v2]
		ifFalse: [in := v2. out := v1].
	out walkStrength: (strength weakest: in walkStrength).
	out stay: (in stay).
	(out stay) ifTrue: [self execute].		"stay optimization"! !


!ScaleConstraint methodsFor: 'initialize-release'!

src: srcVar scale: scaleVar offset: offsetVar dst: dstVar strength: strengthSymbol
	"Initialize myself with the given variables and strength."

	strength := Strength of: strengthSymbol.
	v1 := srcVar.
	v2 := dstVar.
	scale := scaleVar.
	offset := offsetVar.
	direction := nil.
	self addConstraint.! !

!ScaleConstraint methodsFor: 'add/remove'!

addToGraph
	"Add myself to the constraint graph."

	v1 addConstraint: self.
	v2 addConstraint: self.
	scale addConstraint: self.
	offset addConstraint: self.
	direction := nil.!

removeFromGraph
	"Remove myself from the constraint graph."

	(v1 == nil) ifFalse: [v1 removeConstraint: self].
	(v2 == nil) ifFalse: [v2 removeConstraint: self].
	(scale == nil) ifFalse: [scale removeConstraint: self].
	(offset == nil) ifFalse: [offset removeConstraint: self].
	direction := nil.! !

!ScaleConstraint methodsFor: 'planning'!

execute
	"Enforce this constraint. Assume that it is satisfied."

	(direction == #forward)
		ifTrue: [v2 value: (v1 value * scale value) + offset value]
		ifFalse: [v1 value: (v2 value - offset value) // scale value].!

inputsDo: aBlock
	"Evaluate the given block on my current input variable."

	(direction == #forward)
		ifTrue: [aBlock value: v1; value: scale; value: offset]
		ifFalse: [aBlock value: v2; value: scale; value: offset].!

recalculate
	"Calculate the walkabout strength, the stay flag, and, if it is 'stay',
	 the value for the current output of this constraint. Assume this
	 constraint is satisfied."

	| in out |
	(direction == #forward)
		ifTrue: [in := v1. out := v2]
		ifFalse: [out := v1. in := v2].
	out walkStrength: (strength weakest: in walkStrength).
	out stay: ((in stay) and: [(scale stay) and: [offset stay]]).
	(out stay) ifTrue: [self execute].		"stay optimization"! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScaleConstraint class
	instanceVariableNames: ''!


!ScaleConstraint class methodsFor: 'instance creation'!

var: src var: scale var: offset var: dst strength: strengthSymbol
	"Install a scale constraint with the given strength on the given
	 variables."

	^(self new) src: src scale: scale offset: offset dst: dst strength: strengthSymbol! !


!EqualityConstraint methodsFor: 'execution'!

execute
	"Enforce this constraint. Assume that it is satisfied."

	(direction == #forward)
		ifTrue: [v2 value: v1 value]
		ifFalse: [v1 value: v2 value].! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EqualityConstraint class
	instanceVariableNames: ''!


!EqualityConstraint class methodsFor: 'instance creation'!

var: variable1 var: variable2 strength: strengthSymbol
	"Install a constraint with the given strength equating the given
	 variables."

	^(self new) var: variable1 var: variable2 strength: strengthSymbol! !


!Planner methodsFor: 'initialize'!

initialize
	"Planner initialize"

	currentMark := 1.! !

!Planner methodsFor: 'add/remove'!

incrementalAdd: c
	"Attempt to satisfy the given constraint and, if successful,
	 incrementally update the dataflow graph.

	 Details: If satifying the constraint is successful, it may override a
	 weaker constraint on its output. The algorithm attempts to resatisfy
	 that constraint using some other method. This process is repeated
	 until either a) it reaches a variable that was not previously
	 determined by any constraint or b) it reaches a constraint that
	 is too weak to be satisfied using any of its methods. The variables
	 of constraints that have been processed are marked with a unique mark
	 value so that we know where we've been. This allows the algorithm to
	 avoid getting into an infinite loop even if the constraint graph has
	 an inadvertent cycle."

	| mark overridden |
	mark := self newMark.
	overridden := c satisfy: mark.
	[overridden == nil] whileFalse:
		[overridden := overridden satisfy: mark].!

incrementalRemove: c
	"Entry point for retracting a constraint. Remove the given constraint,
	 which should be satisfied, and incrementally update the dataflow
	 graph.

	 Details: Retracting the given constraint may allow some currently
	 unsatisfiable downstream constraint be satisfied. We thus collect a
	 list of unsatisfied downstream constraints and attempt to satisfy
	 each one in turn. This list is sorted by constraint strength,
	 strongest first, as a heuristic for avoiding unnecessarily adding
	 and then overriding weak constraints."

	| out unsatisfied |
	out := c output.
	c markUnsatisfied.
	c removeFromGraph.
	unsatisfied := self removePropagateFrom: out.
	unsatisfied do: [: u | self incrementalAdd: u].! !

!Planner methodsFor: 'planning/value propagation'!

extractPlanFromConstraints: constraints
	"Extract a plan for resatisfaction starting from the outputs of the
	 given constraints, usually a set of input constraints."

	| sources |
	sources := OrderedCollection new.
	constraints do:
		[: c | ((c isInput) and: [c isSatisfied]) ifTrue: [sources add: c]].
	^self makePlan: sources!

extractPlanFromVariables: variables
	"Extract a plan from the dataflow graph having the given variables. It
	 is assumed that the given set of variables is complete, or at least
	 that it contains all the input variables."

	| sources |
	sources := OrderedCollection new.
	variables do:
		[: v |
		 (v constraints) do:
			[: c | ((c isInput) and: [c isSatisfied]) ifTrue: [sources add: c]]].
	^self makePlan: sources!

makePlan: sources
	"Extract a plan for resatisfaction starting from the given satisfied
	 source constraints, usually a set of input constraints. This method
	 assumes that stay optimization is desired; the plan will contain only
	 constraints whose output variables are not stay. Constraints that do
	 no computation, such as stay and edit constraints, are not included
	 in the plan.

	 Details: The outputs of a constraint are marked when it is added to
	 the plan under construction. A constraint may be appended to the plan
	 when all its input variables are known. A variable is known if either
	 a) the variable is marked (indicating that has been computed by a
	 constraint appearing earlier in the plan), b) the variable is 'stay'
	 (i.e. it is a constant at plan execution time), or c) the variable
	 is not determined by any constraint. The last provision is for past
	 states of history variables, which are not stay but which are also
	 not computed by any constraint."

	| mark plan todo c |
	mark := self newMark.
	plan := Plan new.
	todo := sources.
	[todo isEmpty] whileFalse:
		[c := todo removeFirst.
		 ((c output mark ~= mark) and:		"not in plan already and..."
		  [c inputsKnown: mark]) ifTrue:	"eligible for inclusion"
			[plan addLast: c.
			 c output mark: mark.
			 self addConstraintsConsuming: c output to: todo]].
	^plan!

propagateFrom: v
	"The given variable has changed. Propagate new values downstream."

	| todo c |
	todo := OrderedCollection new.
	self addConstraintsConsuming: v to: todo.
	[todo isEmpty] whileFalse:
		[c := todo removeFirst.
		 c execute.
		 self addConstraintsConsuming: c output to: todo].! !

!Planner methodsFor: 'private'!

addConstraintsConsuming: v to: aCollection

	| determiningC |
	determiningC := v determinedBy.
	v constraints do:
		[: c |
		 ((c == determiningC) or: [c isSatisfied not]) ifFalse:
			[aCollection add: c]].!

addPropagate: c mark: mark
	"Recompute the walkabout strengths and stay flags of all variables
	 downstream of the given constraint and recompute the actual values
	 of all variables whose stay flag is true. If a cycle is detected,
	 remove the given constraint and answer false. Otherwise, answer true.

	 Details: Cycles are detected when a marked variable is encountered
	 downstream of the given constraint. The sender is assumed to have
	 marked the inputs of the given constraint with the given mark. Thus,
	 encountering a marked node downstream of the output constraint means
	 that there is a path from the constraint's output to one of its
	 inputs."

	| todo d |
	todo := OrderedCollection with: c.
	[todo isEmpty] whileFalse:
		[d := todo removeFirst.
		 (d output mark = mark) ifTrue:
			[self incrementalRemove: c.
			 ^false].
		 d recalculate.
		 self addConstraintsConsuming: d output to: todo].
	^true!

changeVar: aVariable newValue: newValue

	| editConstraint plan |
	editConstraint := EditConstraint var: aVariable strength: #preferred.
	plan := self extractPlanFromConstraints: (Array with: editConstraint).
	10 timesRepeat: [
		aVariable value: newValue.
		plan execute].
	editConstraint destroyConstraint.!

constraintsConsuming: v do: aBlock

	| determiningC |
	determiningC := v determinedBy.
	v constraints do:
		[: c |
		 ((c == determiningC) or: [c isSatisfied not]) ifFalse:
			[aBlock value: c]].!

newMark
	"Select a previously unused mark value.

	 Details: We just keep incrementing. If necessary, the counter will
	 turn into a LargePositiveInteger. In that case, it will be a bit
	 slower to compute the next mark but the algorithms will all behave
	 correctly. We reserve the value '0' to mean 'unmarked'. Thus, this
	 generator starts at '1' and will never produce '0' as a mark value."

	^currentMark := currentMark + 1!

removePropagateFrom: out
	"Update the walkabout strengths and stay flags of all variables
	 downstream of the given constraint. Answer a collection of unsatisfied
	 constraints sorted in order of decreasing strength."

	| unsatisfied todo v nextC |
	unsatisfied := SortedCollection sortBlock:
		[: c1 : c2 | c1 strength stronger: c2 strength].
	out determinedBy: nil.
	out walkStrength: Strength absoluteWeakest.
	out stay: true.
	todo := OrderedCollection with: out.
	[todo isEmpty] whileFalse:
		[v := todo removeFirst.
		 v constraints do:
		 	[: c | (c isSatisfied) ifFalse: [unsatisfied add: c]].
		 self constraintsConsuming: v do:
			[: c |
			 c recalculate.
			 todo add: c output]].
	^unsatisfied! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!


!Planner class methodsFor: 'instance creation'!

new
	^currentPlanner := super new initialize! !

!Planner class methodsFor: 'benchmarks'!

chainTest: n
	"Do chain-of-equality-constraints performance tests."

	| vars editConstraint plan planner |
	planner := Planner new.
	vars := (1 to: n+1) collect: [ :i | Variable new].

	"thread a chain of equality constraints through the variables"
	1 to: n do:
		[ :i || v1 v2 |
		 v1 := vars at: i.
		 v2 := vars at: i + 1.
		 EqualityConstraint var: v1 var: v2 strength: #required].

	StayConstraint var: vars last strength: #strongDefault.
	editConstraint := EditConstraint var: (vars first) strength: #preferred.
	plan := planner extractPlanFromConstraints: (Array with: editConstraint).
	1 to: 100 do: [ :v | 
		vars first value: v.
		plan execute.
		vars last value ~= v ifTrue: [self error: 'Chain test failed!!']].
	editConstraint destroyConstraint!

projectionTest: n
	"This test constructs a two sets of variables related to each other by
	 a simple linear transformation (scale and offset)."

	| scale offset src dst planner dests |
	planner := Planner new.
	dests := OrderedCollection new.
	scale := Variable value: 10.
	offset := Variable value: 1000.
	1 to: n do:
		[ :i |
		src := Variable value: i.
		dst := Variable value: i.
		dests add: dst.
		StayConstraint var: src strength: #default.
		ScaleConstraint var: src var: scale var: offset var: dst strength: #required].

	planner changeVar: src newValue: 17.
	dst value ~= 1170 ifTrue: [self error: 'Projection test 1 failed!!'].

	planner changeVar: dst newValue: 1050.
	src value ~= 5 ifTrue: [self error: 'Projection test 2 failed!!'].

	planner changeVar: scale newValue: 5.
	1 to: n - 1 do: [ :i |
		(dests at: i) value ~= (i*5 + 1000)
			ifTrue: [self error: 'Projection test 3 failed!!']].

	planner changeVar: offset newValue: 2000.
	1 to: n - 1 do: [ :i |
		(dests at: i) value ~= (i*5 + 2000)
			ifTrue: [self error: 'Projection test 4 failed!!']].!

report: string times: count run: aBlock
	"Report the time required to execute the given block."

	| time |
	time := Time millisecondsToRun: [count timesRepeat: aBlock].
	Transcript show: string, ' ', (time // count) printString, ' milliseconds'; cr.!

standardBenchmark
	"This the combined benchmark."
	"Planner standardBenchmark"

	self report: 'Chain and projection tests' times: 100 run: [
		self chainTest: 100. 
		self projectionTest: 100
	]! !

!Planner class methodsFor: 'accessing'!

current
	^currentPlanner! !


!Plan methodsFor: 'execution'!

execute
	"Execute my constraints in order."

	self do: [: c | c execute].! !



!Strength methodsFor: 'comparing'!

sameAs: aStrength
	"Answer true if I am the same strength as the given Strength."

	^arithmeticValue = aStrength arithmeticValue!

stronger: aStrength
	"Answer true if I am stronger than the given Strength."

	^arithmeticValue < aStrength arithmeticValue!

weaker: aStrength
	"Answer true if I am weaker than the given Strength."

	^arithmeticValue > aStrength arithmeticValue! !

!Strength methodsFor: 'max/min'!

strongest: aStrength
	"Answer the stronger of myself and aStrength."

	(aStrength stronger: self)
		ifTrue: [^aStrength]
		ifFalse: [^self].!

weakest: aStrength
	"Answer the weaker of myself and aStrength."

	(aStrength weaker: self)
		ifTrue: [^aStrength]
		ifFalse: [^self].! !

!Strength methodsFor: 'printing'!

printOn: aStream
	"Append a string which represents my strength onto aStream."

	aStream nextPutAll: '%', symbolicValue, '%'.! !

!Strength methodsFor: 'private'!

arithmeticValue
	"Answer my arithmetic value. Used for comparisons. Note that
	 STRONGER constraints have SMALLER arithmetic values."

	^arithmeticValue!

initializeWith: symVal
	"Record my symbolic value and reset my arithmetic value."

	symbolicValue := symVal.
	arithmeticValue := StrengthTable at: symbolicValue.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Strength class
	instanceVariableNames: ''!


!Strength class methodsFor: 'class initialization'!

initialize
	"Initialize the symbolic strength table. Fix the internally caches
	 values of all existing instances."
	"Strength initialize"

	StrengthTable := Dictionary new.
	StrengthTable at: #absoluteStrongest put: -10000.
	StrengthTable at: #required put: -800.
	StrengthTable at: #strongPreferred put: -600.
	StrengthTable at: #preferred put: -400.
	StrengthTable at: #strongDefault put: -200.
	StrengthTable at: #default put: 0.
	StrengthTable at: #weakDefault put: 500.
	StrengthTable at: #absoluteWeakest put: 10000.

	StrengthConstants := Dictionary new.
	StrengthTable keys do:
		[: strengthSymbol |
			StrengthConstants
				at: strengthSymbol
				put: ((super new) initializeWith: strengthSymbol)].

	AbsoluteStrongest := Strength of: #absoluteStrongest.
	AbsoluteWeakest := Strength of: #absoluteWeakest.
	Required := Strength of: #required.! !

!Strength class methodsFor: 'instance creation'!

of: aSymbol
	"Answer an instance with the specified strength."

	^StrengthConstants at: aSymbol! !

!Strength class methodsFor: 'constants'!

absoluteStrongest

	^AbsoluteStrongest!

absoluteWeakest

	^AbsoluteWeakest!

required

	^Required! !



!AbstractConstraint methodsFor: 'accessing'!

strength
	"Answer my strength."

	^strength!

strength: strengthSymbol
	"Set my strength."

	strength := Strength of: strengthSymbol.! !

!AbstractConstraint methodsFor: 'queries'!

isInput
	"Normal constraints are not input constraints. An input constraint is
	 one that depends on external state, such as the mouse, the keyboard,
	 a clock, or some arbitrary piece of imperative code."

	^false!

isSatisfied
	"Answer true if this constraint is satisfied in the current solution."

	self subclassResponsibility! !

!AbstractConstraint methodsFor: 'add/remove'!

addConstraint
	"Activate this constraint and attempt to satisfy it."

	self addToGraph.
	Planner current incrementalAdd: self.!

addToGraph
	"Add myself to the constraint graph."

	self subclassResponsibility!

destroyConstraint
	"Deactivate this constraint, remove it from the constraint graph,
	 possibly causing other constraints to be satisfied, and destroy it."

	(self isSatisfied) ifTrue: [Planner current incrementalRemove: self].
	self removeFromGraph.
	self release.!

removeFromGraph
	"Remove myself from the constraint graph."

	self subclassResponsibility! !

!AbstractConstraint methodsFor: 'planning'!

chooseMethod: mark
	"Decide if I can be satisfied and record that decision. The output of
	 the choosen method must not have the given mark and must have a
	 walkabout strength less than that of this constraint."

	self subclassResponsibility!

execute
	"Enforce this constraint. Assume that it is satisfied."

	self subclassResponsibility!

inputsDo: aBlock
	"Assume that I am satisfied. Evaluate the given block on all my current
	 input variables."

	self subclassResponsibility!

inputsKnown: mark
	"Assume that I am satisfied. Answer true if all my current inputs are
	 known. A variable is known if either a) it is 'stay' (i.e. it is a
	 constant at plan execution time), b) it has the given mark (indicating
	 that it has been computed by a constraint appearing earlier in the
	 plan), or c) it is not determined by any constraint."

	self inputsDo:
		[: v |
		 ((v mark = mark) or: [(v stay) or: [v determinedBy == nil]]) ifFalse:
			[^false]].
	^true!

markUnsatisfied
	"Record the fact that I am unsatisfied."

	self subclassResponsibility!

output
	"Answer my current output variable. Raise an error if I am not
	 currently satisfied."

	self subclassResponsibility!

recalculate
	"Calculate the walkabout strength, the stay flag, and, if it is 'stay',
	 the value for the current output of this constraint. Assume this
	 constraint is satisfied."

	self subclassResponsibility!

satisfy: mark
	"Attempt to find a way to enforce this (still unsatisfied) constraint.
	 If successful, record the solution, perhaps modifying the current
	 dataflow graph.  Answer the constraint that this constraint overrides,
	 if there is one, or nil, if there isn't."

	| overridden out |
	self chooseMethod: mark.
	(self isSatisfied)
		ifTrue:			"constraint can be satisfied"
			["mark inputs to allow cycle detection in addPropagate"
			 self inputsDo: [: in | in mark: mark].
			 out := self output.
			 overridden := out determinedBy.
			 (overridden == nil) ifFalse: [overridden markUnsatisfied].
			 out determinedBy: self.
			 (Planner current addPropagate: self mark: mark) ifFalse:
				[self notify:
					('Cycle encountered adding:\   ',
					 self printString,
					 '\Constraint removed.') withCRs.
				 ^nil].
			 out mark: mark]
		ifFalse:			"constraint cannot be satisfied"
			[overridden := nil.
			 (strength sameAs: (Strength required)) ifTrue:
				[self notify: 'Failed to satisfy a required constraint']].
	^overridden! !

!AbstractConstraint methodsFor: 'printing'!

longPrintOn: aStream

	| bindings |
	aStream nextPut: $(.
	self shortPrintOn: aStream.
	aStream space; nextPutAll: self strength printString.
	(self isSatisfied)
		ifTrue:
			[aStream cr; space; space; space.
			 self inputsDo:
				[: in | aStream nextPutAll: 'v', in asOop printString, ' '].
			aStream nextPutAll: '-> '.
			aStream nextPutAll: 'v', self output asOop printString]
		ifFalse:
			[aStream space; nextPutAll: 'UNSATISFIED'].
	aStream nextPut: $); cr.!

printOn: aStream

	self shortPrintOn: aStream!

shortPrintOn: aStream

	aStream nextPutAll: self class name, '(', self asOop printString, ')'.! !


!Variable methodsFor: 'initialize-release'!

initialize

	value := 0.
	constraints := OrderedCollection new: 2.
	determinedBy := nil.
	walkStrength := Strength absoluteWeakest.
	stay := true.
	mark := 0.! !

!Variable methodsFor: 'access'!

addConstraint: aConstraint
	"Add the given constraint to the set of all constraints that refer
	 to me."

	constraints add: aConstraint.!

constraints
	"Answer the set of constraints that refer to me."

	^constraints!

determinedBy
	"Answer the constraint that determines my value in the current
	 dataflow."

	^determinedBy!

determinedBy: aConstraint
	"Record that the given constraint determines my value in the current
	 data flow."

	determinedBy := aConstraint.!

mark
	"Answer my mark value."

	^mark!

mark: markValue
	"Set my mark value."

	mark := markValue.!

removeConstraint: c
	"Remove all traces of c from this variable."

	constraints remove: c ifAbsent: [].
	(determinedBy == c) ifTrue: [determinedBy := nil].!

stay
	"Answer my stay flag."

	^stay!

stay: aBoolean
	"Set my stay flag."

	stay := aBoolean!

value
	"Answer my value."

	^value!

value: anObject
	"Set my value."

	value := anObject.!

walkStrength
	"Answer my walkabout strength in the current dataflow."

	^walkStrength!

walkStrength: aStrength
	"Set my walkabout strength in the current dataflow."

	walkStrength := aStrength.! !

!Variable methodsFor: 'changes'!

setValue: aValue
	"Attempt to assign the given value to me using a strength of
	 #preferred."

	self setValue: aValue strength: #preferred.!

setValue: aValue strength: strengthSymbol
	"Attempt to assign the given value to me using the given strength."

	| editConstraint |
	editConstraint := EditConstraint var: self strength: strengthSymbol.
	(editConstraint isSatisfied) ifTrue:
		[self value: aValue.
		 Planner propagateFrom: self].
	editConstraint destroyConstraint.! !

!Variable methodsFor: 'printing'!

longPrintOn: aStream

	self shortPrintOn: aStream.
	aStream nextPutAll: '   Constraints: '.
	(constraints isEmpty)
		ifTrue: [aStream cr; tab; nextPutAll: 'none']
		ifFalse:
			[constraints do:
				[: c | aStream cr; tab. c shortPrintOn: aStream]].
	(determinedBy isNil) ifFalse:
		[aStream cr; nextPutAll: '   Determined by: '.
		 aStream cr; tab. determinedBy shortPrintOn: aStream].
	aStream cr.!

printOn: aStream

	self shortPrintOn: aStream!

shortPrintOn: aStream

	aStream nextPutAll: 'V(', self asOop printString, ', '.
	aStream nextPutAll: walkStrength printString, ', '.
	(stay isNil) ifFalse:
		[aStream nextPutAll: (stay ifTrue: ['stay, '] ifFalse: ['changing, '])].
	aStream nextPutAll: value printString.
	aStream nextPutAll: ')'.
	aStream cr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Variable class
	instanceVariableNames: ''!


!Variable class methodsFor: 'instance creation'!

new

	^super new initialize!

value: aValue

	^(super new) initialize; value: aValue! !
Strength initialize!

