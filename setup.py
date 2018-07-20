from setuptools import setup, Extension
from Cython.Build import cythonize

std_args =['-std=c++11', '-DLINUX']


setup(
      name='pjon_cython',
      version='11.0.0',
      packages=['src/pjon_cython'],
      url='https://github.com/xlfe/PJON-cython',
      license='Apache 2.0',
      author='xlfe',
      description='Call the PJON C++ library directly from Python',
      ext_modules=cythonize(
            Extension(
                  "pjon_cython",
                  sources=["src/pjon_cython.pyx"],
                  language = "c++",
                  extra_compile_args=std_args + ['-std=c++11', '-DLINUX', '-DPJON_INCLUDE_LUDP','-DPJON_INCLUDE_GUDP']
                                     + ['-Wno-unneeded-internal-declaration','-Wno-unused-variable'], #'"-Wc++11-extensions"],
                  include_dirs=['PJON/src']),
            compiler_directives={'embedsignature': True}
      )
)

