#!/usr/bin/python

import subprocess
import os
from datetime import datetime
from datetime import timedelta


import matplotlib.pyplot as plt
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

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
	cmd = ['git', '--no-pager', '-C', where,  'log',  '--no-merges', ] + args + [ '--date=iso', '--format=%cd'+sep+'%ad' +sep + '%an' + sep + '%s']
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
	r = {}
	while p.returncode is None:
		for line in p.communicate()[0].split("\n"):
			if len(line) < 1:
				continue
			try:
				(cd, ad, a, s) = line.split(sep)
				ss = strip_subject_line(s)
				if not ss in r:
					r[ss] = []
				r[ss] += [(cd, ad, a)]
			except Exception as e:
				print "Problem with line X",line, "X"
	return r

print "checking repo"
data_in_repo = run_log_in(gitrepo, ['--since=2005']);
print "reading ml"
data_in_ml = run_log_in(gitml, []);

graphx={}

def get_slot(at):
	m = ((at.month + 2) / 3)  * 3
	return datetime(at.year,m, 1)

def add_to_slot(applied_time, timedelta):
	x = get_slot(applied_time)
	y = timedelta

	if not x in graphx:
		graphx[x] = []
	graphx[x] += [y]

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
			# use author date!
			d = datetime.strptime(i[1][:19], '%Y-%m-%d %H:%M:%S')
			if d < youngest:
				youngest = d

		# committer date!
		applied = datetime.strptime(data_in_repo[item][0][0][:19], '%Y-%m-%d %H:%M:%S')
		t = (applied - youngest)

		add_to_slot(applied, t)

print "non-unique subject lines", nonuniquecounter, "ignored for further analysis"
print "for reference there are", len(data_in_repo) , " in the repo dataset"
print "and", len(data_in_ml), "in the ml data set"
print
print "occurrences on the mailing list, by commits"
print
for x in mlmatches:
	print x, mlmatches[x]

print "now plotting a graph"

def percentile(lst, p):
	as_days = [x.total_seconds() / 86400.0 for x in lst]
	idx = int((0.01 * p) * len(as_days))
	return sorted(as_days)[idx]

x = sorted(graphx.keys())
y1 = range(len(graphx))
y2 = range(len(graphx))
y3 = range(len(graphx))
for i, xx in enumerate(x):
	y1[i] = percentile(graphx[xx], 50)
	y2[i] = percentile(graphx[xx], 70)
	y3[i] = percentile(graphx[xx], 90)
l1 = plt.plot_date(x, y1)
l2 = plt.plot_date(x, y2,  color = "yellow")
l3 = plt.plot_date(x, y3, color = "red")

plt.title("date difference between first hit on ml and commit date in git.git")
plt.ylabel("days")
plt.legend((l1[0], l2[0], l3[0]), ('50 pctl', '70 pctl', '90 pctl'))
plt.show()

