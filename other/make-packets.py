import pjon_cython as PJON
import tempfile, itertools, time


class ThroughSerial(PJON.ThroughSerial):
    def receive(self, data, length, packet_info):
        raise Exception("Not expecting any reply")


def make_bytes(b):
    d = []
    for _ in b:
        d.append('0x{:02X}'.format(_))
    return ' '.join(d)


def make_packet(source_id, dest_id, config):


    with tempfile.TemporaryFile(buffering=0) as t:

        ts = ThroughSerial(source_id, t.fileno(), 115200)

        ts.set_synchronous_acknowledge(config['sync_ack'])
        ts.set_asynchronous_acknowledge(config['async_ack'])
        ts.include_sender_info(config['tx_info'])


        if config['packet_id'] or (config['async_ack'] and config['tx_info']):
            packet_id = random.randint(1,65530)
            ts.set_packet_id(True)
        else:
            ts.set_packet_id(False)
            packet_id = 0

        if config['port']:
            port = random.randint(1,65500)
        else:
            port = 0

        if config['ext_len']:
            data = gen_data(random.randint(256,1000))
        else:
            if config['crc32']:
                data = gen_data(random.randint(16,200))
            else:
                data = gen_data(random.randint(0,3))

        ts.set_crc_32(config['crc32'])

        ts.send(dest_id, data, port, packet_id)
        time.sleep(0.01)
        ts.loop()
        t.seek(0)
        t.flush()
        d = bytes(t.read()[1:-1])

        unescaped = []
        i = 0

        while i < len(d):

            if d[i] == 0xBB:
                unescaped.append(d[i] ^ d[i+1])
                i +=1
            else:
                unescaped.append(d[i])

            i +=1
        header = unescaped[1]

        assert d
        return {
            'packet-overhead':ts.packet_overhead(header),
            'packet': make_bytes(d),
            'port': port,
            'packet_id': packet_id,
            'data_len': len(data),
            'serial_len': len(d),
            'packet_len':len(unescaped)
        }

def gen_data(l):
    return bytes(random.randint(0,255) for _ in range(l))

import random

config = dict(
    port=False,
    sync_ack=False,
    async_ack=False,
    tx_info=False,
    ext_len=False,
    crc32=False,
    packet_id=False
)


def output_packet(config):

    # if config['async_ack'] and config['tx_info'] is False:
    #     return

    source_id = random.randint(1,255)
    dest_id = random.randint(1,255)
    data = make_packet(source_id, dest_id, config)

    data['test_name'] = '-'.join('{}_{}'.format(k,str(v).lower()) for k,v in config.items())
    data['dest-id'] = dest_id
    data['source-id'] = source_id
    if data['port'] == 0:
        data['port'] = 'false'

    data['ack_test'] = str(config['sync_ack']).lower()
    data['async_test'] = str(config['async_ack']).lower()
    data['tx-info-test'] = str(config['tx_info']).lower()
    data['ext_len-test'] = str(config['ext_len']).lower()
    data['crc32-test'] = str(data['packet_len'] > 15 or config['crc32']).lower()
    if data['packet_id'] == 0:
        data['packet_id'] = 'false'

    print("""
(def {test_name}-packet (byte-array [{packet}]))
(deftest test-{test_name}
  (let [packet (packet/parse-packet {test_name}-packet)]
    (testing "{test_name}"
      (is (= (:packet-crc-ok packet) true))
      (is (= (:header-crc-ok packet) true))
      (is (= (:packet-overhead packet) {packet-overhead}))
      (is (= (:dest-id packet) {dest-id}))
      (is (= (:ack packet) {ack_test}))
      (is (= (:crc32 packet) {crc32-test}))
      (is (= (:ext-length packet) {ext_len-test}))
      (is (= (:async-ack packet) {async_test}))
      (is (= (:tx-info packet) {tx-info-test}))
      (is (= (:packet-id packet) {packet_id}))
      (is (= (:packet-len packet) {packet_len}))
      (is (= (+ (:data-len packet) (:packet-overhead packet)) (:packet-len packet)))
      (if 
        (:tx-info packet) 
        (is (= (:source-id packet) {source-id}) ))
      (is (= (:port packet) {port}))
      (is (= (:data-len packet) {data_len}))
    )
  )
)
""".format(**data))

print("""
(ns jonure.autogen-test
  (:require [clojure.test :refer :all]
            [jonure.crc :as crc]
            [jonure.packet :as packet]
            [jonure.core :refer :all]))

;these tests are genereated using PJON-cython

""")


def toggle(config, val, lst):

    idx = lst.index(val)

    if val == lst[-1]:
        try:
            output_packet(config)
        except:
            raise Exception(config)
        config[val] = not config[val]
        try:
            output_packet(config)
        except:
            raise Exception(config)
    else:
        next = lst[idx+1]
        toggle(config, next, lst)

        config[val] = not config[val]
        toggle(config, next, lst)




vars=  list(config.keys())
toggle(config,vars[0], vars)


promlem = dict(
    port=False,
    sync_ack=True,
    async_ack=True,
    tx_info=True,
    ext_len=False,
    crc32=True,
    packet_id=True
)


# output_packet(promlem)