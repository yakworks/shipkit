BEGIN {
	stderr = "/dev/stderr"
	logfil = "include.not"
	errfmt = "TRACE include.%s(%s)n"
}

{
	if (may_include()) {
		# mjm 7/26,27/2015
		# with_file( $3 )
		with_file($2)
		next
	}
	print
}


function may_include()
{
	# printf errfmt, "may_include", file > stderr
	# mjm 7/26,27/2015 -- use "iawk" @include syntax
	# return this_line($1 == "")
	return this_line($1 == "@include")
}

function this_line(res)
{
	printf("%3d %d %sn", NF, res, $0) > stderr
	return res
}

function with_file(file)
{
	printf(errfmt, "with_file", file) > stderr
	if (this_line((getline line < file) == -1)) {
		printf("needfile %sn", file) > logfil
		print
	} else {
		# side effect, "file" is opened, so,
		# close it to be able to read it:
		close(file)
		printf(errfmt, "about to INCLUDE", file) > stderr
		system("include " file)
	}
	# and since we may have just read it, close it again
	# if we opened it, or for the first time if we did not.
	# why? an app may include a file more than once.
	close(file)
}
