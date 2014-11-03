#!/usr/bin/python

import serial
import subprocess

ComPort = "/dev/ttyUSB0"

ser = serial.Serial(ComPort, 9600)

def getNodeByAddress(address):
	#print(address);
	node = [ "",

	"28-000005fdb95b", #1
	"28-000005fe0b1e", #2
	"28-000005fe350a", #3
	"28-000005fee542", #4
	"28-000005ff1276", #5
	"28-000005feac32", #6
	"28-000005fee49b", #7
			"28-B215FE05000088", #"28-000005fe15b2",
			"28-DAB7FE0500005A", #"28-000005feb7da",
			"28-97ABFE05000038", #"28-000005feab97",
			"28-2432FE05000022", #"28-000005fe3224"
	"28-000005fd6246", #12
	"28-000005fd6706", #13
	"28-000005fe3e94", #14
	"28-000005ff4e9f", #15
	"28-000005fdd11e", #16
	"28-000005ff431a", #17
	"28-000005ff8c54", #18
	"28-000005ff5bf6", #19
	"28-000005ff107c"];#20
	for i in range(21):
		if ( node[i].lower() == address.lower() ):
			return i;
	return None;


while True:
	line = ser.readline();
	data = line.rstrip('\r\n').split(',');
	if (len(data) == 4):
		# only complete lines
		node_id = (getNodeByAddress(data[0]));
		temp = float(data[3].split('=')[1]);
		temp_str = "{:.2f}".format(temp)	# float to string
		print(node_id, temp);
		url = 'http://datenkrake.dyn.club.entropia.de:8086/db/temperatur/series?u=USERNAME&p=PASSWORD';

		# schoen ist anderes
		values = '[{"name":"node'+ str(node_id) +'", "columns":["value"], "points":[['+ temp_str +']]}]'; 
		subprocess.call(['curl', '-X', 'POST', '-d', values , url]);
