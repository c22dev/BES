# BES

## Installation
1. Download this repo's ZIP
2. Extract the ZIP
3. "cd" to the extracted ZIP folder
4. "chmod" the file and execute it, then restart your machine when prompted
```bash
cd /path/to/extracted/directory/
chmod +x bes.sh
./bes.sh
```
## Capabilities
### 0.1b capabilities
- Launch BES as a startup daemon (aka besd)
- Remove FileWave GUI or ActiveMgr from launchctl
- Global reset of permissions using tccutil
- Perma-kill FW-GUI and Active Mgr
- Block connections to any of your campus CO network if said so (check every second). Please set isFCOBlocked to true if you want to enable this feature.
Those features were and are being tested, and are confirmed to work.
   
### 0.1b in-dev capabilities (already present in script)
- Blocking app internet connection using pfctl
- Blocking servers using pfctl
- Make FileWave believe it's 2008 ([faketime](https://github.com/wolfcw/libfaketime))
  - Breaking SSL Certificate Auth
  - Breaking server connection interval

Those features encounter some issues, depesite an attempt of running them is made by the script :
 - pfctl might requires some admin privileges for certain rules. This is being worked on.
 - faketime's lib (libfaketime) is currently built for arm64 but isn't hooking date process properly.
