import cython
from libcpp cimport bool as bool_t

ctypedef unsigned char uint8_t
ctypedef unsigned short uint16_t
ctypedef unsigned int uint32_t

ctypedef int PJON_SERIAL_TYPE

ctypedef void* PJON_Receiver
ctypedef void* PJON_Error

cdef extern from "interfaces/LINUX/PJON_LINUX_Interface.h":
    int serialOpen (const char *device, const int baud)

cdef extern from "PJON.h":

    const uint8_t PJON_NOT_ASSIGNED
    const uint8_t  PJON_NO_HEADER
    const uint16_t GUDP_DEFAULT_PORT
    const uint8_t PJON_CONNECTION_LOST
    const uint8_t PJON_PACKETS_BUFFER_FULL
    const uint8_t PJON_CONTENT_TOO_LONG

    const uint8_t PJON_CONNECTION_LOST
    const uint8_t PJON_PACKETS_BUFFER_FULL
    const uint8_t PJON_CONTENT_TOO_LONG
    const uint8_t PJON_ID_ACQUISITION_FAIL
    const uint8_t PJON_DEVICES_BUFFER_FULL

    const uint16_t _PJON_ACK "PJON_ACK"
    const uint16_t _PJON_NAK "PJON_NAK"
    const uint16_t _PJON_BUSY "PJON_BUSY"
    const uint16_t _PJON_FAIL "PJON_FAIL"
    const uint16_t _PJON_BROADCAST "PJON_BROADCAST"
    const uint16_t _PJON_TO_BE_SENT "PJON_TO_BE_SENT"

    const uint16_t _PJON_MAX_PACKETS "PJON_MAX_PACKETS"
    const uint16_t _PJON_PACKET_MAX_LENGTH "PJON_PACKET_MAX_LENGTH"
    const uint32_t _LUDP_RESPONSE_TIMEOUT "LUDP_RESPONSE_TIMEOUT"

    cdef struct PJON_Packet_Info:
        uint8_t header
        uint16_t id
        uint8_t receiver_id
        uint8_t receiver_bus_id[4]
        uint8_t sender_id
        uint8_t sender_bus_id[4]
        uint16_t port
        void *custom_pointer

    cdef cppclass _localudp "LocalUDP":
        uint8_t get_max_attempts()
        bool_t can_start()

    cdef cppclass _globaludp "GlobalUDP":
        uint16_t add_node(uint8_t remote_id, const uint8_t remote_ip[], uint16_t port_number)
        uint8_t get_max_attempts()
        bool_t can_start()

    cdef cppclass _throughserial "ThroughSerial":
        void set_serial(PJON_SERIAL_TYPE serial_port)
        void set_baud_rate(uint32_t baud)
        uint8_t get_max_attempts()
        bool_t can_start()

    cdef cppclass PJON[T]:
        T strategy
        PJON()
        void set_id(uint8_t id)
        uint8_t device_id()
        void begin()
        void set_error(PJON_Error e)
        void set_receiver(PJON_Receiver r)
        uint16_t update() except *
        uint16_t receive() except *
        # void set_synchronous_acknowledge(uint8_t state)
        uint16_t receive(uint32_t duration) except *
        void set_custom_pointer(void *pointer)
        uint16_t get_packets_count(uint8_t device_id)
        uint16_t send(uint8_t id, const char *string, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port) except *
        uint16_t send_repeatedly(uint8_t id, const char *string, uint16_t length, uint32_t timing, uint8_t  header, uint16_t p_id, uint16_t requested_port) except *
        uint16_t reply(const char *packet, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port) except *

PJON_BROADCAST = _PJON_BROADCAST
PJON_ACK = _PJON_ACK
PJON_NAK = _PJON_NAK
PJON_BUSY = _PJON_BUSY
PJON_FAIL = _PJON_FAIL
PJON_TO_BE_SENT = _PJON_TO_BE_SENT

PJON_MAX_PACKETS = _PJON_MAX_PACKETS
LUDP_RESPONSE_TIMEOUT = _LUDP_RESPONSE_TIMEOUT
PJON_PACKET_MAX_LENGTH = _PJON_PACKET_MAX_LENGTH

class PJON_Connection_Lost(BaseException):
    pass

