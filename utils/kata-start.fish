#!/usr/bin/env fish

# save the current history timestamp (a few lines)
set num_lines_for_context 3
set datapath "$XDG_DATA_HOME/kata"
if expr ( set --query XDG_DATA_HOME ; echo $status ) \> 0 >/dev/null
    set datapath ~/.local/share/kata
end
set history_savepoint_path "$datapath/start.history"
set history_stop_path "$datapath/stop.history"

# test for parity of commands
set startmod (stat -c "%Y" $history_savepoint_path)
set stopmod (stat -c "%Y" $history_stop_path)
if test $startmod -gt $stopmod
    echo "You must stop a Kata before starting it"
    exit 1
end

#echo "saving history start context in $history_savepoint_path"
mkdir -p ( dirname $history_savepoint_path )
history merge
history search --show-time | head -n ( expr $num_lines_for_context \* 2 ) > $history_savepoint_path

#echo "saving start timestamp"
date +"%s" > "$datapath/start.timestamp"
date -R >> "$datapath/start.timestamp"

echo "Kata Started"
