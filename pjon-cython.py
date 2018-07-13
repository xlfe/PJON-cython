import time
from _pjon_cython import LocalUdp



def callback(test, length):
    print "CALLBACK!!"
    print test
    print length


l= LocalUdp(99, callback)
print l.device_id()

l.loop()
print l.get_packets_count()

l.send(44, 'Ptest')
try:
    while True:
        l.loop()
finally:
    print l.get_packets_count()


# g = GlobalUDP(45, callback)
# print g.device_id()
# g.loop()

