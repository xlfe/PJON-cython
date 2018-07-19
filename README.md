# PJON-cython

Call the PJON C++ library directly from Python (via [Cython](http://cython.org/))

PJON (Github: [PJON](https://github.com/gioblu/PJON/) ) is an open-source, multi-master, multi-media (one-wire, two-wires, radio) communication protocol available for various platforms (Arduino/AVR, ESP8266, Teensy).

PJON is one of very few open-source implementations of multi-master communication protocols for microcontrollers.

## PJON-cython vs PJON-python

**PJON-cython** allows you to use the C++ PJON library from Python via Cython (C++ wrappers for Python) while
**PJON-python** is a re-implementation of the PJON protocol in Python

## Current status:

- very much a work in progress, focus on LocalUDP, GlobalUDP and SWBB strategies

GlobalUDP has a very basic implementation (others are not yet)
* Tested and working to talk to other PJON nodes using GlobalUDP (RPi LINUX and ESP32)

PJON-cython versions are aligned with PJON versions to indicate compatibility with C implementation for uC platforms.

## Installation

## Minimal client example

```python
from _pjon_cython import GlobalUdp

def callback(o, test, length):
    print "Recv (" + str(length) + "): " +  test[:length]
    o.reply("P")

g = GlobalUdp(44, callback)

while True:
    g.loop(10)
```
