Object compileString: 'foo  3+'!
Object compileString: 'foo  3+' 
       ifError: [:a :b :c | a printNl.
			    b printNl.
			    c printNl]!

'test message' printNl!

