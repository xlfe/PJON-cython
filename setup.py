#!/usr/bin/env python

from setuptools import setup, Extension
import os

if 'FORCE_CYTHON' in os.environ:
    USE_CYTHON = True
elif 'DISABLE_CYTHON' in os.environ:
    USE_CYTHON = False
else:
    USE_CYTHON = 'auto'

setup_requires = ['nose>=1.0']

if USE_CYTHON:
    try:
        from Cython.Distutils import build_ext
    except ImportError:
        if USE_CYTHON == 'auto':
            USE_CYTHON = False
        else:
            raise

cmdclass = {}

if USE_CYTHON:
    source = 'pyx'
    cmdclass.update({'build_ext': build_ext})
    setup_requires.append('Cython')
else:
    source = 'cpp'

setup(
    name='pjon_cython',
    version='11.1.3',
    packages=['pjon_cython'],
    url='https://github.com/xlfe/PJON-cython',
    license='Apache 2.0',
    author='xlfe',
    description='Call the PJON C++ library directly from Python',
    setup_requires=setup_requires,
    test_suite = 'nose.collector',
    cmdclass=cmdclass,
    ext_modules=[
        Extension(
            "pjon_cython._pjon_cython",
            sources=["pjon_cython/_pjon_cython.{}".format(source)],
            language="c++",
            extra_compile_args=[
                '-std=c++11',
                '-DPJON_INCLUDE_TS',
                '-DPJON_INCLUDE_LUDP',
                '-DPJON_INCLUDE_GUDP',
                # '-DPJON_INCLUDE_PACKET_ID=true',
                # '-DPJON_INCLUDE_ASYNC_ACK=true',
                '-DLINUX',
                '-Wno-unneeded-internal-declaration',
                '-Wno-unused-variable'],
            include_dirs=['PJON/src'],
        compiler_directives={'embedsignature': True}
        )
    ]
)
