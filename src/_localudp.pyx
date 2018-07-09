# distutils: language = c++
# distutils: sources = pjon_wrapper.cpp

import cython
from cpython.ref cimport PyObject

ctypedef   signed int  int8_t
ctypedef   signed int  int16_t
ctypedef   signed int  int32_t
ctypedef   signed int  int64_t
ctypedef unsigned int uint8_t
ctypedef unsigned int uint16_t
ctypedef unsigned int uint32_t
ctypedef unsigned int uint64_t


# cdef extern from "PJON.h":
#     cdef cppclass PJON[LocalUDP]:
#         PJON()
#         begin()

# cdef struct PJON_Packet_Info:
#     uint8_t header
#     uint16_t id
#     uint8_t receiver_id
#     uint8_t receiver_bus_id[4]
#     uint8_t sender_id
#     uint8_t sender_bus_id[4]
#     uint16_t port
#     void *custom_pointer
#
# cdef object f
#
# cdef void receiver_function(uint8_t *payload, uint16_t length, const PJON_Packet_Info &packet_info):
#     global f
#     result_from_function = (<object>f)(<char*>payload, length)
#

cdef extern from "pjon_wrapper.h":
    cdef cppclass PJONLocalUDP:
        PJONLocalUDP(uint8_t id) except +
        int GetID()
        int getArea()
        void getSize(int* width, int* height)
        void move(int, int)

cdef class LocalUDP:
    cdef PJONLocalUDP *bus
    def __cinit__(self, id):
        self.bus = new PJONLocalUDP(id)

    def __dealloc__(self):
        del self.bus

    def get_id(self):
        return self.bus.GetID()


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