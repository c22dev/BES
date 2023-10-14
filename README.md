# 🔏 BES
🖇️ Bypass Education Spyware - A piece of software that aims to proctect you from any spying by your institution

🚧 Please avoid running this script for now. Far from considered being stable and efficient. 

## 💿 Installation
1. Download this repo's ZIP
2. Extract the ZIP
3. "cd" to the extracted ZIP folder
4. "chmod" the file and execute it, then restart your machine when prompted
```bash
cd /path/to/extracted/directory/
chmod +x bes.sh
./bes.sh
```

## 📇 Goals
- Protect you and your data from any malicious attempt by profiting of badly configured MDM
- Reduce lags related to your school's proprietary software monitoring
- Prevent MDM Profiles remote push
- Disable distant screen and keyboard access
## 📉 Potential Disadvantages
- You may not be able to use, download or connect to your school software or network afterward
- You might lose some Apple Handoff Features
- You may not be able to receive any security or software update from your institution
- And probably more. Feel free to open an Issue.





## 🪄 Actual Capabilities
### 0.1a capabilities
- Launch BES as a startup daemon (aka besd)
- Remove FileWave or ActiveMgr from launchctl
- Global reset of permissions using tccutil
- Perma-kill FW-GUI and Active Mgr
Those features were and are being tested, and are confirmed to work.
   
### 0.1a in-dev capabilities (already present in script)
- Blocking app internet connection using pfctl
- Blocking servers using pfctl
- Make FileWave believe it's 2008 ([faketime](https://github.com/wolfcw/libfaketime))
  - Breaking SSL Certificate Auth
  - Breaking server connection interval
Those features encounter some issues, depesite an attempt of running them is made by the script :
 - pfctl might requires some admin privileges for certain rules. This is being worked on.
 - faketime's lib (libfaketime) isn't currently built for arm64 and isn't hooking system properly. This should be fixed in 0.1b
