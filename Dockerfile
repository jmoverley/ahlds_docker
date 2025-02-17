FROM debian:jessie

LABEL maintainer "James Moverley <jmoverley@ladnet.com>"

# Steam params
ARG steam_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
ARG steam_user=anonymous
ARG steam_password=
ARG steam_dir=/opt/steam

# HLDS install bits
ARG hlds_dir=/opt/hlds

# AHL download URLs
ARG ahl_base_url="http://192.168.2.17/ahl/AHL_DC_RC2_linux.tgz"
ARG ahl_hotfix_url="http://192.168.2.17/ahl/ahldc-rc2-hf1a.tgz"
ARG ahl_dir=${hlds_dir}/action

#ARG metamod_version=1.20
#ARG metamod_url="http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download"

#ARG amxmod_version=1.8.2
#ARG amx_base_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"

RUN apt update && apt install -y lib32gcc1 curl

# Install SteamCMD
RUN mkdir -p $steam_dir && cd $steam_dir && \
    curl -sqL ${steam_url} | tar zxvf -

# Install Steam + HLDS
RUN mkdir -p ${hlds_dir}

# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786
RUN ${steam_dir}/steamcmd.sh +login $steam_user $steam_password +force_install_dir ${hlds_dir} +app_update 90 validate +quit || \
  ${steam_dir}/steamcmd.sh +login $steam_user $steam_password +force_install_dir ${hlds_dir} +app_update 90 validate +quit 
#RUN ${steam_dir}/steamcmd.sh +login $steam_user $steam_password +force_install_dir ${hlds_dir} +app_update 70 validate +quit 

RUN mkdir -p ~/.steam && ln -s ${hlds_dir} ~/.steam/sdk32 \
    && ln -s ${steam_dir} ${hlds_dir}/steamcmd

# setup action steamappid
ADD files/steam_appid.txt ${hlds_dir}/steam_appid.txt

# add in entrypoint script
ADD hlds_run.sh /bin/hlds_run.sh

# dowbload / extract AHL into hlds
RUN cd ${hlds_dir} && curl -sqL ${ahl_base_url} | tar zxvf -

# Apply AHL hotfix
RUN cd ${ahl_dir}/dlls && curl -sqL ${ahl_hotfix_url} | tar zxvf - \
    && mv ahldc-rc2-hotfix1a/ahl_i386-dhc2h1a.so ahl.so


ADD files/ahl_i686.so ${ahl_dir}/dlls/ahl.so

# setup hotfix for ahl:dc-rc2 h1a
#RUN cd ${ahl_dir}/dlls && mv ahldc-rc2-hotfix1a/ahl_i386-dhc2h1a.so ahl_i386.so

###################
## Setup SERVER
# Add default config
#ADD files/server.cfg ${ahl_dir}/server.cfg

## Add maps
#ADD maps/* ${ahl_dir}/maps/
#ADD files/mapcycle.txt ${ahl_dir}/mapcycle.txt

# # Install metamod
# RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls
# RUN curl -sqL ${metamod_url} | tar -C ${ahl_dir}/addons/metamod/dlls -zxvf -
# ADD files/liblist.gam ${ahl_dir}/liblist.gam
# # Remove this line if you aren't going to install/use amxmodx and dproto
# ADD files/plugins.ini ${ahl_dir}/addons/metamod/plugins.ini

# # Install dproto
# RUN mkdir -p ${ahl_dir}/addons/dproto
# ADD files/dproto_i386.so ${ahl_dir}/addons/dproto/dproto_i386.so
# ADD files/dproto.cfg ${ahl_dir}/dproto.cfg

# # Install AMX mod X
# RUN curl -sqL ${amx_base_url} | tar -C ${ahl_dir} -zxvf -
# ADD files/maps.ini ${ahl_dir}/addons/amxmodx/configs/maps.ini

# Cleanup
RUN apt remove -y curl

WORKDIR ${hlds_dir}

EXPOSE 27015/udp
EXPOSE 27015/tcp
EXPOSE 27020/udp
EXPOSE 26900/udp

ENTRYPOINT ["/bin/hlds_run.sh"]

# TODO: make mount-able config.. 
# - make mount area
# - create script to check for files there, if not present (1st timer run) copy in place from original
