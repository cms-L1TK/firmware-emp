# Building/Simulating the Track Finder Chain #

This repository contains payload projects for the end of the Track Finder chain - compatible with the extensible, modular processor (EMP) firmware framework for phase-2 upgrades.

The project can be built against multiple boards, but has so far been implemented for the Apollo (VU13P) and Serenity (VU13P).

## Quick start instructions for developers ##

Make sure that the [Prerequisites](#prerequisites) are satisfied.

##### Step 1: Setup the work area

```
ipbb init work
cd work
kinit myusername@CERN.CH

ipbb add git https://gitlab.cern.ch/ttc/legacy_ttc.git -b v2.1
ipbb add git https://:@gitlab.cern.ch:8443/cms-tcds/cms-tcds2-firmware.git -b v0_1_1
ipbb add git https://gitlab.cern.ch/HPTD/tclink.git -r fda0bcf07c501f81daeec1421ffdfb46f828f823
ipbb add git https://gitlab.cern.ch/dth_p1-v2/slinkrocket_ips.git -b v03.12
ipbb add git https://github.com/ipbus/ipbus-firmware -b v1.14.1
ipbb add git https://gitlab.cern.ch/gbt-fpga/gbt-fpga.git -b gbt_fpga_6_1_0
ipbb add git https://gitlab.cern.ch/gbt-fpga/lpgbt-fpga.git -b v.2.1
ipbb add git https://:@gitlab.cern.ch:8443/gbtsc-fpga-support/gbt-sc.git -b gbt_sc_4_3
ipbb add git https://github.com/apollo-lhc/CM_FPGA_FW -b v3.0.0
ipbb add git https://:@gitlab.cern.ch:8443/p2-xware/firmware/emp-fwk.git -b v0.9.3
ipbb add git https://github.com/cms-L1TK/l1tk-for-emp.git -b update_emp_version
```

*Note: You need to be a member of the `cms-tcds2-users` egroup in order to clone the `cms-tcds2-firmware` repository. In order to add yourself to that egroup, go to the "Members" tab of [this page](https://e-groups.cern.ch/e-groups/Egroup.do?egroupId=10380295), and click on the "Add me" button; you may need to wait ~ 24 hours to get access to the GitLab repo.*

Some repositories might require 2-factor authenication to clone, thus create a personal access token on [gitlab](https://gitlab.cern.ch:8443/help/user/profile/personal_access_tokens.md) and use said token to download the repositories, e.g.

```
ipbb add git https://gitlab-ci-token:INSERT_TOKEN_HERE@gitlab.cern.ch:8443/p2-xware/firmware/emp-fwk.git -b v0.9.1
ipbb add git https://gitlab-ci-token:INSERT_TOKEN_HERE@gitlab.cern.ch:8443/cms-tcds/cms-tcds2-firmware.git -b v0_1_1
ipbb add git https://gitlab-ci-token:INSERT_TOKEN_HERE@gitlab.cern.ch:8443/dth_p1-v2/slinkrocket.git -b v03.12
```

##### Step 2: Create an ipbb project area

Some of the available projects are currently

| Description                                              | `.dep` file name                  |
| -------------------------------------------------------- | --------------------------------- |
| Track Merger (tm)                                        | `apollo.dep`                      |
| Track Merger (tm)                                        | `serenity.dep`                    |
| Duplicate Remover (dr)                                   | `apollo.dep`                      |
| Kalman Filter (kf)                                       | `apollo.dep`                      |
| TM to KF (tmdrkf)                                        | `apollo.dep`                      |
| TM to DR (tmdr)                                          | `apollo.dep`                      |
| DR to KF (drkf)                                          | `apollo.dep`                      |
| Hybrid Summer Chain                                      | `apollo.dep`                      |
| Hybrid Summer Chain                                      | `Serenity.dep`                    |

A project area can be created as follows:

For board implementation:
```
ipbb proj create vivado FOLDER_NAME l1tk-for-emp:PROJECT_NAME 'apollo.dep'
cd proj/FOLDER_NAME
```

For questa simulation testbench:
```
ipbb proj create sim FOLDER_NAME l1tk-for-emp:PROJECT_NAME 'qsim.dep'
ln -s ../src/l1tk-for-emp/tracklet/firmware/emData/ proj/ % I don't do this... I specify the path to the input files manually
cd proj/FOLDER_NAME
```

For vivado simulation testbench:
```
ipbb proj create sim FOLDER_NAME l1tk-for-emp:PROJECT_NAME 'vsim.dep'
ln -s ../src/l1tk-for-emp/tracklet/firmware/emData/ proj/ % I don't do this... I specify the path to the input files manually
cd proj/FOLDER_NAME
```

##### Step 3: Implementation and simulation


For board implementation:
Note: For the following commands, you need to ensure that can find & use the `gen_ipbus_addr_decode` script - e.g. for a standard uHAL installation:
```
export PATH=/opt/cactus/bin/uhal/tools:$PATH LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
```
Run the following IPBB commands:
```
ipbb ipbus gendecoders
ipbb vivado generate-project --single
ipbb vivado synth -j8 impl -j8
ipbb vivado package
```


For questa simulation testbench:
```
ipbb sim setup-simlib
ipbb sim ipcores
ipbb sim fli-udp
ipbb sim generate-project (rerun this if you change VHDL)

./run_sim -c work.top -Gsourcefile=<input.txt> -Gsinkfile=<out.txt> -Gplaylen=xyz -Gcaplen=xyz -do 'run 50.0us' -do quit 
  (where xyz = number of events * 108, where default is 9 events).
```
where `input.txt` follows the standard EMP pattern file convention. 
To create input.txt from InputRouter input files in emData/, run in work/proj/

```
python3 ../src/l1tk-for-emp/script/convert_emData2EMP_Link.py
```

*N.B.* The Xilinx simulation libraries can be shared between different ipbb projects and work areas. By default they are written to `${HOME}/.xilinx_sim_libs`, but they can be written to another directory by defining the environment variable `IPBB_SIMLIB_BASE` before running these two commands, or by adding the `-x` option to end of each command (e.g. `-x /path/to/simlib_directory`).

For vivado simulation testbench:
```
ipbb vivado generate-project
```
and open the project with vivado gui for simulation.

## Comparison with emulation ##

Aside from doing this in CMSSW (for up to 9 consecutive events), can do in proj/work/ 

```
# Convert emulated TrackBuilder output file in emData/ to EMP format
python3 ../src/l1tk-for-emp/script/convert_emData2EMP_FT.py
# Compare this corresponding file from VHDL test-bench 
python3 ../src/l1tk-for-emp/script/compareEMP_FT.py
```


## Prerequisites ##

 * Xilinx Vivado 2022.1 (or later)
 * Python 2.7 - available on most linux distributions, natively or as [miniconda](https://conda.io/miniconda.html) distribution.
 * Python 3 devel
 * ipbb: `dev/2024b` pre-release or greater - the [IPbus Builder Tool](https://github.com/ipbus/ipbb). Note: a single `ipbb` installation is not work area specific and suffices for any number of projects.
 
```
curl -L https://github.com/ipbus/ipbb/archive/dev/2024b.tar.gz | tar xvz
source ipbb-dev-2024b/env.sh
(or if you use tcsh:  bash -c 'source ipbb-dev-2024b/env.sh; tcsh -l')
```

## Guide to firmware ##

````
UTILITIES

common/firmware/hdl/hybrid_config.vhd
  Cfg params (#PS DTC, #2S DTC, num layers ...)

common/firmware/hdl/hybrid_data_formats.vhd:
  Defines tracking bit widths

common/firmware/hdl/hybrid_data_types.vhd:
  Defines tracker data types.

common/firmware/hdl/hybrid_tools.vhd
  Defines functions

/emp-fwk/components/datapath/firmware/hdl/emp_data_types.vhd
/emp-fwk/components/ttc/firmware/hdl/emp_ttc_decl.vhd:
  Define EMP data types (ldata=64b data, start, valid)

CODE

emp_payload.vhd:
  Top-level: converts EMP links I/O data (format ldata) to/from formats t_stubsDTC (hybrid DTC stub format for PS & 2S) / t_trackTracklet (hybrid tracklet format), and calls hybrid_tracklet to run L1 tracking.

````
