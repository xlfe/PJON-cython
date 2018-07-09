#ifndef RECTANGLE_H
#define RECTANGLE_H

    class PJONLocalUDP {
    public:
        PJONLocalUDP(unsigned short id);
        ~PJONLocalUDP();
        int getLength();
        int getHeight();
        int getArea();
        void move(int dx, int dy);
        int GetID();

    private:
        void* bus;
    };

#endif
