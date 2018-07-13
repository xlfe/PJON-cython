# PJON-cython

Call the PJON C++ library directly from Python (via [Cython](http://cython.org/))

PJON (Github: [PJON](https://github.com/gioblu/PJON/) ) is an open-source, multi-master, multi-media (one-wire, two-wires, radio) communication protocol available for various platforms (Arduino/AVR, ESP8266, Teensy).

PJON is one of very few open-source implementations of multi-master communication protocols for microcontrollers.

## PJON-cython vs PJON-python

**PJON-cython** allows you to use the C++ PJON library from Python via Cython (C++ wrappers for Python) while
**PJON-python** is a re-implementation of the PJON protocol in Python

## Current status:

- work in progress, focus on LocalUDP, GlobalUDP and SWBB strategies

PJON-cython versions are aligned with PJON versions to indicate compatibility with C implementation for uC platforms.


## Installation

## Minimal client example

```python
from pjon_python.base_client import PjonBaseSerialClient
import time

pjon_cli = PjonBaseSerialClient(1, 'COM6')
pjon_cli.start_client()


def receive_handler(payload, packet_length, packet_info):
    print "received packet from device %s with payload: %s" % (packet_info.sender_id, payload)

pjon_cli.set_receive(receive_handler)

while True:
    #             recipient id   payload
    pjon_cli.send(35,            'C123456789')  # payload can be string or an array of bytes (or any type suitable for casting to byte)
    time.sleep(1)
```
