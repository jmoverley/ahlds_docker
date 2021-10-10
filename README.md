[![Build Status](https://travis-ci.org/artem-panchenko/counter-strike-docker.svg?branch=master)](https://travis-ci.org/artem-panchenko/counter-strike-docker)
[![License Apache 2.0](https://goo.gl/joRzTI)](https://github.com/artem-panchenko/counter-strike-docker/blob/master/LICENSE)

![Half-Life Logo](https://en.wikipedia.org/wiki/Action_Half-Life#/media/File:Action_Half-life_logo.png)

# Docker image for Half-Life Dedicated Server

### Build an image:

```
 $ make build
```

### Create and start new Counter-Strike 1.6 server:

```
 $ docker run -d -p 27020:27015/udp -e START_MAP=ahl_bankdoom -e ADMIN_STEAM=0:1:1234566 -e SERVER_NAME="My Server" --name ahlds hlds:alpha
```

### Stop the server:

```
 docker stop ahlds
```

### Start existing (stopped) server:

```
 docker start ahlds
```

### Remove the server:

```
 docker rm ahlds
```

### Use image from [Docker Hub](https://hub.docker.com/r/hlds/server/):

```
 $ docker run -d -p 27020:27015/udp -e START_MAP=de_inferno -e ADMIN_STEAM=0:1:1234566 -e SERVER_NAME="My Server" --name cs hlds/server:alpha +log
```
