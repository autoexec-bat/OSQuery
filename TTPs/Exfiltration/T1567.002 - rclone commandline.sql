/*************************** Sophos.com/RapidResponse ***************************\
| DESCRIPTION                                                                    |
| The query look for evidence of Rclone execution in the commandline. It might   |
| bring FP.                                                                      |
|                                                                                |
|                                                                                |
| VARIABLES                                                                      |
| - start_time(date)                                                             |
| - end_time (date)                                                              |
|                                                                                |
| Version: 1.0                                                                   |
| Author: The Rapid Response Team                                                |
| github.com/SophosRapidResponse                                                 |
\********************************************************************************/

SELECT 
 strftime('%Y-%m-%dT%H:%M:%SZ',datetime(spj.process_start_time,'unixepoch')) AS Datetime,
 spj.path AS Path, 
 spj.cmd_line AS Cmd_Line,
 spj.sophos_pid AS sophos_PID, 
 CAST (spj.process_name AS TEXT) Process_Name,
 strftime('%Y-%m-%dT%H:%M:%SZ',datetime(spj.process_start_time,'unixepoch')) AS Process_Start_Time, 
 CASE WHEN spj.end_time = 0 THEN '' ELSE strftime('%Y-%m-%dT%H:%M:%SZ',datetime(spj.end_time,'unixepoch')) END AS Process_End_Time, 
 CAST ( (Select u.username from users u where spj.sid = u.uuid) AS text) Username,
 spj.sid AS Sid,
 spj.sha256 AS sha256,
 spj.file_size AS File_Size, 
 CAST ( (Select strftime('%Y-%m-%dT%H:%M:%SZ',datetime(f.btime,'unixepoch')) from file f where f.path = spj.path) AS text) First_Created_On_Disk,
 CAST ( (Select strftime('%Y-%m-%dT%H:%M:%SZ',datetime(f.mtime,'unixepoch')) from file f where f.path = spj.path) AS text) Last_Modified,
 spj.parent_sophos_pid AS sophos_parent_PID, 
 CAST ( (Select spj2.path from sophos_process_journal spj2 where spj2.sophos_pid = spj.parent_sophos_pid) AS text) Parent_Path, 
 CAST ( (Select spj2.process_name from sophos_process_journal spj2 where spj2.sophos_pid = spj.parent_sophos_pid) AS text) Parent_Process,
 CAST ( (Select spj2.cmd_line from sophos_process_journal spj2 where spj2.sophos_pid = spj.parent_sophos_pid) AS text) Parent_Cmd_Line,
 'low' As Potential_FP_chance,
 'Possible Rclone execution' As Description,
 'Process Journal/File/Users' AS Data_Source,
 'T1567.002 - rclone commandline' AS Query 
FROM sophos_process_journal spj 
WHERE parent_process IN ('cmd.exe', 'powershell.exe','wt.exe')
AND LOWER(process_name) NOT IN ('robocopy.exe', 'ipconfig.exe', 'xcopy.exe', 'net.exe', 'java.exe')
AND (cmd_line like '%-pass %' 
OR cmd_line like '%user %' 
OR cmd_line like '%copy %' 
OR cmd_line like '%sync %' 
OR cmd_line like '%config %' 
OR cmd_line like '%lsd %' 
OR cmd_line like '%remote %' 
OR cmd_line like '%ls %' 
OR cmd_line like '%rcd %' 
OR cmd_line like '%move %'
OR cmd_line like '%--transfer%'
OR cmd_line like '%--no-check-certificate %')
AND spj.time > $$start_time$$ 
AND spj.time < $$end_time$$