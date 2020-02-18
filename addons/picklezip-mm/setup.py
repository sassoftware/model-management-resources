# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0


# %%
import io
import os
from setuptools import setup, find_packages

# %% 
def getFile(fName):
    with io.open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                              fName), encoding='utf8') as inFile:
        return inFile.read()
    
setup(
      name='picklezip-mm',
      version='1.0',
      description='',
      long_description=getFile('README.md'),
      long_description_content_type='text/markdown',
      author='SAS',
      author_email='support@sas.com',
      license='Apache 2.0',
      packages=find_packages(),
      include_package_data=True,
      install_requires=[
              'scipy >= v1.4.0',
              'scikit-learn >= v0.22.1',
              'pandas >= v0.25.3'
              ],
      classifiers=[
              'Development Status :: 5 - Production/Stable',
              'Environment :: Console',
              'Intended Audience :: Science/Research',
              'Programming Language :: Python',
              'Topic :: Scientific/Engineering'
              ]
      )