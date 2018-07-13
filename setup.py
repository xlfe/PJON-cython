from setuptools import setup, Extension
from Cython.Build import cythonize

std_args =['-std=c++11', '-DLINUX']
setup(
      name='pjon_cython',
      ext_modules=cythonize(
            Extension(
                  "_pjon_cython",
                  sources=["src/_pjon_cython.pyx"],
                  language = "c++",
                  extra_compile_args=std_args + ['-std=c++11', '-DLINUX', '-DPJON_INCLUDE_LUDP','-DPJON_INCLUDE_GUDP']
                                     + ['-Wno-unneeded-internal-declaration','-Wno-unused-variable'], #'"-Wc++11-extensions"],
                  include_dirs=['PJON/src'])
      )
)

