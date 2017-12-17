-   ![](https://project.anrisoftware.com/projects/attachments/download/217/apache2.0-small.gif)
    (© 2016 Erwin Müller)
-   [Source github.com](https://github.com/devent/docker_utils)
-   `git`anrisoftware.com:docker\_make\_utils.git@
-   `git`github.com:devent/docker\_make\_utils.git@

Docker Make Utils
=================

This project contains scripts for Docker image creation and Docker
container creation. Those scripts are intended to be imported by a
`Makefile` script file.

Usage
-----

Checkout the `docker_make_utils` as a submodule in your Git project and
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
<td>SHELL</td>
<td>/bin/bash</td>
<td>The shell of the Makefile goals.</td>
</tr>
<tr class="even">
<td>.DEFAULT_GOAL</td>
<td>help</td>
<td>The default goal.</td>
</tr>
<tr class="odd">
<td>.PHONY</td>
<td></td>
<td>All of the goals mentioned below.</td>
</tr>
<tr class="even">
<td>NAME</td>
<td></td>
<td>The image name.</td>
</tr>
<tr class="odd">
<td>VERSION</td>
<td></td>
<td>The image version.</td>
</tr>
<tr class="even">
<td>REPOSITORY</td>
<td></td>
<td>The docker hub repository.</td>
</tr>
<tr class="odd">
<td>DOCKER_HUB_USER</td>
<td></td>
<td>The docker hub repository user name.</td>
</tr>
<tr class="even">
<td>DOCKER_HUB_PASSWORD</td>
<td></td>
<td>The docker hub repository user password.</td>
</tr>
</tbody>
</table>

### Example Image Makefile

    REPOSITORY := erwinnttdata
    NAME := mysql
    VERSION ?= 5.7-build_010

    build: _build ##@targets Builds the docker image.

    clean: _clean ##@targets Removes the local docker image.

    deploy: _deploy ##@targets Deploys the docker image to the repository.

    include docker_make_utils/Makefile.help
    include docker_make_utils/Makefile.functions
    include docker_make_utils/Makefile.image

    .PHONY +: build clean deploy

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
<td>SHELL</td>
<td>/bin/bash</td>
<td>The shell of the Makefile goals.</td>
</tr>
<tr class="even">
<td>WEAVE</td>
<td>/usr/local/bin/weave</td>
<td>The path of the weave tool.</td>
</tr>
<tr class="odd">
<td>CONTAINER_USER</td>
<td></td>
<td>The local container user. Used by the <code>_containeruser</code> goal.</td>
</tr>
<tr class="even">
<td>.DEFAULT_GOAL</td>
<td>run</td>
<td>The default goal.</td>
</tr>
<tr class="odd">
<td>.PHONY</td>
<td></td>
<td>All of the goals mentioned below.</td>
</tr>
<tr class="even">
<td>NAME</td>
<td></td>
<td>The container name.</td>
</tr>
<tr class="odd">
<td>DOCKER_CMD</td>
<td></td>
<td>The docker command to create the container.</td>
</tr>
<tr class="even">
<td>DOCKER_RUN</td>
<td>docker start $(NAME)</td>
<td>The local container user. Used by the <code>_containeruser</code> goal.</td>
</tr>
<tr class="odd">
<td>DATA_IMAGE_NAME</td>
<td></td>
<td>The data docker container image name, for example &quot;mysql:latest&quot;.</td>
</tr>
<tr class="even">
<td>DATA_VOL_NAME</td>
<td></td>
<td>The convoy volume name, for example &quot;vol1&quot;.</td>
</tr>
<tr class="odd">
<td>DATA_MOUNT_PATH</td>
<td></td>
<td>The data docker container mount path, for example &quot;/var/lib/mysql&quot;.</td>
</tr>
<tr class="even">
<td>DATA_CONTAINER_NAME</td>
<td></td>
<td>The data docker container name, for example &quot;db_data&quot;.</td>
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

-   Container makefile with a data container that stores the persistent
    data in a convoy volume.

<!-- -->

    # docker image version
    VERSION := latest
    # docker container name
    NAME := mysql
    # DNS server
    DNS_SERVER ?= 172.17.0.3
    # configuration files
    CONFIG := conf
    # database root password
    ROOT_PASSWORD ?= auHoh5fei4biSooyobae1ahp8Xi1iaGo
    # data container
    DATA_VOL_NAME := ofbiz_db1
    DATA_MOUNT_PATH := var/lib/mysql
    DATA_IMAGE_NAME := erwinnttdata/mysql:$(VERSION)
    DATA_CONTAINER_NAME := ofbiz_db_data
    # database local user
    CONTAINER_USER ?= mysql

    include ../docker_make_utils/Makefile.help
    include ../docker_make_utils/Makefile.functions
    include ../docker_make_utils/Makefile.container

    define DOCKER_CMD :=
    docker run \
    --name $(NAME) \
    --dns=$(DNS_SERVER) \
    --volumes-from $(DATA_CONTAINER_NAME) \
    -v "`realpath my.cnf`:/etc/mysql/my.cnf.custom" \
    -v "`realpath $(CONFIG)`:/etc/mysql/conf.d" \
    -e MYSQL_ROOT_PASSWORD="$(ROOT_PASSWORD)" \
    -e MYSQL_USER_ID=`id -u $(CONTAINER_USER)` \
    -e MYSQL_GROUP_ID=`id -g $(CONTAINER_USER)` \
    -d \
    $(DATA_IMAGE_NAME)
    endef

    .PHONY +: run rerun rm clean test restart dataContainer rm_dataContainer connect user drop dropdb dropuser

    run: dataContainer _containeruser _run ##@default Starts the container.

    rerun: _rerun ##@targets Stops and starts the container.

    rm: _rm ##@targets Stops and removes the container.

    clean: _clean rm_dataContainer ##@targets Stops and removes the container and removes all created files.

    test: testDataContainer _test ##@targets Tests if the container is running.

    restart: _restart ##@targets Restarts the container.

    dataContainer: _dataContainer ##@targets Creates the data container.

    rm_dataContainer: _rm_dataContainer ##@targets Removes the data container.

    testDataContainer: _testDataContainer ##@targets Tests that the data container is available.

-   This example will retrieve the IP address of a DNS server running on
    the Weave network. The name of the container running the DNS server
    should be set in the `DNS_SERVER` variable, for example as
    `DNS_SERVER := maradns`.

<!-- -->

    # The name of the container running the authoritative DNS server, for example "maradns-deadwood".
    DNS_SERVER ?= maradns

    include ../docker_make_utils/Makefile.help
    include ../docker_make_utils/Makefile.functions
    include ../docker_make_utils/Makefile.container

    define DOCKER_CMD :=
    set -x &&\
    $(DNS_SERVER_ARG) \
    docker run \
    --name $(NAME) \
    $$DNS_ARG \
    --volumes-from $(DATA_CONTAINER_NAME) \
    -v "`realpath nginx.conf`:/etc/nginx/nginx.conf.custom" \
    -v "`realpath $(CONFIG)`:/etc/nginx/conf.d" \
    -v "`realpath $(SITES)`:/etc/nginx/sites-enabled" \
    -e NGINX_USER_ID=`id -u nginx` \
    -e NGINX_GROUP_ID=`id -g nginx` \
    $(PORTS) \
    -d \
    $(IMAGE_NAME)
    endef

License
-------

Licensed under a [Apache 2.0
License.](http://www.apache.org/licenses/LICENSE-2.0) Permissions beyond
the scope of this license may be available at
`erwin.mueller`deventm.org@ or `erwin.mueller`nttdata.com@.
