!Integer methodsFor: 'benchmarks'!

tinyBenchmarks
    "Report the results of running the two tiny Squeak benchmarks.
     
     The following table lists results for various Smalltalks on a
     300 MHz PentiumII PC.  Take these results with a grain of salt
     and read these notes:
     
     Notes:
     a) An object table does hinder performance of course, but not
     that much.  VisualWorks is still 25% faster than IBM Smalltalk,
     and even 40% in the `send message' benchmark where the object
     table should penalize it more.
     b) Smalltalk MT's sending performance is poor because numbers
     were obtained evaluating the benchmarks from the Transcript,
     which activates a non-optimized build -- creating an indipendent
     executable would bring numbers considerably higher.  Not owning
     a copy Smalltalk MT I cannot do that and correct the figures.
     c) I feel that the JIT compiler's performance is encouraging,
     although the current architecture cannot show great improvements
     in the sends benchmark.  Adding type inferencing will probably
     shorten the gap with VisualWorks, which is a derivative of the
     original ParcPlace translator!
     d) I know that some values are for obsolete versions of the
     tools.  Send updated values if you care.

	 ,--- (B)ytecode interpreter, (J)IT compiler, static (C)ompiler
	/ ,-- Uses (D)irect or (I)ndirect pointers
       / /
     ././.---------------------.---------------------.-----------------.
     |B|I| Dolphin Smalltalk   | 17.4 Mbytecodes/sec | 1112 Ksends/sec |
     |B|I| GST (with GCC 3.0)  | 22.4 Mbytecodes/sec | 1080 Ksends/sec |
     |J|D| IBM Smalltalk 3.0   | 61.9 Mbytecodes/sec | 4224 Ksends/sec |
     |J|I| GST (with JIT)      | 72.0 Mbytecodes/sec | 2625 Ksends/sec |
     |J|I| VisualWorks 5i      | 81.8 Mbytecodes/sec | 5950 Ksends/sec |
     |C|?| Smalltalk MT        |  128 Mbytecodes/sec | 1076 Ksends/sec |
     '-'-----------------------'---------------------'-----------------"


    | t1 t2 r n1 n2 |
    n1 _ 1 bitShift: self.
    [ObjectMemory compact. t1 _ Time millisecondsToRun: [n1 benchmark].
     t1 < 5000] whileTrue:[ n1 _ n1 * 2 ].

    n2 _ 24 + self.
    [ObjectMemory compact. t2 _ Time millisecondsToRun: [r _ n2 benchFib].
     t2 < 5000] whileTrue:[ n2 _ n2 + 1 ].

    ^((n1 * 500000 * 1000) // t1) printString, ' bytecodes/sec; ',
     ((r * 1000) // t2) printString, ' sends/sec'!

benchFib
    "Handy send-heavy benchmark -- result is number of sends:
     (result // seconds to run) = approx calls per second"
    ^self < 2
	ifTrue: [1] 
	ifFalse: [(self - 1) benchFib + (self - 2) benchFib + 1]
!

benchmark
    "Handy bytecode-heavy benchmark -- approx 500000 bytecodes per run:
     (500000 * times ran // secs to run) = approx bytecodes per second"

    | size flags prime k count |
    size _ 8190.
    flags _ Array new: size.
    self timesRepeat: [
	count _ 0.
	flags atAllPut: true.
	1 to: size do:
	    [:i | (flags at: i) ifTrue:
		[prime _ i+1.
		k _ i + prime.
		[k <= size] whileTrue:
		    [flags at: k put: false.
		    k _ k + prime].
		count _ count + 1]]].
    ^count
! !

Transcript showCr: 12 tinyBenchmarks!
