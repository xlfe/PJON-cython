# PJON-cython

Call the PJON C++ library directly from Python 2 or Python 3 (via [Cython](http://cython.org/))

PJON (Github: [PJON](https://github.com/gioblu/PJON/) ) is an open-source, multi-master, multi-media (one-wire, two-wires, radio) communication protocol available for various platforms (Arduino/AVR, ESP8266, Teensy).

PJON is one of very few open-source implementations of multi-master communication protocols for microcontrollers.


## PJON-cython vs PJON-python

**PJON-cython** allows you to use the C++ PJON library from Python via Cython (C++ wrappers for Python) while
**PJON-python** is a re-implementation of the PJON protocol in Python

## Current status:

Support for PJON 11.1 *only* and the following strategies :-
- LocalUDP
- GlobalUDP
- ThroughSerial
- ThroughSerialAsync *new*

Note

- PJON-cython versions are aligned with PJON versions to indicate compatibility with C implementation for uC platforms.

#### Python support

Python 2.7, 3.4, 3.5 and 3.6 are tested and considered supported

#### Platform support

Linux and Mac OS X are considered supported. Windows is not supported (sorry!).

## Install from pip

Current version is 11.1.5-1

```bash
pip install pjon-cython
```

## Testing

```bash
$(which python) setup.py nosetests --with-doctest --doctest-extension=md
```

## GlobalUDP example

```python
>>> import pjon_cython as PJON
>>> class GlobalUDP(PJON.GlobalUDP):
...     # you can overload __init__ if you want
...     def __init__(self, device_id):
...         PJON.GlobalUDP.__init__(self, device_id)
...         self.packets_received = 0
...     def receive(self, data, length, packet_info):
...         print ("Recv ({}): {}".format(length, data))
...         print (packet_info)
...         self.packets_received += 1
...         self.reply(b'P')

>>> g = GlobalUDP(44)
>>> idx = g.send(123, b'HELO')
>>> # calling loop calls the PJON bus.update() and bus.receive()
>>> # and the return is the results of those functions -
>>> packets_to_send, receive_status = g.loop()
>>> # packets_to_send is the Number of packets in the PJON buffer
>>> packets_to_send
1
>>> #PJON constants are available too
>>> receive_status == PJON.PJON_FAIL
True
>>> # When you're done with your PJON interface, you can cleanup the connection by deleting it
>>> del g

```

## Through Serial example

```python
>>> import pjon_cython as PJON
>>> #ThroughSerial Example
>>> # Make sure you set self.bus.set_synchronous_acknowledge(false) on the other side
>>> 
>>> class ThroughSerial(PJON.ThroughSerial):
...
...     def receive(self, data, length, packet_info):
...        if data.startswith(b'H'):
...            print ("Recv ({}): {} - REPLYING".format(length, data))
...            self.reply(b'BONZA')
...        else:
...            print ("Recv ({}): {}".format(length, data))
...        print ('')
...
>>> # Put your actual serial device in here...
>>> ts = ThroughSerial(44, b"/dev/null", 115200)
>>> # Send returns the packet's index in the packet buffer
>>> ts.send(100, b'PING 1')
0
>>> ts.send(100, b'PING 2')
1
>>> # Error handling happens through exceptions such as PJON.PJON_Connection_Lost
>>> while True:
...     packets_to_send, receive_status = ts.loop()
Traceback (most recent call last):
    ...
PJON_Connection_Lost

```


## Setting configurable properties

```python
>>> import pjon_cython as PJON
>>> class GlobalUDP(PJON.GlobalUDP):
...     def receive(self, data, length, packet_info):
...         print ("Recv ({}): {}".format(length, data))

>>> # GlobalUDP and LocalUDP both support set_port to configure their UDP listening port
>>> g = GlobalUDP(99, 8821)
>>> del g
>>> #They return the class object, so you can "chain them"
>>> pjon = GlobalUDP(100,8821).set_autoregistration(False)
>>> pjon                                                            # doctest: +ELLIPSIS
<__main__.GlobalUDP object at 0x...>
>>>
>>> # These options affect packet overhead (in bytes)
>>> pjon.packet_overhead()
6
>>> pjon.set_crc_32(True).packet_overhead()
9
>>> pjon.set_packet_id(True).packet_overhead()
11
>>> pjon.set_synchronous_acknowledge(True).packet_overhead()
11
>>> pjon.set_packet_id(False).set_asynchronous_acknowledge(False).packet_overhead()
9
>>> pjon.set_crc_32(False).include_sender_info(False).packet_overhead()
5

```
