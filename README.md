# Docker image packaging for tox

[tox](https://tox.wiki) is a generic Python virtual environment management and test command line tool.
This multi-arch Docker image neatly packages tox v4 along with common build dependencies (e.g., `make`, `gcc`, etc) and currently [active CPython versions](https://devguide.python.org/versions/#status-of-python-versions):
* 3.7
* 3.8
* 3.9
* 3.10
* 3.11

The image is secure, tested, compact, and easy to use.
At this moment, it supports the following platforms:
* `linux/arm64/v8`
* `linux/amd64`

The following demo shows how to test [Flask](https://github.com/pallets/flask) using out-of-the box Docker image for tox:

![tox copy](https://user-images.githubusercontent.com/3657959/217558483-db24bc8e-c0f1-4591-9be0-1a19d1d48c7d.gif)

You can try it yourself by running the following commands:

```
$ git clone --depth 1 --branch 2.2.2 https://github.com/pallets/flask.git
$ docker run -v `pwd`/flask:/tests -it --rm 31z4/tox run-parallel --skip-env style
```

## Usage

The recommended way of using the image is to mount the directory that contains your tox configuration files and your code as a volume.
Assuming your project is within the current directory of the host, use the following command to run `tox` without any flags:

	$ docker run -v `pwd`:/tests -it --rm 31z4/tox

Also, you can easily pass subcommands and flags:

	$ docker run -v `pwd`:/tests -it --rm 31z4/tox run-parallel -e black,py311

Note, that the image is configured with a working directory at `/tests`.

If you want to install additional Python versions/implementations or Ubuntu packages you can create a derivative image.
Just make sure you switch the user to `root` when needed and switch back to `tox` afterwards:

```Dockerfile
FROM 31z4/tox

USER root

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        python3.12; \
    rm -rf /var/lib/apt/lists/*

USER tox
```

## Versioning

Image tags have the form of `{tox-version}-{image-version}` where `image-version` part is optional and follows [semantic versioning](https://semver.org).
For example, expect major image version bump on incompatible changes, like removing the Python version which has reached its end-of-life or changing a base image.

For production use, it's recommended to pin both tox and image versions (e.g., `31z4/tox:4.4.5-2.1.1`).

## License

View license information for [tox](https://github.com/tox-dev/tox/blob/main/LICENSE) and [Python 3](https://docs.python.org/3/license.html).

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