class PJON_Packets_Buffer_Full(BaseException):
    pass

class PJON_Content_Too_Long(BaseException):
    pass

class PJON_Id_Acquisition_Fail(BaseException):
    pass

class PJON_Devices_Buffer_Full(BaseException):
    pass


cdef void error_handler(uint8_t code, uint16_t data, void *custom_pointer) except *:

    # raise Exception('Code: {} Data: {}'.format(code, data))

    if code == PJON_CONNECTION_LOST:
        raise PJON_Connection_Lost()

    if code == PJON_PACKETS_BUFFER_FULL:
        raise PJON_Packets_Buffer_Full()

    if code == PJON_CONTENT_TOO_LONG:
        raise PJON_Content_Too_Long()

    if code == PJON_DEVICES_BUFFER_FULL:
        raise PJON_Devices_Buffer_Full()

    if code == PJON_ID_ACQUISITION_FAIL:
        raise PJON_Id_Acquisition_Fail()

    raise Exception("PJON Error Code Unknown")


cdef object make_packet_info_dict(const PJON_Packet_Info &_pi):
    return dict(
        header=_pi.header,
        id=_pi.id,
        receiver_id = _pi.receiver_id,
        receiver_bus_id =_pi.receiver_bus_id,
        sender_id = _pi.sender_id,
        sender_bus_id = _pi.sender_bus_id,
        port = _pi.port
    )

cdef void _globaludp_receiver(uint8_t *payload, uint16_t length, const PJON_Packet_Info &_pi):
    cdef GlobalUDP self = <object> _pi.custom_pointer
    self._receive(payload, length, make_packet_info_dict(_pi))


