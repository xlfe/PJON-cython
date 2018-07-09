from setuptools import setup, Extension
from Cython.Build import cythonize

setup(
      name='python_pjon_pi',
      ext_modules=cythonize(
            Extension(
                  "python_pjon_pi",
                  sources=["_localudp.pyx"],
                  language = "c++",
                  extra_compile_args=['-std=c++11', '-DLINUX', '-DPJON_INCLUDE_LUDP']
                                     + ['-Wno-unneeded-internal-declaration','-Wno-unused-variable'], #'"-Wc++11-extensions"],
                  include_dirs=['../PJON/src/'])
      )
)

