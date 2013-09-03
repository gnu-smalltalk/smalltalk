TestCase subclass: TestContextPart [

    testContextStatePrint [
        <category: 'testing'>

        | ctxt stream |
        stream := WriteStream on: String new.
        ctxt := [ : a : b : c | | d e f | d := 21. e := 22. f := 23. thisContext ] value: 1 value: 2 value: 3.
        ctxt printContextStateOn: stream spaces: 2.
        self assert: stream contents = 
'  args:
    a -> 1
    b -> 2
    c -> 3
  temps:
    d -> 21
    e -> 22
    f -> 23
  optimized temps:
'.
    ]

    testOptimizedContextStatePrint [
        <category: 'testing'>

        | ctxt stream |
        stream := WriteStream on: String new.
        ctxt := [ : a : b : c | | d e f | d := 21. e := 22. f := 23. 1 to: 10 do: [ :i | ]. thisContext ] value: 1 value: 2 value: 3.
        ctxt printContextStateOn: stream spaces: 2.
        self assert: stream contents =
'  args:
    a -> 1
    b -> 2
    c -> 3
  temps:
    d -> 21
    e -> 22
    f -> 23
  optimized temps:
    7 -> 11
'.
    ]
]
