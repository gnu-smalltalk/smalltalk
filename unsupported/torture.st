"by Andreas Klimas

 This is a real torture test for the GC!! With a=100,000 and
 using IdentityDictionaries, it executes 120,000,000 bytecodes
 and 85 GCs!!"

| d a |

"When i reaches 75,000 GST crashes because of a chronical lack of OOP
 slots. I put a=74,000 just to leave some margin. With IdentityDictionaries,
 I got a up to 130,000 (because they don't chew up OOPs for the associations)."

a := 100000.

d := Dictionary new.
1 to: a do: [ :i |
    d at: i put: 'a little test ', i printString.
    (i \\ 100) = 0 ifTrue: [ i printNl ]
]!
