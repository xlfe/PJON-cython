import time
from python_pjon_pi import LocalUDP



def callback(test):
    print "CALLBACK!!"


l= LocalUDP(44, callback)
print l.device_id()

while True:
    l.loop()
    time.sleep(0.1)

