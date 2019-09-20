from setuptools import setup
import os
import sys

_here = os.path.abspath(os.path.dirname(__file__))

if sys.version_info[0] < 3:
    with open(os.path.join(_here, 'README.rst')) as f:
        long_description = f.read()
else:
    with open(os.path.join(_here, 'README.rst'), encoding='utf-8') as f:
        long_description = f.read()

version = {}
with open(os.path.join(_here, 'mp-crawl', 'version.py')) as f:
    exec(f.read(), version)

setup(
    name='mp-crawl',
    version=version['__version__'],
    description=('High-level interface to obtain data from Marktplaats.nl.'),
    long_description=long_description,
    author='Mark van der Broek',
    author_email='markvanderbroek@gmail.com',
    url='https://github.com/markkvdb/marktplaats-crawler',
    license='MPL-2.0',
    packages=['mp-crawl'],
#   no dependencies in this example
#   install_requires=[
#       'dependency==1.2.3',
#   ],
#   no scripts in this example
#   scripts=['bin/a-script'],
    include_package_data=True,
    classifiers=[
        'Development Status :: 2 - Pre-Alpha,
        'Intended Audience :: Science/Research',
        'Programming Language :: Python :: 3.7'],
    )