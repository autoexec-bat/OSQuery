/****************************** Sophos.com/RapidResponse ******************************\
| DESCRIPTION                                                                          |
| Pass the hash is a method of authenticating as a user without having access to the   |
| user's cleartext password. It's usually performed using tools such as Mimikatz.      |
| Adversaries uses this method to move laterally within an environment. This event will|
| be logged on the SOURCE HOST machine.                                                |
|                                                                                      |
| REFERENCE                                                                            |
| https://blog.netwrix.com/2021/11/30/how-to-detect-pass-the-hash-attacks/             |
| https://attack.mitre.org/techniques/T1550/002/                                       |
|                                                                                      |
| Version: 1.0                                                                         |
| Author: The Rapid Response Team | Stephen McNally                                    |
| github.com/SophosRapidResponse                                                       |
\**************************************************************************************/

SELECT
    strftime('%Y-%m-%dT%H:%M:%SZ',datetime) AS Datetime,
    source,
    eventid,
    JSON_EXTRACT(data, '$.EventData.TargetUserName') AS Targeted_Username,
    JSON_EXTRACT(data, '$.EventData.TargetDomainName') AS Targeted_Domain,
    JSON_EXTRACT(data, '$.EventData.LogonType') AS Logon_Type,
    JSON_EXTRACT(data, '$.EventData.AuthenticationPackageName') AS Auth_Package,
    JSON_EXTRACT(data, '$.EventData.LogonProcessName') AS Logon_Process,
    'Low' As Potential_FP_chance,
    'EVTX' AS Data_Source,
    'T1550.002 - Pass the Hash' AS Query 
FROM sophos_windows_events
WHERE
    source = 'Security' 
    AND eventid = 4624
    AND Logon_Type = 9
    AND Auth_Package = 'Negotiate' 
    AND Logon_Process = 'seclogo'