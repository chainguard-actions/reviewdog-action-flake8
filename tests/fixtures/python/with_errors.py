"""A Python module with intentional flake8 errors."""
import os  # F401 'os' imported but unused
import sys  # F401 'sys' imported but unused


def bad_function( x,y ):  # E231, E203
    return x+y  # E225
