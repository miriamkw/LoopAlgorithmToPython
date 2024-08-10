from setuptools import setup, find_packages

setup(
    name='loop_to_python_api',
    version='0.1.0',
    description='Accessing swift code with python.',
    author='Miriam K. Wolff',
    author_email='miriamkwolff@outlook.com',
    url='https://github.com/miriamkw/LoopAlgorithmToPython',
    packages=find_packages(),
    install_requires=[
        'pytest',
    ],
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',  # Specify the Python versions you support
)
