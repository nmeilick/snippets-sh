#
# Convert a human readable string describing a duration or interval
# to seconds. Whitespace is ignored. Default unit is seconds.
# Float values are supported and rounded to three digits after
# comma.
#
# Arguments:
#   $1      - string to convert
#
# Result:
#   stdout: The number of seconds
#   stderr: Any errors that occur
#
# Return code:
#   0: Success
#   1: Error
#
# Example:
#   "1 year3mo 2w5days 3h2min5s2000000µs"
#
ParseDuration()
{
  local msecs=0

  set -- $(echo "$1" | sed "s/,/./g" | tr A-Z a-z | sed -r -e 's/([0-9.]+)/ \1 /g')
  while [ $# -gt 0 ]; do
    if ! num=$(LANG=C printf '%.3f' "$1" 2>/dev/null); then
      echo "Invalid number: $1" >&2
      return 1
    fi
    num=$(echo "$num" | sed 's/[.]//g')

    if [ $# -gt 1 ]; then
      case "$2" in
        ns|nsec|nsecs|nanosec|nanosecs|nsecond|nseconds|nanosecond|nanoseconds)     msecs=$((msecs+($num/1000000000))) ;;
        [µu]s|[µu]sec|[µu]secs|[µu]second|[µu]seconds)                              msecs=$((msecs+($num/1000000))) ;;
        ms|msec|msecs|millisec|millisecs|msecond|mseconds|millisecond|milliseconds) msecs=$((msecs+($num/1000))) ;;
        s|sec|secs|second|seconds|'')                                               msecs=$((msecs+$num)) ;;
        m|mi|min|mins|minute|minutes)                                               msecs=$((msecs+$num*60)) ;;
        h|hr|hrs|hour|hours)                                                        msecs=$((msecs+$num*60*60)) ;;
        d|dy|day|days)                                                              msecs=$((msecs+$num*60*60*24)) ;;
        w|wk|wks|week|weeks)                                                        msecs=$((msecs+$num*60*60*24*7)) ;;
        mo|mon|month|months)                                                        msecs=$((msecs+$num*60*60*24*30)) ;;
        y|yr|yrs|year|years)                                                        msecs=$((msecs+$num*60*60*24*365)) ;;
        *)
          echo "Unsupported unit: $2" >&2
          return 1;;
      esac
      shift
    else
      msecs=$((msecs+$num))
    fi


    if [ "$msecs" -lt 0 ]; then
      echo 'Overflow! The number is too large.' >&2
      return
    fi
    shift
  done
  echo "$((msecs/1000))"
}
