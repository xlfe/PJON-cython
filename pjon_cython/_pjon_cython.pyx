import cython
from libcpp cimport bool as bool_t
from os import close

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
    const uint16_t LUDP_DEFAULT_PORT

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
        void set_port(uint16_t port)

    cdef cppclass _globaludp "GlobalUDP":
        uint16_t add_node(uint8_t remote_id, const uint8_t remote_ip[], uint16_t port_number)
        void set_port(uint16_t port)
        void set_autoregistration(bool_t enabled)

    cdef cppclass _throughserial "ThroughSerial":
        void set_serial(PJON_SERIAL_TYPE serial_port)
        void set_baud_rate(uint32_t baud)

    cdef cppclass _throughserialasync "ThroughSerialAsync":
        void set_serial(PJON_SERIAL_TYPE serial_port)
        void set_baud_rate(uint32_t baud)

    cdef cppclass StrategyLinkBase:
        pass

    cdef cppclass _any "Any":
        pass

    cdef cppclass StrategyLink[T]:
        T strategy
        uint8_t get_max_attempts()
        void set_link(StrategyLinkBase *strategy_link)
        bool_t can_start()

    cdef cppclass PJON[T]:
        StrategyLink strategy
        PJON()
        void set_id(uint8_t id)
        void set_packet_id(bool_t state)
        void set_crc_32(bool_t state)
        uint8_t device_id()
        uint8_t packet_overhead(uint8_t  header)
        void set_synchronous_acknowledge(bool_t state)
        void set_asynchronous_acknowledge(bool_t state)
        void include_sender_info(bool_t state)
        void begin()
        void set_error(PJON_Error e)
        void set_receiver(PJON_Receiver r)
        uint16_t update() except *
        uint16_t receive() except *
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

class PJON_Unable_To_Create_Bus(BaseException):
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

cdef void _pjon_receiver(uint8_t *payload, uint16_t length, const PJON_Packet_Info &_pi):
    cdef PJONBUS self = <object> _pi.custom_pointer
    self.receive(<bytes>payload[:length], length, make_packet_info_dict(_pi))


cdef class PJONBUS:
    cdef PJON[_any] *bus

    def __cinit__(self):
        self.bus = new PJON[_any]()
        self.bus.set_custom_pointer(<void*> self)
        self.bus.set_receiver(&_pjon_receiver)
        self.bus.set_error(&error_handler)

    def __dealloc__(self):
        del self.bus

    def packet_overhead(self):
        return self.bus.packet_overhead(PJON_NO_HEADER)

    def set_synchronous_acknowledge(self, enabled):
        "Acknowledge receipt of packets"
        self.bus.set_synchronous_acknowledge(1 if enabled else 0)
        return self

    def set_asynchronous_acknowledge(self, enabled):
        "sync or async ack"
        self.bus.set_asynchronous_acknowledge(1 if enabled else 0)
        return self

    def include_sender_info(self, enabled):
        self.bus.include_sender_info(1 if enabled else 0)
        return self

    def set_crc_32(self, enabled):
        self.bus.set_crc_32(1 if enabled else 0)
        return self

    def set_packet_id(self, enabled):
        self.bus.set_packet_id(1 if enabled else 0)
        return self

    def can_start(self):
        return self.bus.strategy.can_start()

    def receive(self, payload, length, packet_info):
        raise NotImplementedError()

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


cdef class GlobalUDP(PJONBUS):
    cdef StrategyLink[_globaludp] * link

    def __cinit__(self):
        self.link = new StrategyLink[_globaludp]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        del self.link

    def __init__(self, device_id, port=GUDP_DEFAULT_PORT):
        self.bus.set_id(device_id)
        self.link.strategy.set_port(port)
        self.bus.begin()

    def can_start(self):
        return self.bus.strategy.can_start()

    def set_autoregistration(self, enabled):
        self.link.strategy.set_autoregistration(1 if enabled else 0)
        return self

    def add_node(self, device_id, ip, port = GUDP_DEFAULT_PORT):
        ip_ints = bytearray(map(lambda _:int(_),ip.split('.')))
        self.link.strategy.add_node(device_id, ip_ints, port)


cdef class LocalUDP(PJONBUS):
    cdef StrategyLink[_localudp] * link

    def __cinit__(self):
        self.link = new StrategyLink[_localudp]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        del self.link

    def __init__(self, device_id, port=LUDP_DEFAULT_PORT):
        self.bus.set_id(device_id)
        self.link.strategy.set_port(port)
        self.bus.begin()
        if not self.link.can_start():
            raise PJON_Unable_To_Create_Bus()

cdef class ThroughSerial(PJONBUS):
    cdef StrategyLink[_throughserial] *link
    cdef int s

    def __cinit__(self):
        self.link = new StrategyLink[_throughserial]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        if self.s > 0:
            close(self.s)

    def _fd(self):
        return self.s

    def __init__(self, device_id, port, baud_rate):
        self.bus.set_id(device_id)
        self.s = serialOpen(port, baud_rate)

        if(int(self.s) < 0):
            raise PJON_Unable_To_Create_Bus('Unable to open serial port')

        self.link.strategy.set_serial(self.s)
        self.link.strategy.set_baud_rate(baud_rate)
        self.bus.begin()

cdef class ThroughSerialAsync(PJONBUS):
    cdef StrategyLink[_throughserialasync] *link
    cdef int s

    def __cinit__(self):
        self.link = new StrategyLink[_throughserialasync]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        if self.s > 0:
            close(self.s)

    def _fd(self):
        return self.s

    def __init__(self, device_id, port, baud_rate, port_timeout_s=10):
        self.bus.set_id(device_id)
        self.s = serialOpen(port, baud_rate)

        if(int(self.s) < 0):
            raise PJON_Unable_To_Create_Bus('Unable to open serial port')

        self.link.strategy.set_serial(self.s)
        self.link.strategy.set_baud_rate(baud_rate)
        self.bus.begin()

