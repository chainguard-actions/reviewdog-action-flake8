"""Module with long lines that would normally fail E501 but pass with --max-line-length=120."""


def describe_something():
    """Return a long description string that exceeds 79 chars but is under 120 chars."""
    return "This is a somewhat long line that exceeds the default 79 character limit set by PEP8 style guide"
