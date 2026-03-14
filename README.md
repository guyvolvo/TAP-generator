# TAP-generator
Powershell script that utilizes graph to generate a temporary password for a user\
Usage:
`.\temp-pass.ps1 'user@domain.com'`


**You muse have a group with a dedicated Temporary pass rule to add members to**\
And then change this in the script: 
`$GroupId = "CHANGE_TO_YOUR_TEMP_PASS_GROUP_ID (f4673c290-d89172... etc. for example"`
