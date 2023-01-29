# Docker image packaging for tox

_Disclaimer: this project is under active development and is not recommended for production use._

[tox](https://tox.wiki) is a generic Python virtual environment management and test command line tool.
This multi-arch Docker image neatly packages tox v4 along with all currently [active Python versions](https://devguide.python.org/versions/#status-of-python-versions).
The image is secure, compact, and easy to use.

At this moment, the image only supports the following platforms:
* `linux/arm64/v8`
* `linux/amd64`

## Usage

The recommended way of using the image is to mount the directory that contains your tox configuration files and your code as a volume.
Assuming your project is within the current directory of the host, use the following command to run `tox` without any flags:

	$ docker run -v `pwd`:/tests -w /tests -it --rm 31z4/tox

Because an entry point of the image is `tox`, you can easily pass subcommands and flags:

	$ docker run -v `pwd`:/tests -w /tests -it --rm 31z4/tox run-parallel -e black,py311

To list all installed Python versions, run:

	$ docker run -it --rm --entrypoint pyenv 31z4/tox versions

## Versioning

Image tags have the form of `{tox-version}-{image-version}` where `image-version` part is optional and follows [semantic versioning](https://semver.org).
For example, expect major image version bump on incompatible changes, like removing the Python version which has reached its end-of-life or changing a base image.

For production use, it's recommended to pin both tox and image versions (e.g., `31z4/tox:4.3.5-1.0.0`).
Although, the image is not ready for production yet.

## Limitations

The current version of the image has several limitations.
Some of these limitations might be addressed in the future.

* tox v3 is not supported.
* The image is optimized for size and doesn't include any build dependencies.
Thus, it is not possible to install additional Python versions into a running container.
Also, testing Python code that requires building C extensions is not supported.

## Known issues

Multi-platform image build using emulation is ridiculously slow on macOS running on an M1 chip.
Possible solutions are:
* Cross-compiling Python (might be tricky).
* Use [deadsnakes PPA](https://launchpad.net/~deadsnakes) instead of compiling Python.
* Building on multiple native nodes.

## License

View license information for [tox](https://github.com/tox-dev/tox/blob/main/LICENSE), [pyenv](https://github.com/pyenv/pyenv/blob/master/LICENSE) and [Python 3](https://docs.python.org/3/license.html).

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).