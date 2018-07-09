#include "pjon_wrapper.h"

#define PJON_INCLUDE_LUDP 1
#define LINUX 1

#include <PJON.h>


// Default constructor
PJONLocalUDP::PJONLocalUDP(unsigned short id) {
    PJON <LocalUDP> *bus = new PJON<LocalUDP>(id);

    this->bus = bus;

}

int PJONLocalUDP::GetID() {

    ((PJON<LocalUDP> * )this->bus)->begin();
    return ((PJON<LocalUDP> * )this->bus)->device_id();
}

// Destructor
PJONLocalUDP::~PJONLocalUDP() {}

// Return the area of the rectangle
int PJONLocalUDP::getArea() {
    return 0;
}

// Move the rectangle by dx dy
void PJONLocalUDP::move(int dx, int dy) {
//        this->x0 += dx;
//        this->y0 += dy;
//        this->x1 += dx;
//        this->y1 += dy;
}


