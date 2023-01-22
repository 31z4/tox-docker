# Docker image packaging for tox

[tox](https://tox.wiki) is a generic Python virtual environment management and test command line tool.
This multi-arch Docker image neatly packages tox along with all currently active Python versions.

## Usage

Assuming your `tox.ini` is within the curent directory, use the following command to run `tox` without any flags:

	$ docker run -v `pwd`:/tests -w /tests -it --rm 31z4/tox

Because an entrypoint of the image is `tox`, you can easily pass subcommands and flags:

	$ docker run -v `pwd`:/tests -w /tests -it --rm 31z4/tox run-parallel -e black,py311

## License

View license information for [tox](https://github.com/tox-dev/tox/blob/main/LICENSE), [pyenv](https://github.com/pyenv/pyenv/blob/master/LICENSE) and [Python 3](https://docs.python.org/3/license.html).

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).