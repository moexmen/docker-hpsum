HPE Smart Update Manager Docker Container
===
HPE's [Smart Update Manager](https://www.hpe.com/us/en/product-catalog/detail/pip.5182020.html) helps you deploy firmware and software updates to your HPE servers. This Docker container allows you to run it on your local machine the Docker way.

This container has been tested on macOS. In Linux, it should work ootb.


Launch the SUM Container
---
The container can be run in 2 ways.

Using `docker-compose`. This is the preferred method. Replace the volumes in `docker-compose.yml` with the appropriate paths.
```bash
docker-compose up
```

Using `docker run`. Replace the volumes (`-v`) with the appropriate paths.
```bash
docker run -p 63002:63002 \
-v $(pwd)/conf:/var/tmp/sum \
-v $(pwd)/baselines:/opt/sum-baselines
```

Set the root password.
```bash
docker exec -it <container_name> bash -c "chpasswd <<< 'root:p@ssw0rd'"

Login to the SUM interface at `https://localhost:63002` using the `root` credentials configured in the previous step.


Debug the container
---
Get a bash shell on the container to debug it.
```bash
docker run -it --entrypoint=bash -p 63002:63002 -v $(pwd)/conf:/var/tmp/sum -v $(pwd)/baselines/baseline-2018.09.0:/opt/sum-baseline-2018.09.0 hpe-sum
```

Using SUM
---
### (Option 1) Create a Baseline from a HTTP source
Follow these steps to create new baseline:
1. Select `Smart Update Manager > Baseline Library`.
1. Click `+ Add Baseline`.
   1. `Select the location type`: Download from http share.
   1. `Location Details`: `/opt/sum-baseline-2018.09.0`.
   1. `Enter HTTP URL`: http://downloads.linux.hpe.com/SDR/repo/spp-gen9/2018.09.0/packages/bp003318.xml
      1. Change the baseline according to the server generation and date of SPP release
   1. `OS Filter Options`: Linux
      1. At the time of writing, it's not possible to filter the packages down to the server model. This can be done only by downloading the humongous SPP (>6GB), adding it to the baseline and filtering from there.
1. Wait for the download of components to complete.

Create a subset baseline from the downloaded baseline:
1. Select `Smart Update Manager > Baseline Library`.
1. Click `Actions > Create Custom`.
   1. Filters > Advanced Filters
      1. Operating System: RHEL 7
      1. Server Model > HPE ProLiant DL Series: DL360, DL380

### (Option 2) Create new baseline from downloaded packages
Follow these steps to create new baseline:
1. Run `download-fw.sh` to download only the firmware (about 1.5GB) for the servers. Mount this folder in the Docker container.
1. Select `Smart Update Manager > Baseline Library`.
1. Click `+ Add Baseline`.
   1. `Select the location type`: Browse SUM server path
   1. `Enter directory path`: Point to the download path

### Create Node Groups
Create a node group to group servers:
1. Select `Smart Update Manager > Node Groups`.
1. Click `+ Create Node Group`.
   1. `Node Group Name`: Arbitrary
   1. `Node Group Description`: Arbitrary
   1. `Baseline`: If you went with Option 1, assign the baseline here
   1. `Additional Package`: If you went with Option 2, assign the baseline here

Config credentials to login to the nodes:
1. Select `Smart Update Manager > Node Groups`.
1. Click on the node group you just created.
1. Select `Actions > Edit`.
1. Enter the iLO `Username` and `Password` that has the permission to deploy firmware updates.

### Add Nodes
1. Select `Smart Update Manager > Node Nodes`.
1. Click `+ Add Node`.
   1. Nodes
      1. `Select operation`: Add a single node or known range of nodes
      1. `IPV4 / IPV6 / DNS`: IPs_of_nodes
      1. `Nodes type`: iLO
   1. Node Group
      1. `Assign to`: The Node Group(s) you created above
1. Credentials: Enter iLO username/password



Caveats
---
### SUM on the client machine must be accessible to the servers
The server pulls packages from SUM via its HTTPS service on port `63002`. This means that wherever SUM is deployed, the server must be able to contact it on this port. This can pose a problem if the client sits behind NAT.

Some ways to get around this:
1. Use SSH to tunnel traffic back to the client
1. Use VPN to put SUM and the servers in the same network
1. Deploy SUM in the same environment as the servers

### Running a new Docker instance with an existing SUM cache errors out
The SUM cache/config that's created by a container cannot be used by a brand new container. This following error will appear:
```
Error: Cannot launch sum_service_x64 locally. Reason: General failure. (Error: Failed to get key, run cleancache and relaunch SUM.)
```

To resolve this, the sqlite3 cache at `conf/8_3_1_7` has to be deleted. This pretty much resets SUM so it's not a viable solution.


Other Resources
---
1. [SUM User Guide and other documentation](https://support.hpe.com/hpesc/public/home/documentHome?docId=emr_na-a00047899en_us&document_type=5000001&pmrsr=0&sort_by=relevance&sp4ts.oid=1008862656)