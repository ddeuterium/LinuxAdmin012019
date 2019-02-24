#!/bin/bash
# Analog of 'ps ax' command (report a snapshot of the current processes) 
#

# Gets sequence of pids from /proc and output columns of values
function unionr {
    PID=$*
    for i in $PID
    do
        # Uses tree directives on procfs "/proc/$PID/stat", "/proc/$PID/environ" and "/proc/$PID/fd/"
        if [[ -e /proc/$i/environ && -e /proc/$i/stat ]]; then

            cd /proc
            
            # Get VALUES
            # Field PID
            FPid=`cat $i/stat | awk '{ printf "%7d", $1 }'`

            # Field TTY
            Tty_nr=`awk '{print $7}' /proc/$i/stat`

            # Field STATE
            FState=`cat $i/stat | awk '{ printf "%1s", $3 }'`
            SLead=`cat $i/stat | awk '{ printf $6 }'`
            Nice=`cat $i/stat | awk '{ printf $19 }'` 
            Threads=`cat $i/stat | awk '{ printf $20 }'`
            VmLPages=`grep VmFlags $i/smaps | grep lo`
            ProcGrForegr=`cat $i/stat | awk '{ printf $8 }'`

            # Field COMMAND
            FCommand=`cat $i/cmdline | awk '{ printf "%10s", $1 }'`

            # Field STAT
            ## Flag 'l'(threads)
            [[ $Threads -gt 1 ]] && Threads='l' || Threads=''
            ## Flag 'L'(vm lock pages)
            [[ -n $VmLPages ]] && VmLPages='L' || VmLPages=''
            ## Flag '+' foreground process group
            [[ $ProcGrForegr -eq "-1" ]] && ProcGrForegr='' || ProcGrForegr='+'
            ## Flag 's' session leader
            [[ $SLead -eq $i ]] && SLead='s' || SLead=''
            ## Flag '<' or 'N' priority (the lowest pri. is 20 and the highest pri. is -19)
            if [[ $Nice -lt 0 ]]; then Nice='<'; elif [[ $Nice -gt 0 ]]; then Nice='N'; else Nice=''; fi
            
            # Field TTY
            ## Flag 'pts|tty' or tty_nr - terminal tty which uses process (pseudo terminal slave and teletype)
            [[ Tty_nr -eq 0 ]] && TTY='?' || TTY=`ls -l $i/fd/ | grep -E 'tty|pts' | cut -d\/ -f3,4 | uniq`
            
            # Field COMMAND, second try to find command
            [[ -z $FCommand ]] && FCommand=`cat $i/stat | awk '{ printf "%10s", $2 }' | tr '(' '[' | tr ')' ']'`
        fi

        # Output of result
        # 
        Stat="$FState$Nice$SLead$Threads$VmLPages$ProcGrForegr"
        printf "%5d %-6s %-7s %s\n" "$FPid" "$TTY" "$Stat" "$FCommand"
    done
}

# Get only digits to $PID
PID=`ls /proc | grep -E '[[:digit:]]' | sort -n | xargs`
# Output 1st line as header of columns
echo "  PID TTY    STAT    COMMAND"
# Output values(parametrs) of $PIDs
unionr $PID


