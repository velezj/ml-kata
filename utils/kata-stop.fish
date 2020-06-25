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
date -Is >> "$datapath/stop.timestamp"
set timestring (cat "$datapath/stop.timestamp" | tail -n1)
set record_path "$datapath/records/kata-$timestring.record"

#echo "saving history stop context in $history_savepoint_path"
mkdir -p ( dirname $history_savepoint_path )
history merge
history search --show-time > $history_savepoint_path

# stop http dump
set http_dump_path "$datapath/start.http.tcpdump"
set http_dump_pid_path "$datapath/start.http.tcpdump.pid"
set http_dump_pid (cat $http_dump_pid_path)
sudo kill --signal SIGTERM $http_dump_pid
while test -d /proc/$http_dump_pid
    sleep "0.5s"
end

# grab history between the start and top of the kata
set history_diff_path "$datapath/diff.history"
awk (echo -s "BEGIN{KLINE = \"" (cat $history_start_path | head -n1) "\"} \$0 ~ KLINE {exit} ; {print \$0}") $history_savepoint_path > $history_diff_path

# package into a kata record
mkdir -p $record_path
cp "$http_dump_path" "$record_path/http.tcpdump"
cp "$history_diff_path" "$record_path/history"
cp "$datapath/stop.timestamp" "$record_path/stop.timestamp"
cp "$datapath/start.timestamp" "$record_path/start.timestamp"

echo "Kata Stopped, record at '$record_path'"
