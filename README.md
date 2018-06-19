This is an attempt to create a docker environment for esxi, with the eventual
goal to be able to compile in esxi directly

# Setup

Since I don't have permission to distribute esxi, you will have to download the
ISO yourself from VMWare and put it in the docker context, and then build the
docker image. BYOD - Build Your Own Docker (image).

1. Download the esxi iso using https://my.vmware.com/en/group/vmware/evalcenter?p=free-esxi6.
Note: [this](https://my.vmware.com/group/vmware/details?productId=614&downloadGroup=ESXI650A)
link did not work for me for some reason, but [this](https://my.vmware.com/group/vmware/info/slug/datacenter_cloud_infrastructure/vmware_vsphere_hypervisor_esxi/6_5) link will let you choose from the different versions
2. Place the iso in **same** directory as the Dockerfile
3. Run `docker-compose build --build-arg ISO_IMAGE={image_filename.iso}`
4. And now, you have an esxi base image. `andyneff/esxi`

# Usage

I have no idea how much works in this container, it currently only a proof of
concept

# Thanks

Special thanks to [William Lam](https://www.virtuallyghetto.com/2011/08/how-to-create-and-modify-vgz-vmtar.html)
and [Jonathon Reinhart](https://github.com/JonathonReinhart/vmware-utils/blob/master/vtar/vtar.py)