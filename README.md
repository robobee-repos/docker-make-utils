-   ![](https://project.anrisoftware.com/projects/attachments/download/217/apache2.0-small.gif)
    (© 2016 Erwin Müller)

<!-- -->

    git@gitea.anrisoftware.com:robobeerun/docker-make-utils.git
    git@github.com:devent/docker-make-utils.git

Docker Make Utils
=================

This project contains scripts for Docker image creation and Docker
container creation. Those scripts are intended to be imported by a
`Makefile` script file.

Usage
-----

Checkout the `docker-make-utils` as a submodule in your Git project and
import the needed utility `Makefile` into your own `Makefile` as shown
in the example below.

    include docker_make_utils/Makefile.help
    include docker_make_utils/Makefile.functions
    include docker_make_utils/Makefile.container

Makefile.help
-------------

Provides the `help` target to your `Makefile`.

Makefile.functions
------------------

Provides various functions to your `Makefile`.

-   `check_defined`, will check if a variable was set, as in the
    example:

<!-- -->

    $(call check_defined, DB_USER DB_PASSWORD, Database user credentials)

Makefile.image
--------------

Provides targets to build and to deploy a Docker image. The user is
expected to provide the `Dockerfile` and to set image related variables.

### Variables

<table>
<thead>
<tr class="header">
<th>Variable</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>NAME</code></td>
<td></td>
<td>The image name.</td>
</tr>
<tr class="even">
<td><code>VERSION</code></td>
<td></td>
<td>The image version.</td>
</tr>
<tr class="odd">
<td><code>REPOSITORY</code></td>
<td></td>
<td>The docker hub repository.</td>
</tr>
<tr class="even">
<td><code>DOCKER_HUB_USER</code></td>
<td></td>
<td>The docker hub repository user name.</td>
</tr>
<tr class="odd">
<td><code>DOCKER_HUB_PASSWORD</code></td>
<td></td>
<td>The docker hub repository user password.</td>
</tr>
<tr class="even">
<td><code>APT_CACHE</code></td>
<td></td>
<td>Optionally, the URL of the apt-cacher.</td>
</tr>
</tbody>
</table>

### Example Image Makefile

    REPOSITORY := erwin
    NAME := mysql
    VERSION ?= 5.7-build_010

    .PHONY: build
    build: _build ##@targets Builds the docker image.

    .PHONY: clean
    clean: _clean ##@targets Removes the local docker image.

    .PHONY: deploy
    deploy: _deploy ##@targets Deploys the docker image to the repository.

    include docker-make-utils/Makefile.help
    include docker-make-utils/Makefile.functions
    include docker-make-utils/Makefile.image

Makefile.container
------------------

Provides targets to run a Docker container. The user is expected to
provide the Docker command to run the container and to set container
related variables. It also provides targets to build a data container to
persist data by using the Convoy Docker module. Furthermore, it provides
targets to create a local user for the Docker container.

### Variables

<table>
<thead>
<tr class="header">
<th>Variable</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>NAME</code></td>
<td></td>
<td>Container name.</td>
</tr>
<tr class="even">
<td><code>DOCKER_CMD</code></td>
<td></td>
<td>Docker command to create the container.</td>
</tr>
<tr class="odd">
<td><code>IMAGE</code></td>
<td></td>
<td>Image name.</td>
</tr>
<tr class="even">
<td><code>DATA_NAME</code></td>
<td></td>
<td>Data container name.</td>
</tr>
<tr class="odd">
<td><code>DATA_DOCKER_CMD</code></td>
<td></td>
<td>Docker command to create the data container.</td>
</tr>
<tr class="even">
<td><code>DOCKER_RUN</code></td>
<td></td>
<td>Docker command to start the container.</td>
</tr>
</tbody>
</table>

### Examples

-   Simple container makefile with a local user for the data.

<!-- -->

    VERSION := latest
    NAME := phpmyadmin
    CONF := .
    CONTAINER_USER ?= www-data
    DNS_SERVER ?= 172.17.0.3

    include docker_make_utils/Makefile.help
    include docker_make_utils/Makefile.functions
    include docker_make_utils/Makefile.container

    define DOCKER_CMD :=
    docker run \
    --name $(NAME) \
    --dns=$(DNS_SERVER) \
    -v "`realpath $(CONF)/config.inc.php`:/usr/src/phpMyAdmin/config.inc.php.custom" \
    -e PHPMYADMIN_USER_ID=`id -u $(CONTAINER_USER)` \
    -e PHPMYADMIN_GROUP_ID=`id -g $(CONTAINER_USER)` \
    -d \
    erwinnttdata/phpmyadmin:$(VERSION)
    endef

    .PHONY +: run rerun rm clean test restart bash

    run: _localuser _run backend ##@default Starts the container.

    rerun: rm run ##@targets Stops, removes and re-starts the container.

    stop: backend-stop _stop ##@targets Stops the container.

    rm: _rm backend-rm ##@targets Stops and removes the container.

    clean: _clean backend-clean ##@targets Stops and removes the container and removes all created files.

    test: backend-test _test ##@targets Tests if the container is running.

    restart: _restart backend-restart ##@targets Restarts the container.

    bash: test _bash ##@targets Executes the bash inside the running container.

License
-------

This image is licensed under the
[MIT](https://opensource.org/licenses/MIT) license.

Copyright 2017 Erwin Müller, erwin@muellerpublic.de

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
