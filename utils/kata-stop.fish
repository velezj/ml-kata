#!/usr/bin/env fish

set datapath "$XDG_DATA_HOME/kata"
if expr ( set --query XDG_DATA_HOME ; echo $status ) \> 0 >/dev/null
    set datapath ~/.local/share/kata
end
set history_savepoint_path "$datapath/stop.history"
set history_start_path "$datapath/start.history"

# test for parity of commands
set startmod (stat -c "%Y" $history_start_path)
set stopmod (stat -c "%Y" $history_savepoint_path)
if test $stopmod -gt $startmod
    echo "You must start a Kata before stopping it"
    exit 1
end

#echo "saving stop timestamp"
date +"%s" > "$datapath/stop.timestamp"
date -R >> "$datapath/stop.timestamp"


#echo "saving history stop context in $history_savepoint_path"
mkdir -p ( dirname $history_savepoint_path )
history merge
history search --show-time > $history_savepoint_path

# grab history between the start and top of the kata
set history_diff_path "$datapath/diff.history"
awk (echo -s "BEGIN{KLINE = \"" (cat $history_start_path | head -n1) "\"} \$0 ~ KLINE {exit} ; {print \$0}") $history_savepoint_path > $history_diff_path

echo "Kata Stopped"
