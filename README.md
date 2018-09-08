# PJON-cython

Call the PJON C++ library directly from Python 2 or Python 3 (via [Cython](http://cython.org/))

PJON (Github: [PJON](https://github.com/gioblu/PJON/) ) is an open-source, multi-master, multi-media (one-wire, two-wires, radio) communication protocol available for various platforms (Arduino/AVR, ESP8266, Teensy).

PJON is one of very few open-source implementations of multi-master communication protocols for microcontrollers.


## PJON-cython vs PJON-python

**PJON-cython** allows you to use the C++ PJON library from Python via Cython (C++ wrappers for Python) while
**PJON-python** is a re-implementation of the PJON protocol in Python

## Current status:

- simple implementation working - focus on LocalUDP, GlobalUDP and ThroughSerial strategies
- LocalUDP - (Should work but not tested)
- GlobalUDP - Tested and appears to work
- ThroughSerial - Tested and appears to work

Note

- PJON-cython versions are aligned with PJON versions to indicate compatibility with C implementation for uC platforms.

## Testing (see pjon-cython-testing.py)

```bash
python setup.py build_ext --inplace; python pjon-cython-testing.py
python3 setup.py build_ext --inplace; python3 pjon-cython-testing.py
```

## Install from this repo

```bash
python setup.py install
```

## Install from pip

```bash
pip install pjon-cython
```

## GlobalUDP example

```python
import pjon_cython as PJON

class GlobalUDP(PJON.GlobalUDP):

    def receive(self, data, length, packet_info):
        print ("Recv ({}): {}".format(length, data))
        print (packet_info)
        self.reply(b'P')

g = GlobalUDP(44)
g.add_node(123,'192.168.22.10',1234)
g.send(123, b'HELO')

while True:
    g.loop()

```

## Through Serial example

```python
import pjon_cython as PJON

#ThroughSerial Example
# Make sure you set self.bus.set_synchronous_acknowledge(false) on the other side

class ThroughSerial(PJON.ThroughSerial):

    def receive(self, data, length, packet_info):
        if data.startswith(b'H'):
            print ("Recv ({}): {} - REPLYING".format(length, data))
            self.reply(b'BONZA')
        else:
            print ("Recv ({}): {}".format(length, data))
        print ('')

ts = ThroughSerial(44, b"<YOUR SERIAL DEVICE HERE>", 115200)

while True:
    ts.loop()
```
