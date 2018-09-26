#!/usr/bin/python3
import sys

def applyformat(fname):
	"""
	This formats tests mechanically on a line by line basis.
	It is implemented as a statemachine, storing its state in 'state';
	The following states are possible:
		"outside_test_expect" -- a line outside a test_expect_* function
		"expecting_test_title" -- found a line with test_expect_*
					  but the title is on the next line
		"expecting_test_body" -- expecting the first line of the body
					 after an initial quote sign
		"inside_test_expect" -- in the body of a test function
	"""

	def emit_statements(l):
		nonlocal outlines
		ind = len(l) - len(l.lstrip())
		lines = l.strip().split("&&")

		for p in lines[:-1]:
			line = "\t"*ind + p.strip() + " &&\n"
			outlines += [line]

		if len(lines[-1]):
			line = "\t"*ind + lines[-1].strip() + "\n"
			outlines += [line]

	def handle_line_in_test(l):
		nonlocal outlines, state
		l = l.rstrip("\n")
		endswith_quote = l.endswith("'")
		if endswith_quote:
			l = l[:-1]

		if len(l.strip()):
			emit_statements(l)
		elif endswith_quote:
			# skip an empty line before test is done
			pass
		else:
			# add the empty line
			outlines += ["\n"]

		if endswith_quote:
			outlines += ["'\n"]
			state = "outside_test_expect"
			print("state now outside_test_expect")

	print("reading ", fname)
	with open(fname, 'r') as f:
		lines = f.readlines()
		state = "outside_test_expect"

		outlines = []
		for line in lines:
			print(state, line)
			if state == "outside_test_expect":
				if line == "test_expect_success \\\n":
					state = "expecting_test_title"
					print("state now expecting_test_title")
				elif line.startswith("test_expect_success") and line.endswith("' '\n"):
					# well formatted test header
					outlines += [line]
					state = "inside_test_expect"
					print("state now inside_test_expect")
				else:
					outlines += [line]
			elif state == "expecting_test_title":
				l = line.strip()
				ends_with_backslash = l.endswith("\\")
				if ends_with_backslash:
					l = l[:-1]
					# state = "expecting_test_body"
				if l.endswith("'"):
					l = l[:-1].strip()
				if l.startswith("'"):
					line = "test_expect_success " + l + " '\n"
					outlines += [line]
					if ends_with_backslash:
						state = "expecting_test_body"
						print("state now expecting_test_body")
					else:
						state = "inside_test_expect"
						print("state now inside_test_expect")
				else:
					print("what?")
					exit(1)
			elif state == "expecting_test_body":
				if line.strip().startswith("'"):
					ind = len(line) - len(line.lstrip())
					line = "\t"* ind + line.strip()[1:]
				else:
					print("expecting the test body after a quote sign?")
					exit(1)
				handle_line_in_test(line)
			elif state == "inside_test_expect":
				handle_line_in_test(line)
			else:
				print("what?")
				exit(1)

	# ~ print "writing ", fname,
	# ~ print outlines
	with open(fname, 'w') as f:
		f.write(''.join(outlines))
	# ~ print "done"

for n in sys.argv[1:]:
	print(n)
	applyformat(n)
