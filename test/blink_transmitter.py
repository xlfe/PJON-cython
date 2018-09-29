import pjon_cython as PJON


class ThroughSerial(PJON.ThroughSerial):

    def receive(self, data, length, packet_info):
        print data


ts = ThroughSerial(45, '/dev/cu.usbmodem1411', 9600)
ts.send_repeatedly(44, b"B", 1000000)
while True:
    ts.loop()


