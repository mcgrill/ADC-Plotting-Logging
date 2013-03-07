import serial
import signal
import sys

def signal_handler(signal, frame):
    m2.close()
    sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)


m2 = serial.Serial('/dev/tty.usbmodem411', 9600)	# A new serial port is opened @ 9600 baud and named 'm2'
m2.flushInput()			# The input buffer is cleared, in case anything is leftover

while 1:

	#m2.write('1')	# Signal to the m2 that we want data!
	#print m2.read()

	user_input = raw_input('Write to device? \n(1) Motor 1\n(2) Motor 2\nInput: ')
	if user_input == '1':
		m2.write('1')
		print m2.read()
	#elif user_input == '2':
	#	m2.write('2')
		#print m2.read()
