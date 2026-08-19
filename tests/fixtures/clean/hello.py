"""A clean Python module with no flake8 errors."""


def greet(name):
    """Return a greeting string."""
    return "Hello, {}!".format(name)


if __name__ == "__main__":
    print(greet("world"))
