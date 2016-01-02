mtail is a simple bash script that tails multiple files at once.

that's usefull if, for example, you have no clue which logfile to look at :-)


```
usage:
   mtail [file] [file] [file] [...]
```

When called without any parameters, mtail will locate all `*`log files and tail them all.
That's probably a bit too much. Edit the script to change its defaults.