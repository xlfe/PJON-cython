from nose.tools import raises
import time
import pjon_cython as PJON

class LocalUDP(PJON.LocalUDP):
    def receive(self, data, length, packet_info):
        raise Exception("Not expecting any reply")

    def __init__(self, device_id):
        PJON.LocalUDP.__init__(self, device_id)

class GlobalUDP(PJON.GlobalUDP):
    def receive(self, data, length, packet_info):
        raise Exception("Not expecting any reply")

class ThroughSerial(PJON.ThroughSerial):
        def receive(self, data, length, packet_info):
            raise Exception("Not expecting any reply")

def test_gudp():
    "Test GlobalUDP, add_node and send_repeatedly"

    g = GlobalUDP(0)
    g.add_node(1,'10.0.0.1')
    g.send_repeatedly(10, b"1234", 10000000)
    g.send(1, b'HELLO')
    for i in range(10):
        g.loop()


def test_ludp():
    "Test LocalUDP and send_repeatedly"

    l = LocalUDP(0)
    l.send(1, b'HELLO')
    l.send_repeatedly(10, b"1234", 10000000)
    for i in range(10):
        l.loop()

def test_throughserial():
    "Test ThroughSerial and send_repeatedly"

    ts = ThroughSerial(44, b"/dev/null", 115200)
    ts.send_repeatedly(10, b"1234", 10000000)
    for i in range(10):
        ts.loop()


def test_constants():
    "Check that PJON constants are defined"
    assert PJON.PJON_ACK == 6
    assert PJON.PJON_NAK == 21
    assert PJON.PJON_BUSY == 666

    assert PJON.PJON_BROADCAST == 0
    assert PJON.PJON_FAIL == 65535
    assert PJON.PJON_TO_BE_SENT == 74



def connection_lost(add_to_max_attempts=0):
    l = LocalUDP(0)
    l.send(1, b'Never delivered')

    for i in range(l.get_max_attempts() + add_to_max_attempts):
        l.loop()
        time.sleep(PJON.LUDP_RESPONSE_TIMEOUT/1000000)

    l.loop()

@raises(PJON.PJON_Packets_Buffer_Full)
def test_ludp_raises_packet_buffer_full():
    "Check that we get PACKET_BUFFER_FULL error in LocalUDP"
    l = LocalUDP(0)
    for i in range(PJON.PJON_MAX_PACKETS + 1):
        l.send(1, b'blah')

@raises(PJON.PJON_Packets_Buffer_Full)
def test_gudp_raises_packet_buffer_full():
    "Check that we get PACKET_BUFFER_FULL error in GlobalUDP"
    g = GlobalUDP(0)
    for i in range(PJON.PJON_MAX_PACKETS + 1):
        g.send(1, b'blah')

@raises(PJON.PJON_Packets_Buffer_Full)
def test_ts_raises_packet_buffer_full():
    "Check that we get PACKET_BUFFER_FULL error in ThroughSerial"
    ts = ThroughSerial(44, b"/dev/null", 115200)
    for i in range(PJON.PJON_MAX_PACKETS + 1):
        ts.send(1, b'blah')



@raises(PJON.PJON_Connection_Lost)
def test_raises_connection_lost():
    "Check that we get CONNECTION_LOST error"
    connection_lost(1)

def test_doesnt_raise_conn_lost():
    "Check that we don't get CONNECTION_LOST error"
    connection_lost(-1)

@raises(PJON.PJON_Content_Too_Long)
def test_raises_content_too_long():
    "Check that we get CONTENT_TOO_LONG error"
    l = LocalUDP(10)
    ret = l.send(2, b'b'*(PJON.PJON_PACKET_MAX_LENGTH))

def test_doesnt_raise_content_too_long():
    "Check that we don't get CONTENT_TOO_LONG error"
    l=LocalUDP(0)
    l.send(1, b'b'*(PJON.PJON_PACKET_MAX_LENGTH-10))



cython_class_methods = lambda _: [func for func in dir(_) if callable(getattr(_, func)) and not func.startswith("__")]

def test_base_functions():
    """
    test that all classes share the same set of base functions
    """

    classes = {
        PJON.GlobalUDP : {'add_node'},
        PJON.LocalUDP: {} ,
        PJON.ThroughSerial : {}
    }

    func_list = set()

    for c in classes:

        c_methods = set(cython_class_methods(c)).difference(classes[c])
        func_list = func_list.union(c_methods)

    for c in classes:
        c_methods = set(cython_class_methods(c)).difference(classes[c])

        for method in func_list:
            if method not in c_methods:
                raise Exception('{} does not have {}'.format(c, method))