cdef class GlobalUDP:
    """
    GlobalUDP Strategy - you must create a new class that inherits this one and add a receive function
    """
    cdef PJON[_globaludp] *bus

    def __cinit__(self):
        self.bus = new PJON[_globaludp]()
        self.bus.set_custom_pointer(<void*> self)
        self.bus.set_receiver(&_globaludp_receiver)
        self.bus.set_error(&error_handler)
        # self.bus.set_asynchronous_acknowledge(1)

    def __dealloc__(self):
        del self.bus

    def __init__(self, device_id):
        self.bus.set_id(device_id)
        self.bus.begin()
        assert self.bus.strategy.can_start()

    def receive(self, payload, length, packet_info):
        raise NotImplementedError()

    def _receive(self, payload, length, packet_info):
        self.receive(payload[:length], length, packet_info)

    def device_id(self):
        return self.bus.device_id()

    def get_max_attempts(self):
        return self.bus.strategy.get_max_attempts()

    def get_packets_count(self, device_id = PJON_NOT_ASSIGNED):
        return self.bus.get_packets_count(device_id)

    def loop(self, timeout_us=None):
        """
        :param self:
        :param timeout_us: optional parameter - timeout in uS on receive() call
        :return: (packets_to_be_sent, return from receive (one of PJON_FAIL, PJON_BUSY, PJON_NAK)
        """
        to_be_sent = self.bus.update()
        if timeout_us is not None:
            return to_be_sent, self.bus.receive(timeout_us)
        else:
            return to_be_sent, self.bus.receive()

    def send(self, device_id, data):
        return self.bus.send(device_id, data, len(data), PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def reply(self, data):
        return self.bus.reply(data, len(data), PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def send_repeatedly(self, device_id, data, timing):
        return self.bus.send_repeatedly(device_id, data, len(data), timing, PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def add_node(self, device_id, ip, port = GUDP_DEFAULT_PORT):
        ip_ints = bytearray(map(lambda _:int(_),ip.split('.')))
        self.bus.strategy.add_node(device_id, ip_ints, port)

    def send_repeatedly(self, device_id, data, timing):
        self.bus.send_repeatedly(device_id, data, len(data), timing, PJON_NO_HEADER, 0, PJON_BROADCAST)




cdef void _localudp_receiver(uint8_t *payload, uint16_t length, const PJON_Packet_Info &_pi):
    cdef LocalUDP self = <object> _pi.custom_pointer
    self._receive(payload, length, make_packet_info_dict(_pi))

cdef class LocalUDP:
    """
    LocalUDP Strategy - you must create a new class that inherits this one and add a receive function
    """
    cdef PJON[_localudp] *bus

    def __cinit__(self):
        self.bus = new PJON[_localudp]()
        self.bus.set_custom_pointer(<void*> self)
        self.bus.set_receiver(&_localudp_receiver)
        self.bus.set_error(&error_handler)

    def __dealloc__(self):
        del self.bus

    def __init__(self, device_id):
        self.bus.set_id(device_id)
        self.bus.begin()
        assert self.bus.strategy.can_start()

    def receive(self, payload, length, packet_info):
        raise NotImplementedError()

    def _receive(self, payload, length, packet_info):
        self.receive(payload[:length], length, packet_info)

    def device_id(self):
        return self.bus.device_id()

    def get_packets_count(self, device_id = PJON_NOT_ASSIGNED):
        return self.bus.get_packets_count(device_id)

    def get_max_attempts(self):
        return self.bus.strategy.get_max_attempts()

    def loop(self, timeout_us=None):
        """
        :param self:
        :param timeout_us: optional parameter - timeout in uS on receive() call
        :return: (packets_to_be_sent, return from receive (one of PJON_FAIL, PJON_BUSY, PJON_NAK)
        """
        to_be_sent = self.bus.update()
        if timeout_us is not None:
            return to_be_sent, self.bus.receive(timeout_us)
        else:
            return to_be_sent, self.bus.receive()

    def send(self, device_id, data):
        return self.bus.send(device_id, data, len(data), PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def reply(self, data):
        return self.bus.reply(data, len(data), PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def send_repeatedly(self, device_id, data, timing):
        return self.bus.send_repeatedly(device_id, data, len(data), timing, PJON_NO_HEADER, 0, _PJON_BROADCAST)



cdef void _through_serial_receiver(uint8_t *payload, uint16_t length, const PJON_Packet_Info &_pi):
    cdef ThroughSerial self = <object> _pi.custom_pointer
    self._receive(payload, length, make_packet_info_dict(_pi))

cdef class ThroughSerial:
    """
    ThroughSerial Strategy - you must create a new class that inherits this one and add a receive function
    """
    cdef PJON[_throughserial] *bus

    def __cinit__(self):

        self.bus = new PJON[_throughserial]()
        self.bus.set_custom_pointer(<void*> self)
        self.bus.set_receiver(&_through_serial_receiver)
        self.bus.set_error(&error_handler)

    def __dealloc__(self):
        del self.bus

    def __init__(self, device_id, port, baud_rate):
        self.bus.set_id(device_id)
        cdef int s = serialOpen(port, baud_rate)

        if(int(s) < 0):
            raise Exception("Couldn't open serial port")

        self.bus.strategy.set_serial(s)
        # self.bus.set_synchronous_acknowledge(0)
        self.bus.strategy.set_baud_rate(baud_rate)
        self.bus.begin()
        assert self.bus.strategy.can_start()

    def receive(self, payload, length, packet_info):
        raise NotImplementedError()

    def get_max_attempts(self):
        return self.bus.strategy.get_max_attempts()

    def _receive(self, payload, length, packet_info):
        self.receive(payload[:length], length, packet_info)

    def device_id(self):
        return self.bus.device_id()

    def get_packets_count(self, device_id = PJON_NOT_ASSIGNED):
        return self.bus.get_packets_count(device_id)

    def loop(self, timeout_us=None):
        """
        :param self:
        :param timeout_us: optional parameter - timeout in uS on receive() call
        :return: (packets_to_be_sent, return from receive (one of PJON_FAIL, PJON_BUSY, PJON_NAK)
        """
        to_be_sent = self.bus.update()
        if timeout_us is not None:
            return to_be_sent, self.bus.receive(timeout_us)
        else:
            return to_be_sent, self.bus.receive()

    def send(self, device_id, data):
        return self.bus.send(device_id, data, len(data), PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def reply(self, data):
        return self.bus.reply(data, len(data), PJON_NO_HEADER, 0, _PJON_BROADCAST)

    def send_repeatedly(self, device_id, data, timing):
        return self.bus.send_repeatedly(device_id, data, len(data), timing, PJON_NO_HEADER, 0, _PJON_BROADCAST)


