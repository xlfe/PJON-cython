# distutils: language = c++

import cython
from cpython.ref cimport PyObject

ctypedef unsigned char uint8_t
ctypedef unsigned short uint16_t

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


#


cdef extern from "PJON.h":
    struct PJON_Packet_Info:
        pass
    cdef cppclass PJON[LocalUDP]:
        PJON(uint8_t id)
        void begin()
        uint16_t update()
        uint16_t receive()
        uint8_t device_id()
        void set_receiver(PJON_Receiver r)

cdef object f
cdef void c_receiver_function(uint8_t *payload, uint16_t length, const PJON_Packet_Info &packet_info):
    global f
    result_from_function = (<object>f)(<char*>payload, length)

cdef class LocalUDP:
    cdef PJON *bus
    def __cinit__(self, id, receiver_function):
        self.bus = new PJON(id)
        f = receiver_function
        self.bus.set_receiver(&c_receiver_function)
        self.bus.begin()

    def __dealloc__(self):
        del self.bus

    def device_id(self):
        return self.bus.device_id()

    def loop(self):
        self.bus.receive()
        self.bus.update()



def setup(pythonf, id):
    global f
    f = pythonf
    return 'test'
    # setup_c(id)

# cdef int create_bus(unsigned short id, void* rf) {
# bus->set_receiver(rf);
# bus->begin();

# c_function( <cfunction> cfunction_cb,
# double a,
#        double b,
#               double c,
# <void *> args )