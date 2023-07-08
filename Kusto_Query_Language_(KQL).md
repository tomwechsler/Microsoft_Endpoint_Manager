# Analyze Intune Logs with Kusto Query Language (KQL)!

## Log Analytics Workspace

Before we can examine the logs, we need a central repository where the logs can be stored. In this case, that would be a Log Analytics Workspace in Azure.

<img src="/Images/LAW.png" alt="Log Analytics Workspace">

**If you don't have one yet, here's how to create a Log Analytics workspace.**  

- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)

## Intune Reports

In order for the logs to be examined, we must first make the tenant aware that we want to collect the logs. This means that we have to set up the Diagnostic Settings.

<img src="/Images/Intune_Tenant_Add.png" alt="Setup Diagnostic settings">

<img src="/Images/Diag_Settings.png" alt="Diagnostic settings">

As you have done the preparation it now takes some time until you can examine the logs. Give the portal a few hours/days. After that you can start the log analysis.

<img src="/Images/Query_Logs.png" alt="Log Query">

## KQL Examples

1. List of Devices and the assigned UserName.

```
// List of Devices and the assigned UserName.
IntuneDevices
//| where OS == "Windows"
| where PrimaryUser !startswith "000000"
| project DeviceName, UserName
```
<img src="/Images/Example_1.png" alt="Example 1">

If you remove the comment (//), you will search only for Windows devices.

2. Visualize device compliance

```
// Visualize device compliance
IntuneDevices
| where TimeGenerated > ago (30d)
| summarize arg_max(DeviceName, *) by DeviceName
| where isnotempty(CompliantState)
| summarize ComplianceCount=count()by CompliantState
| render piechart      
    with (title="Device compliance")
```

<img src="/Images/Example_2.png" alt="Example 2">

3. Autopilot process

```
// Show how long the Autopilot process took in seconds and minutes.
IntuneOperationalLogs
| where TimeGenerated > ago(30d)
| extend DeviceId = tostring(todynamic(Properties).DeviceId)
| extend Time_Seconds = todynamic(Properties).TimeDiff
| extend Autopilot = todynamic(Properties).IsAutopilot
| extend Status = todynamic(Properties).Status
| extend Time_Minutes = Time_Seconds/60
| where Status == "Completed"
| where isnotempty(Autopilot)
| join kind=leftouter IntuneDevices on DeviceId 
| project ['Is Autopilot?'] = Autopilot, Status, DeviceName, Time_Minutes, Time_Seconds
```
<img src="/Images/Example_3.png" alt="Example 3">

4. Devices and timestamp the last time they successfully connected to Intune.

```
// Devices and timestamp the last time they successfully connected to Intune.
IntuneDeviceComplianceOrg
| where todatetime(LastContact) > ago(30d)
| extend Date=format_datetime(todatetime(LastContact), "dd.MM.yyyy")
| extend Time=format_datetime(todatetime(LastContact), "hh:mm tt")
| extend ['Last successful connection']=strcat(Date," ",Time)
| sort by Date
| project DeviceName, ['Last successful connection']
| project-rename ['Device name'] = DeviceName
```

<img src="/Images/Example_4.png" alt="Example 4">

5. Percentage of free storage on devices

```
// Percentage of free storage on devices
IntuneDevices
| where OS == "Windows"
| where StorageFree != "0" and StorageTotal != "0"
| where DeviceName != "User deleted for this device" and DeviceName != ""
| extend ['Free Storage'] = StorageFree
| extend ['Total Storage'] = StorageTotal
| extend Percentage = round(todouble(StorageFree) * 100 / todouble(StorageTotal), 2)
| distinct DeviceName, ['Free Storage'], ['Total Storage'], Percentage, UserName
| sort by Percentage asc
```
<img src="/Images/Example_5.png" alt="Example 5">