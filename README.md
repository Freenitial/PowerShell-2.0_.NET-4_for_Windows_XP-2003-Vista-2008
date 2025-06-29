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
