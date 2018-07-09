from python_pjon_pi import setup,LocalUDP



def callback(test):
    print "CALLBACK!!"

print setup(callback, 10)

l= LocalUDP(100)
print l.get_id()
