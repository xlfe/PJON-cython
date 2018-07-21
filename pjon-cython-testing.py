import pjon_cython as PJON

if True:
    class GlobalUDP(PJON.GlobalUDP):

        def receive(self, data, length, packet_info):
            print ("Recv ({}): {}".format(length, data))
            print (packet_info)
            self.reply(b'P')

    g = GlobalUDP(44)
    g.add_node(123,'192.168.22.10',1234)
    g.send(123, b'HELO')

    while True:
        g.loop()



if True:

    #ThroughSerial Example
    # Make sure you set self.bus.set_synchronous_acknowledge(false) on the other side

    class ThroughSerial(PJON.ThroughSerial):

        def receive(self, data, length, packet_info):
            if data.startswith(b'H'):
                print ("Recv ({}): {} - REPLYING".format(length, data))
                self.reply(b'BONZA')
            else:
                print ("Recv ({}): {}".format(length, data))
            print ('')

    ts = ThroughSerial(44, b"<YOUR SERIAL DEVICE HERE>", 115200)

    while True:
        ts.loop()
