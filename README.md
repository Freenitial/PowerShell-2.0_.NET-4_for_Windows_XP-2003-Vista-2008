# PowerShell 2.0 + .NET 4 for legacy OS

Already included in Windows 7 / Server 2008 R2 and higher --> not necessary

---

Not compatible with :
- Windows XP RTM
- Windows XP SP1 x32
- Windows Server 2003 RTM (x32/x64)
- OS below Windows XP / Server 2003

---

This setup uses an official method for :
- Windows XP SP3 (x32)
- Windows Server 2003 SP2 (x32/x64)
- Windows Vista SP1+ (x32/x64)
- Windows server 2008 SP1+

---

This setup uses an unofficial method for :
- Windows XP SP1 x64
- Windows XP SP2 (x32/x64)
- Windows Server 2003 SP1 (x32/x64)
- Windows Vista RTM (x32/x64)
- Windows Server 2008 RTM (x32/x64)

* For 64-bit OS (using the unofficial method), PowerShell will be installed exclusively in x32 context
* Windows Server features not included
* Unofficial method inspired from: rprieto.github.io/psDeploy/powershell-2-on-windows-xp-sp2.html

---

Later, if you get an error "To run this application, you first must install one of the following versions of the .NET Framework:v4.0.30319" :
- Open the control panel, first uninstall “Microsoft .Net Framework 4 Extended”, then uninstall “Microsoft .Net Framework 4 Client Profile”.
- Restart the PC
- Launch this setup again.

---

## ScreenShot

![image](https://github.com/user-attachments/assets/58aaee03-3637-4a6a-a1e4-46e54e4e8ed5)

---

## Can be detected as a virus because it's an auto-extractible SFX

### [VirusTotal scan link](https://www.virustotal.com/gui/file-analysis/OGFjMmNlMDhkNzFiMjBhNWU2N2Q5NzBlZjNhOTBlZTI6MTc1MTI0MDYxNg==)

![image](https://github.com/user-attachments/assets/2a9e1029-1001-498d-a22b-e0f958721a51)

---

# Install

### Download and open: [Latest release](https://github.com/Freenitial/PowerShell-2.0_.NET-4_for_Windows_XP-2003-Vista-2008/releases/latest/download/Ensure_PowerShell2+.Net4.exe)
