FileStream require: #CTypeParser -> 'CParseType.st'!

Smalltalk snapshot!

| x |
     CTypeParser test2: '/usr/include/curses.h'
!

Smalltalk quitPrimitive!

| x |
     CTypeParser test2: '/usr/include/libio.h'
!

Smalltalk quit!


| x |
     "CTypeParser test2: '/usr/include/sys/cdefs.h'"
     CTypeParser test2: '../sublibio.h'
!



