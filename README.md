# Container to convert files using HandBrake-CLI

Container to automatically convert files.  Container will watch a directory and whenever a file is put into that directoy
it will convert it to a new file using the specificed options and outputing it to a second folder.  The source can 
optionally be deleted after conversion.



Evinronment Variables:

HANDBRAKE_OPTIONS - Options passed to HandBrake-CLI (default: " --preset \"H.264 MKV 720p30\" --native-language eng")
THREADS - Number of jobs to queue up simultaniously (default: 2)
DELETE_SOURCE - Should source file be deleted after conversion (default: no)
FILE_TYPE - File extension of output file (default: mkv)

Example to run:
```
docker run -d \
           --name handbrake \
           -v <watch directory>:/watch \
           -v <output directory>:/output \
           --env DELETE_SOURCE=yes
           --env HANDBRAKE_OPTIONS="--long --list --of --options" \
           apnar/handbrake-watcher
```


Default Handbrake settings borrowed from jbebel at the Pacifica Forums:
http://www.pacificaforums.com/forum/384721-post108.html
 
