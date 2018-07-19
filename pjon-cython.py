from _pjon_cython import GlobalUdp

def callback(o, test, length):
    print "Recv (" + str(length) + "): " +  test[:length]
    o.reply("P")

g = GlobalUdp(44, callback)

while True:
    g.loop(10)



