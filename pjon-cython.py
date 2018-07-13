import time
from _pjon_cython import LocalUDP, GlobalUDP



def callback(test):
    print "CALLBACK!!"


l= LocalUDP(44, callback)
print l.device_id()

l.loop()
print l.get_packets_count()


g = GlobalUDP(45, callback)
print g.device_id()
g.loop()

