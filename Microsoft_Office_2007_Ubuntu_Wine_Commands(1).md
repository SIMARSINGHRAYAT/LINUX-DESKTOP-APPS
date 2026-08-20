# Microsoft Office 2007 on Ubuntu Linux — Complete Command Guide

## Enable i386 Architecture

```bash
sudo dpkg --add-architecture i386
```

## Verify i386 Architecture

```bash
dpkg --print-foreign-architectures
```

## Update Package Lists

```bash
sudo apt update
```

## Install Wine, Winbind & Winetricks

```bash
sudo apt install wine64 wine32 winbind winetricks -y
```

## Create Office 2007 Wine Prefix

```bash
export WINEPREFIX="$HOME/.wine-office2007"
```

## Initialize Wine Prefix

```bash
wineboot
```

## Open Wine Configuration

```bash
winecfg
```

## Install Rich Edit Component

```bash
winetricks riched20
```

## Install GDI+ Component

```bash
winetricks gdiplus
```

## Open Downloads Folder

```bash
cd ~/Downloads
```

## List Downloaded Files

```bash
ls
```

## Create Office 2007 Mount Directory

```bash
mkdir -p ~/office2007
```

## Mount Office 2007 ISO

```bash
sudo mount -o loop "$HOME/Downloads/Office 2007 Standard Edition32bit.iso" "$HOME/office2007"
```

## Verify Mounted Office Files

```bash
ls ~/office2007
```

## Set Wine Prefix

```bash
export WINEPREFIX="$HOME/.wine-office2007"
```

## Open Office Installation Directory

```bash
cd ~/office2007
```

## Start Microsoft Office 2007 Installation

```bash
wine setup.exe
```

## Find Microsoft Word

```bash
find "$WINEPREFIX/drive_c" -iname "WINWORD.EXE"
```

## Find Microsoft Excel

```bash
find "$WINEPREFIX/drive_c" -iname "EXCEL.EXE"
```

## Find Microsoft PowerPoint

```bash
find "$WINEPREFIX/drive_c" -iname "POWERPNT.EXE"
```

## Create Word Alias

```bash
alias winword='WINEPREFIX="$HOME/.wine-office2007" wine "$HOME/.wine-office2007/drive_c/Program Files (x86)/Microsoft Office/Office12/WINWORD.EXE"'
```

## Create Excel Alias

```bash
alias excel='WINEPREFIX="$HOME/.wine-office2007" wine "$HOME/.wine-office2007/drive_c/Program Files (x86)/Microsoft Office/Office12/EXCEL.EXE"'
```

## Create PowerPoint Alias

```bash
alias powerpoint='WINEPREFIX="$HOME/.wine-office2007" wine "$HOME/.wine-office2007/drive_c/Program Files (x86)/Microsoft Office/Office12/POWERPNT.EXE"'
```

## Save Aliases Permanently

```bash
echo 'alias winword='''WINEPREFIX="$HOME/.wine-office2007" wine "$HOME/.wine-office2007/drive_c/Program Files (x86)/Microsoft Office/Office12/WINWORD.EXE"'''' >> ~/.bashrc
```

```bash
echo 'alias excel='''WINEPREFIX="$HOME/.wine-office2007" wine "$HOME/.wine-office2007/drive_c/Program Files (x86)/Microsoft Office/Office12/EXCEL.EXE"'''' >> ~/.bashrc
```

```bash
echo 'alias powerpoint='''WINEPREFIX="$HOME/.wine-office2007" wine "$HOME/.wine-office2007/drive_c/Program Files (x86)/Microsoft Office/Office12/POWERPNT.EXE"'''' >> ~/.bashrc
```

## Reload Bash Configuration

```bash
source ~/.bashrc
```

## Launch Microsoft Word

```bash
winword
```

## Launch Microsoft Excel

```bash
excel
```

## Launch Microsoft PowerPoint

```bash
powerpoint
```

## Unmount Office 2007 ISO

```bash
sudo umount ~/office2007
```

## Remove Mount Directory

```bash
rmdir ~/office2007
```

#Ubuntu #Linux #Wine #MicrosoftOffice #Office2007 #MicrosoftWord #MicrosoftExcel #PowerPoint #Winetricks #UbuntuLinux #LinuxTutorial #KILZSNIPPET
