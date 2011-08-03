nodist_check_DATA = gst.im

AUTOTEST = $(AUTOM4TE) --language=autotest
TESTSUITE = $(srcdir)/testsuite

dist_noinst_DATA = \
atlocal.in local.at testsuite.at $(TESTSUITE) package.m4 \
ackermann.ok ackermann.st arrays.ok arrays.st ary3.ok ary3.st blocks.ok \
blocks.st chars.ok chars.st classes.ok classes.st cobjects.ok cobjects.st \
compiler.ok compiler.st dates.ok dates.st delays.ok delays.st except.ok \
except.st exceptions.ok exceptions.st fibo.ok fibo.st fileext.ok fileext.st \
floatmath.ok floatmath.st getopt.ok getopt.st geometry.ok geometry.st hash.ok \
hash.st hash2.ok hash2.st heapsort.ok heapsort.st intmath.ok intmath.st \
lists.ok lists.st lists1.ok lists1.st lists2.ok lists2.st matrix.ok \
matrix.st methcall.ok methcall.st mutate.ok mutate.st nestedloop.ok \
nestedloop.st objects.ok objects.st objinst.ok \
objinst.st processes.ok processes.st prodcons.ok prodcons.st quit.ok \
quit.st random-bench.ok random-bench.st untrusted.ok untrusted.st sets.ok \
sets.st sieve.ok sieve.st strcat.ok strcat.st strings.ok strings.st \
pools.ok pools.st Ansi.st AnsiDB.st AnsiInit.st AnsiLoad.st AnsiRun.st \
stcompiler.st stcompiler.ok shape.st shape.ok

CLEANFILES = gst.im
DISTCLEANFILES = atconfig

.PHONY: regress

regress:
	cd $(srcdir) || exit 1; \
	for test in $(TESTS); do \
	  result=`echo $$test | $(SED) 's/st$$/ok/'`; \
	  @abs_top_builddir@/gst --image=@abs_top_builddir@/gst.im -r $$test 2>&1 | tee $$result; \
	done

gst.im: ../kernel/stamp-classes AnsiLoad.st Ansi.st AnsiDB.st
	echo "PackageLoader fileInPackage: #SUnit. ObjectMemory snapshot: 'gst.im'" | ./gst --image=../gst.im -
	cd $(srcdir) && @abs_builddir@/gst -S --image=@abs_top_builddir@/tests/gst.im AnsiLoad.st

$(srcdir)/package.m4: $(top_srcdir)/configure.ac
	{                                      \
	    echo '# Signature of the current package.'; \
	    echo 'm4_define([AT_PACKAGE_NAME],      [@PACKAGE_NAME@])'; \
	    echo 'm4_define([AT_PACKAGE_TARNAME],   [@PACKAGE_TARNAME@])'; \
	    echo 'm4_define([AT_PACKAGE_VERSION],   [@PACKAGE_VERSION@])'; \
	    echo 'm4_define([AT_PACKAGE_STRING],    [@PACKAGE_STRING@])'; \
	    echo 'm4_define([AT_PACKAGE_BUGREPORT], [@PACKAGE_BUGREPORT@])'; \
	  } >'$(srcdir)/package.m4'

check-local: gst atlocal atconfig $(TESTSUITE)
	$(SHELL) '$(TESTSUITE)' $(TESTSUITEFLAGS)

clean-local:
	-$(SHELL) '$(TESTSUITE)' --clean

installcheck-local: atlocal atconfig $(TESTSUITE)
	if test -z "$(DESTDIR)"; then \
	  $(SHELL) '$(TESTSUITE)' $(TESTSUITEFLAGS) AUTOTEST_PATH=$(bindir); \
	fi

$(TESTSUITE): $(srcdir)/testsuite.at $(srcdir)/package.m4 $(srcdir)/local.at
	$(AUTOTEST) -I '$(srcdir)' -o $@.tmp $@.at
	mv $@.tmp $@
