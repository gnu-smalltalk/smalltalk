TESTS = $(low_level_tests) $(ansi_tests)

low_level_tests = arrays.st classes.st blocks.st \
	sets.st processes.st exceptions.st \
	intmath.st floatmath.st dates.st \
	objects.st strings.st chars.st objdump.st \
	delays.st geometry.st cobjects.st compiler.st \
	fileext.st mutate.st

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
arrays.ok      classes.st    cobjects.st  \
intmath.ok     processes.st  arrays.st	  \
exceptions.ok  intmath.st    sets.ok	  \
blocks.ok      exceptions.st sets.st      \
blocks.st      dates.ok      floatmath.ok \
strings.ok     chars.ok      dates.st     \
floatmath.st   objects.ok    strings.st   \
chars.st       delays.ok     geometry.ok  \
objects.st     classes.ok    delays.st    \
geometry.st    processes.ok  cobjects.ok  \
compiler.ok    compiler.st   objdump.ok   \
objdump.st     fileext.st    fileext.ok   \
mutate.st      mutate.ok     AnsiDB.st    \
Ansi.st	       AnsiInit.st   AnsiRun.st   \
AnsiLoad.st

CLEANFILES = *.log *.diff gst.im

EXTRA_DIST = run-test

.PHONY: regress $(ansi_tests)

$(ansi_tests):

regress:
	SMALLTALK_KERNEL="$(top_srcdir)/kernel/"; \
	export SMALLTALK_KERNEL; \
	for test in $(low_level_tests); do \
	  result=`echo $$test|sed 's/st$$/ok/'`; \
	  $(top_builddir)/gst -I $(top_builddir)/gst.im \
		-r $$test 2>&1 | tee $$result; \
	done

gst.im: ../kernel/stamp-classes AnsiLoad.st Ansi.st AnsiDB.st
	builddir=`pwd`; cd $(srcdir) && \
	  SMALLTALK_IMAGE=$$builddir SMALLTALK_KERNEL=../kernel \
	    $$builddir/../gst -QSsi AnsiLoad.st

