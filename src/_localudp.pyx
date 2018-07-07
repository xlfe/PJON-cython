# distutils: language = c++

import cython
from cpython.ref cimport PyObject

def say_hello_to(name):
    print("Hello %s!" % name)