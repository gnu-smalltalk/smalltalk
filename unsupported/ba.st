3 + 4 !
3 * 4 !



| x |
    [ true ] whileTrue: 
	[ x := ByteArray new: 4.
	  1 to: 3 do: [ :i | x grow ]
	      ].
!
