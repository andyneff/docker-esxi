This is an attempt to create a docker environment for ESXi, with the goal to be able to compile ESXi plugins directly in this esxi image. No more "try it in an old OS and hope the binaries are compatible"

***This is NOT running ESXi VMs in Docker. That's just not possible. This only lets you run some of the ESXi's binaries, which is only useful for testing, debugging, and compiling packages to install into a real ESXi server.***

# Setup

Since I don't have permission to distribute ESXi, you will have to download the
ISO yourself from VMWare and put it in the docker context, and then build the
docker image. BYOD - Build Your Own Docker (image). Update: Tested with ESXi 7.0. ("Compressed data is corrupt" is now ignored, it's just some signature upsetting xz after it succeeds)

1. ~~Download the ESXi iso using https://my.vmware.com/en/group/vmware/evalcenter?p=free-esxi6.
Note: [this](https://my.vmware.com/group/vmware/details?productId=614&downloadGroup=ESXI650A)
link did not work for me for some reason, but [this](https://my.vmware.com/group/vmware/info/slug/datacenter_cloud_infrastructure/vmware_vsphere_hypervisor_esxi/6_5) link will let you choose from the different versions~~
1. Go to https://my.vmware.com/en/group/vmware/downloads/info/slug/datacenter_cloud_infrastructure/vmware_vsphere/7_0
  - Pick your version, then (I go to Standard, not that I understand the differences), next to the "VMware vSphere Hypervisor (ESXi)", I click "Go to Downloads"
  - I forget what I did next "Click get Trial?" But at any rate, I got it to allow me to download, and I did so.
  - I think this is how you download all versions of ESXi in 2020 now.
2. Place the iso in **same** directory as the Dockerfile (it must be in the [docker context](https://docs.docker.com/engine/reference/commandline/build/#extended-description) in order for this to work)
3. Run `docker-compose build --build-arg ISO_IMAGE=my_image_filename.iso` esxi.
    - For example if the iso you download is called `VMware-VMvisor-Installer-6.0.0.update02-3620759.x86_64.iso`, then you should run the command:

          docker-compose build --build-arg ISO_IMAGE=VMware-VMvisor-Installer-6.0.0.update02-3620759.x86_64.iso

    - Also acceptable:

          docker build --build-arg ISO_IMAGE=VMware-VMvisor-Installer-6.0.0.update02-3620759.x86_64.iso -t andyneff/esxi .

    - **Note**: this can only be a relative path to the docker context. No absolute path will work.

4. And now, you have an ESXi base image. `andyneff/esxi`

# Usage

I have no idea how much of this ESXi image works. It is mainly a proof of concept, but I do use this to build a ESXi plugin [here](https://github.com/andyneff/esxi-nut/blob/master/Dockerfile) which will create a plugin package for ESXi that I know works, because it is compiled in this ESXi environment

# Issues

On some versions of `Docker for Windows`, building the images just freezes on the step `Step 14/17 : COPY --from=stage /esxi /`

# Thanks

Special thanks to [William Lam](https://www.virtuallyghetto.com/2011/08/how-to-create-and-modify-vgz-vmtar.html)
and [Jonathon Reinhart](https://github.com/JonathonReinhart/vmware-utils/blob/master/vtar/vtar.py)
