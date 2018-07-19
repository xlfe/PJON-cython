import cython
from cpython.ref cimport PyObject

ctypedef unsigned char uint8_t
ctypedef unsigned short uint16_t
ctypedef unsigned int uint32_t

# cdef struct PJON_Packet_Info:
#     uint8_t header
#     uint16_t id
#     uint8_t receiver_id
#     uint8_t receiver_bus_id[4]
#     uint8_t sender_id
#     uint8_t sender_bus_id[4]
#     uint16_t port
#     void *custom_pointer

ctypedef void* PJON_Receiver
    # uint8_t *payload
    # uint16_t length
    # const PJON_Packet_Info &packet_info

cdef extern from "PJON.h":

    const uint8_t PJON_NOT_ASSIGNED
    const uint8_t  PJON_NO_HEADER
    const uint16_t PJON_BROADCAST

    struct PJON_Packet_Info:
        pass
    cdef cppclass LocalUDP:
        pass
    cdef cppclass GlobalUDP:
        pass
    cdef cppclass ThroughSerial:
        pass

    cdef cppclass PJON[T]:
        PJON(uint8_t device_id)
        void begin()
        uint16_t reply(const char *packet, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port)
        uint16_t update()
        uint16_t receive()
        uint16_t receive(uint32_t duration)
        uint8_t device_id()
        uint16_t get_packets_count(uint8_t device_id)
        void set_receiver(PJON_Receiver r)
        uint16_t send(uint8_t id, const char *string, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port)



cdef object gudp_f
cdef object gudp_o
cdef void gudp_receiver_function(uint8_t *payload, uint16_t length, const PJON_Packet_Info &packet_info):
    global gudp_o
    result_from_function = gudp_f(<object>gudp_o, <char*>payload, length)

cdef class GlobalUdp:
    cdef PJON[GlobalUDP] *bus

    def __cinit__(self, uint8_t device_id, object callback):
        global gudp_f
        global gudp_o
        gudp_o = self
        gudp_f = callback
        self.bus = new PJON[GlobalUDP](device_id)
        self.bus.set_receiver(&gudp_receiver_function)
        self.bus.begin()

    def device_id(self):
        return self.bus.device_id()

    def get_packets_count(self, device_id = PJON_NOT_ASSIGNED):
        return self.bus.get_packets_count(device_id)

    def loop(self, timeout_ms=None):
        self.bus.update()
        if timeout_ms is not None:
            self.bus.receive(timeout_ms)
        else:
            self.bus.receive()

    def send(self, device_id, data):
        self.bus.send(device_id, data, len(data), PJON_NO_HEADER, 0, PJON_BROADCAST)

    def reply(self, data):
        self.bus.reply(data, len(data), PJON_NO_HEADER, 0, PJON_BROADCAST)



