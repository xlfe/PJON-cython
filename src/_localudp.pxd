
cdef extern from "c-pjon/LocalUDP.cpp":
    pass

cdef extern from "c-pjon/LocalUDP.h":
    int create_bus(unsigned short id)
    void loop()
    void set_receiver()

