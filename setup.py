from setuptools import setup, Extension
from Cython.Build import build_ext

std_args =['-std=c++11', '-DLINUX']


setup(
      name='pjon_cython',
      version='11.1.0',
      packages=['pjon_cython'],
      url='https://github.com/xlfe/PJON-cython',
      license='Apache 2.0',
      author='xlfe',
      description='Call the PJON C++ library directly from Python',
      # cmdclass={ 'build_ext': build_ext },
      ext_modules= [

            Extension(
                  "pjon_cython",
                  sources=["pjon_cython/pjon_cython.cpp"],
                  language = "c++",
                  extra_compile_args=std_args + ['-std=c++11', '-DLINUX', '-DPJON_INCLUDE_TS',
                                                 '-DPJON_INCLUDE_LUDP','-DPJON_INCLUDE_GUDP']
                                     + ['-Wno-unneeded-internal-declaration','-Wno-unused-variable'], #'"-Wc++11-extensions"],
                  include_dirs=['PJON/src']),
            # compiler_directives={'embedsignature': True}
      # )
      ]
)

