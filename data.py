#!/usr/bin/python

import subprocess
import os
from datetime import datetime
from datetime import timedelta

gitrepo = os.getenv("HOME") + "/git"
gitml =   os.getenv("HOME") + "/git-ml"

sep="MYSEPARATOR"

def strip_subject_line(s):
	if s.startswith("[PATCH"):
		p = s.find("]")+2  # account for } and ws after.
		s = s[p:]
	#strip off [PATCH ..]
	# strip of "RE: " ?
	return s

def run_log_in(where, args):
	cmd = ['git', '--no-pager', '-C', where,  'log',  '--no-merges', ] + args + [ '--date=iso', '--format=%ad' +sep + '%an' + sep + '%s']
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
	r = {}
	while p.returncode is None:
		for line in p.communicate()[0].split("\n"):
			if len(line) < 1:
				continue
			try:
				(d, a, s) = line.split(sep)
				ss = strip_subject_line(s)
				if not ss in r:
					r[ss] = []
				r[ss] += [(d, a)]
			except Exception as e:
				print "Problem with line X",line, "X"
	return r

print "checking repo"
data_in_repo = run_log_in(gitrepo, ['--since=2011']);
print "reading ml"
data_in_ml = run_log_in(gitml, []);

nonuniquecounter=0
dates = []
mlmatches = {}

for item in data_in_repo:
	if len(data_in_repo[item]) != 1:
		nonuniquecounter = nonuniquecounter+1
	else:
		if not item in data_in_ml:
			m = 0
		else: 
			m = len(data_in_ml[item])
			
		if not m in mlmatches:
			mlmatches[m] = 0
		
		mlmatches[m] = mlmatches[m] + 1
		if m == 0:
			continue
			
		# find the earliest appearance on the mailing list
		youngest = datetime.now()
		for i in data_in_ml[item]:
			d = datetime.strptime(i[0][:19], '%Y-%m-%d %H:%M:%S')
			if d < youngest:
				youngest = d
		applied = datetime.strptime(data_in_repo[item][0][0][:19], '%Y-%m-%d %H:%M:%S')
		t = (applied - youngest)
		print applied, t
		
print "non-unique subject lines", nonuniquecounter

for x in mlmatches:
	print x, mlmatches[x]
