from setuptools import setup, Extension
from Cython.Build import cythonize

setup(
      name='localudp',
      ext_modules=cythonize(
            Extension(
                  "LocalUDP",
                  sources=["_localudp.pyx"],
                  language = "c++",
                  extra_compile_args=['-std=c++11'], #'"-Wc++11-extensions"],
                  include_dirs=['../PJON/src/'])
      )
)


# setup(name='Hello world app',
#       zip_safe=False,
#       ext_modules=cythonize(
#             "LocalUDP.pyx",
#             include_path=['../PJON/src/']))