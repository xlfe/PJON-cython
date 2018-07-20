import cython

ctypedef unsigned char uint8_t
ctypedef unsigned short uint16_t
ctypedef unsigned int uint32_t

ctypedef void* PJON_Receiver

cdef extern from "PJON.h":

    const uint8_t PJON_NOT_ASSIGNED
    const uint8_t  PJON_NO_HEADER
    const uint16_t PJON_BROADCAST

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
        pass
    cdef cppclass _globaludp "GlobalUDP":
        pass
    cdef cppclass _throughserial "ThroughSerial":
        pass

    cdef cppclass PJON[T]:
        PJON(uint8_t device_id)
        void begin()
        uint16_t reply(const char *packet, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port)
        uint16_t update()
        uint16_t receive()
        uint16_t receive(uint32_t duration)
        uint8_t device_id()
        void set_custom_pointer(void *pointer)
        uint16_t get_packets_count(uint8_t device_id)
        void set_receiver(PJON_Receiver r)
        uint16_t send(uint8_t id, const char *string, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port)

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

    def __cinit__(self, uint8_t device_id):
        self.bus = new PJON[_globaludp](device_id)
        self.bus.set_custom_pointer(<void*> self)
        self.bus.set_receiver(&_globaludp_receiver)
        self.bus.begin()

    def receive(self, payload, length, packet_info):
        raise NotImplementedError()

    def _receive(self, payload, length, packet_info):
        self.receive(payload[:length], length, packet_info)

    def device_id(self):
        return self.bus.device_id()

    def get_packets_count(self, device_id = PJON_NOT_ASSIGNED):
        return self.bus.get_packets_count(device_id)

    def loop(self, timeout_us=None):
        self.bus.update()
        if timeout_us is not None:
            self.bus.receive(timeout_us)
        else:
            self.bus.receive()

    def send(self, device_id, data):
        self.bus.send(device_id, data, len(data), PJON_NO_HEADER, 0, PJON_BROADCAST)

    def reply(self, data):
        self.bus.reply(data, len(data), PJON_NO_HEADER, 0, PJON_BROADCAST)



