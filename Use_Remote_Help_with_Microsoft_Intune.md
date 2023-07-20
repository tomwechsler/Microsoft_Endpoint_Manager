# Use Remote Help with Microsoft Intune

- [Remote Help](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remote-help)

> Note: The steps are from Microsoft's documentation, but somewhat summarized!

## Supported platforms and devices
This feature applies to:

- Windows 10/11
- Windows 11 on ARM64 devices
- Windows 10 on ARM64 devices
- Windows 365

## License requirements and Prerequisites

- [Microsoft Intune licensing](https://learn.microsoft.com/en-us/mem/intune/fundamentals/licenses)

- [Use Intune Suite add-on capabilities](https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-add-ons)

## Download Remote Help

- [Download Remote Help](https://aka.ms/downloadremotehelp)

## Deploy Remote Help as a Win32 app

To deploy Remote Help with Intune, you can add the app as a Windows Win32 app, and define a detection rule to identify devices that don’t have the most current version of Remote Help installed. Before you can add Remote Help as a Win32 app, you must repackage remotehelpinstaller.exe as a .intunewin file, which is a Win32 app file you can deploy with Intune.

**To do so (The name of the .exe is somewhat shortened.)**  
```
IntuneWinAppUtil.exe -c C:\Apps\RemoteHelp -s C:\Apps\RemoteHelp\remotehelpinstaller.exe -o C:\Apps\RemoteHelp\RemoteHelp_Packed -q
```

After you repackage Remote Help as a .intunewin file, use the procedures in Add a Win32 app with the following details to upload and deploy Remote Help. In the following, the repackaged remotehelpinstaller.exe file is named remotehelpinstaller.intunewin.

- For Install command line, specify remotehelpinstaller.exe /quiet acceptTerms=1
- For Uninstall command line, specify remotehelpinstaller.exe /uninstall /quiet acceptTerms=1

Manually configure detection rules:

- For Rule type, select File
- For Path, specify C:\Program Files\Remote Help
- For File or folder, specify RemoteHelp.exe
- For Detection method, select File or Folder exists

Proceed to the Assignments page, and then select an applicable device group or device groups that should install the Remote Help app. Remote Help is applicable when targeting group(s) of devices and not for User groups.

## Configure Remote Help for your tenant

**Task 1 – Enable Remote Help**  

On the Settings tab:

- Go to Tenant administration > Remote Help
- Set Enable Remote Help to Enabled to allow the use of remote help. By default, this setting is Disabled.
- Set Allow Remote Help to unenrolled devices to Enabled if you want to allow this option. By default, this setting is Disabled.
- Set Disable chat to Yes to remove the chat functionality in the Remote Help app. By default, chat is enabled and this setting is set to No.

**Task 2 – Configure permissions for Remote Help**  

The following Intune RBAC permissions manage the use of the Remote Help app.

- Category: Remote Help app
- Permissions:  
    Take full control – Yes/No  
    Elevation – Yes/No  
    View screen – Yes/No  

By default, the built-in Help Desk Operator role sets all of these permissions to Yes.

**Task 3 – Assign user to roles**  

After creating the custom roles that you'll use to provide different users with Remote Help permissions, assign users to those roles.

- Go to Tenant administration > Roles > and select a role that grants Remote Help app permissions.
- Select Assignments > Assign to open Add Role Assignment.
- On the Basics page, enter an Assignment name and optional Assignment description, and then choose Next.
- On the Admin Groups page, select the group that contains the user you want to give the permissions to. Choose Next.
- On the Scope (Groups) page, choose a group containing the users/devices that the member above will be allowed to manage. You also can choose all users or all devices. Choose Next to continue.
- On the Review + Create page, when you're done, choose Create. The new assignment is displayed in the list of assignments.

