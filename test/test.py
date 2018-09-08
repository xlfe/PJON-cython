import pjon_cython as PJON

def test_gudp():

    class GlobalUDP(PJON.GlobalUDP):

        def receive(self, data, length, packet_info):
            raise Exception("Not expecting any reply")

    g = GlobalUDP(0)
    g.add_node(1,'10.0.0.1')
    g.send_repeatedly(10, b"1234", 10000000)
    g.send(1, b'HELLO')
    for i in range(10):
        g.loop()


def test_ludp():

    class LocalUDP(PJON.LocalUDP):

        def receive(self, data, length, packet_info):
            raise Exception("Not expecting any reply")

    l = LocalUDP(0)
    l.send(1, b'HELLO')
    l.send_repeatedly(10, b"1234", 10000000)
    for i in range(10):
        l.loop()

def test_throughserial():

    class ThroughSerial(PJON.ThroughSerial):

        def receive(self, data, length, packet_info):
            raise Exception("Not expecting any reply")

    ts = ThroughSerial(44, b"/dev/null", 115200)
    ts.send_repeatedly(10, b"1234", 10000000)
    for i in range(10):
        ts.loop()

