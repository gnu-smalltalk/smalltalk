| mutex empty full data consumed produced n join |

n := Smalltalk arguments isEmpty
	ifTrue: [ 10000 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

mutex := Semaphore forMutualExclusion.
empty := Semaphore new.
full := Semaphore new.
consumed := produced := 0.

join := Semaphore new.

empty signal.

[
    | i |
    i := 0.
    [
	full wait.
	mutex wait.
	i := data.
	mutex signal.
	empty signal.
	consumed := consumed + 1.
	i = n
    ] whileFalse.
    join signal.
] fork.

[
    1 to: n do: [ :i |
	empty wait.
	mutex wait.
	data := i.
	mutex signal.
	full signal.
	produced := produced + 1.
    ].
    join signal.
] fork.

join wait.
join wait.
('%1 %2' bindWith: produced with: consumed) displayNl!
