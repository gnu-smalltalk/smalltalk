TESTS = $(low_level_tests) $(benchmark_tests) $(ansi_tests)

low_level_tests = arrays.st classes.st blocks.st \
	sets.st processes.st exceptions.st \
	intmath.st floatmath.st dates.st \
	objects.st strings.st chars.st objdump.st \
	delays.st geometry.st cobjects.st compiler.st \
	fileext.st mutate.st untrusted.st getopt.st \
	quit.st

benchmark_tests = ackermann.st ary3.st except.st \
	fibo.st hash.st hash2.st heapsort.st \
	lists.st lists1.st lists2.st matrix.st \
	methcall.st nestedloop.st objinst.st \
	prodcons.st random-bench.st sieve.st strcat.st

ansi_tests = \
	ArrayANSITest \
	ArrayFactoryANSITest \
	BagANSITest \
	BagFactoryANSITest \
	BooleanANSITest \
	ByteArrayANSITest \
	ByteArrayFactoryANSITest \
	CharacterANSITest \
	CharacterFactoryANSITest \
	DateAndTimeANSITest \
	DateAndTimeFactoryANSITest \
	DictionaryANSITest \
	DictionaryFactoryANSITest \
	DurationANSITest \
	DurationFactoryANSITest \
	DyadicValuableANSITest \
	ErrorANSITest \
	ErrorClassANSITest \
	ExceptionANSITest \
	ExceptionClassANSITest \
	ExceptionSetANSITest \
	FailedMessageANSITest \
	FileStreamFactoryANSITest \
	FloatANSITest \
	FloatCharacterizationANSITest \
	FractionANSITest \
	FractionFactoryANSITest \
	IdentityDictionaryANSITest \
	IdentityDictionaryFactoryANSITest \
	IntegerANSITest \
	IntervalANSITest \
	IntervalFactoryANSITest \
	MessageNotUnderstoodANSITest \
	MessageNotUnderstoodSelectorANSITest \
	MonadicBlockANSITest \
	NilANSITest \
	NiladicBlockANSITest \
	NotificationANSITest \
	NotificationClassANSITest \
	ObjectANSITest \
	ObjectClassANSITest \
	OrderedCollectionANSITest \
	OrderedCollectionFactoryANSITest \
	ReadFileStreamANSITest \
	ReadStreamANSITest \
	ReadStreamFactoryANSITest \
	ReadWriteStreamANSITest \
	ReadWriteStreamFactoryANSITest \
	ScaledDecimalANSITest \
	SelectorANSITest \
	SetANSITest \
	SetFactoryANSITest \
	SortedCollectionANSITest \
	SortedCollectionFactoryANSITest \
	StringANSITest \
	StringFactoryANSITest \
	SymbolANSITest \
	TranscriptANSITest \
	WarningANSITest \
	WarningClassANSITest \
	WriteFileStreamANSITest \
	WriteStreamANSITest \
	WriteStreamFactoryANSITest \
	ZeroDivideANSITest \
	ZeroDivideFactoryANSITest

TESTS_ENVIRONMENT=$(srcdir)/run-test

nodist_check_DATA = gst.im

dist_noinst_DATA = \
ackermann.ok ackermann.st arrays.ok arrays.st ary3.ok ary3.st blocks.ok \
blocks.st chars.ok chars.st classes.ok classes.st cobjects.ok cobjects.st \
compiler.ok compiler.st dates.ok dates.st delays.ok delays.st except.ok \
except.st exceptions.ok exceptions.st fibo.ok fibo.st fileext.ok fileext.st \
floatmath.ok floatmath.st getopt.ok getopt.st geometry.ok geometry.st hash.ok \
hash.st hash2.ok hash2.st heapsort.ok heapsort.st intmath.ok intmath.st \
lists.ok lists.st lists1.ok lists1.st lists2.ok lists2.st matrix.ok \
matrix.st methcall.ok methcall.st mutate.ok mutate.st nestedloop.ok \
nestedloop.st objdump.ok objdump.st objects.ok objects.st objinst.ok \
objinst.st processes.ok processes.st prodcons.ok prodcons.st quit.ok \
quit.st random-bench.ok random-bench.st untrusted.ok untrusted.st sets.ok \
sets.st sieve.ok sieve.st strcat.ok strcat.st strings.ok strings.st \
Ansi.st AnsiDB.st AnsiInit.st AnsiLoad.st AnsiRun.st

CLEANFILES = *.log *.diff gst.im

EXTRA_DIST = run-test

.PHONY: regress $(ansi_tests)

$(ansi_tests):

regress:
	cd $(srcdir) || exit 1; \
	for test in $(filter $(low_level_tests) $(benchmark_tests), $(TESTS)); do \
	  result=`echo $$test | $(SED) 's/st$$/ok/'`; \
	  @abs_top_builddir@/gst -I @abs_top_builddir@/gst.im \
	    -r $$test 2>&1 | tee $$result; \
	done

gst.im: ../kernel/stamp-classes AnsiLoad.st Ansi.st AnsiDB.st
	cp $(top_builddir)/gst.im .
	cd $(srcdir) && \
	  @abs_top_builddir@/gst -SI @abs_top_builddir@/tests/gst.im AnsiLoad.st

