# Ark Dedicated Cluster
This is my personal dedicated Ark cluster. I made this so I can quickly and easily
start one or more Ark servers in a cluster. It auto updates Ark and installs/updates
mods automatically. It isn't using Ark Server Manager and doesn't have any fancy bells
and whistles like live auto updates with broadcast warnings to online players.

## Building
This image does not exist in docker hub so you'll need to build it before using it.
I had this being done in the docker-compose file but that triggers 9 builds Instead
of just 1. To build the image do the following:

```shell
docker build --no-cache -t ark:latest ./build
```

The `--no-cache` flag here isn't required, I just use it out of habit. You must run
the above from the root project directory or from within the `build` directory. If
you choose to run from the build directory `./build` will need to change to `.`.

## Running
Bringing the server online is as simple as running `docker-compose up -d`.

## Cluster Backup
There is no automated backup in this repo, I don't really need one for my small server
so I just went with an incredibly simple and "dumb" script (`backup.sh`) that just makes a tarball
of the required directories for backup. Do not run this while the cluster is running,
it may end up copying a file in a corrupted state.

## Modes of Operation
There are 2 ways to run this image:

1. **SHARED**: As a cluster sharing ini files and all binaries. This will keep the deployment size
much smaller as well as only downloading 1 set of binaries

1. **CHONKY**: As a cluster with individual ini files and a copy of all binaries. This will
significantly increase the size of your deployment and eat up a lot of bandwidth while
the binaries download. Use this only if you have a need for individual game settings per map
or plan on deploying this to multiple bare metal servers (or appropriately sized VMs)

See the included `docker-compose.yml` and `docker-compose.copies.yml` for examples of each.

## Environment Variables

| Variable Name | Description |
| ------------- | ----------- |
| CLUSTER_ID | This will be your cluster ID and must be the same for all instances (optional) |
| SESSION_NAME | The session name for your cluster/server, this will show in the server browser (required) |
| MAP_NAME | The map to run on the server (required) |
| MAIN_NODE | The `container name` of the main server node which will handle all downloading and initial configuration. This is optional for `CHONKY` mode but required for `SHARED` mode. All instances will need this variable set **except** the actual main node (optional/required) |
| MODS | A comma delimited list of mods to add to the cluster. Only the main node needs this defined in `SHARED` mode but all instances need this in `CHONKY` mode (optional) |
| OPERATORS | A comma delimited list of [Steam64 IDs](https://steamid.io/) for users you want to have admin access (optional) |
| WHITELIST | A comma delimited list of [Steam64 IDs](https://steamid.io/) for users you want to access your servers. By itself this does not do anything but allow people to bypass login queues, use this combined with `EXCLUSIVE_JOIN` to lock your server down to only allow certain players to login (optional) |
| EXCLUSIVE_JOIN | Set to `'true'` to make your server only accessible to users you specify in `WHITELIST` (optional) |
| OPT_* | [? command line arguments](https://ark.gamepedia.com/Server_Configuration#Command_line_arguments) to pass to the ark server on the command line. For example, to specify the option `?NonPermanentDiseases` you would add `OPT_NonPermanentDiseases` to your environment variables (optional) |
| OPT_Port | This is a special OPT variable that is required when running multiple instances on the same physical server. This *UDP* port should initially be `7777` and increment by 2 for each additional server. For example, if you have 3 servers your OPT_Port variable would be set to `7777`, `7779`, and `77781`. Don't forget to map your ports if using bridge mode in docker (optional/required) |
| OPT_QueryPort | *UDP* Port used for the steam server browser and discovery. This is not required for single instance servers or servers on multiple physical systems. The starting port is `27015` and you can go up or down from there (required/optional) |
| BYPASS_MAIN_NODE | Only useful for testing. If you have multiple instances in `SHARED` mode and you want to start a map that isn't the main node, use this to enable mod updates and configuration changes through launching a non-main node instance |

#### A Note on OPT_QueryPort and The Steam Browser
Steam will be able to see your game sessions through the server browser if you add it to favorites but it will only see around 6 of the
maps for some reason. Players will be able to see all your maps from within Ark at an Obelisk and if you add all servers to your favorites
there should be no issue. For example, I had to add `my.domain:27015`, `my.domain:27016`, etc. for all my game maps in order to login to a
specific map. I've read some guides that say port 27020-27050 are used by steam and cannot be used for your Ark server but I believe this is
very misleading because you can use those ports just not on a desktop machine that is also running the steam client.

## Non-Root
This image runs as a non-root user and you will need to specify the `user` (`--user`) option in docker. If you really want to run
Ark as root, just use the id 0:0

## Volumes
This image runs as non-root and does not provide chown functionality for mapped volumes. You will need to ensure that the user
has read/write access to the directory. Logs will show an error if the directory is not writable

| Volume | Description |
| ------ | ----------- |
| /server | The main instance/cluster directory. In `SHARED` mode this can be anything and all instances should be set to map the same directory. In `CHONKY` mode, you must specify unique directories for each map (eg. /data/the_island:/server, /data/the_center:/server) |
| /cluster | Directory to share data between running Ark instances. This is only required in `CHONKY` mode |

## Updates
The image will automatically update Ark to the latest server version as well as download any updates to mods. It will
also install any missing mods automatically. All you need to do is restart the containers.
