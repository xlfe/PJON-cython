import pjon_cython as PJON

class GlobalUDP(PJON.GlobalUDP):

    def receive(self, data, length, packet_info):
        print ("Recv ({}): {}".format(length, data))
        print (packet_info)
        self.reply(b'P')

g = GlobalUDP(44)

while True:
    g.loop(timeout_us=1000)



