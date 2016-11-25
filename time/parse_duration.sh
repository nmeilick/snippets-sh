#
# Convert a human readable strings to seconds
# Whitespace is ignored. Default unit is seconds.
#
# Arguments:
#   $1      - string to convert
#
# Result:
#   stdout: The number of seconds
#   stderr: Any errors that occur
#
# Example:
#   "1 year 2w5days 3h2min5"
#
parse_duration()
{
  local secs=0

  set -- $(echo "$1" | tr A-Z a-z | sed -r -e 's/([0-9.]+)/ \1 /g')
  while [ $# -gt 0 ]; do
    case "$1" in
      [0-9].*|.[0-9]*)
        echo "Floating point numbers are not supported: $1" 1>&2
        return ;;
      [0-9]*)
        if [ $# -gt 1 ]; then
          case "$2" in
            s|sec|secs|second|seconds|'') secs=$((secs+$1)) ;;
            m|min|mins|minute|minutes)    secs=$((secs+$1*60)) ;;
            h|hr|hrs|hour|hours)          secs=$((secs+$1*60*60)) ;;
            d|day|days)                   secs=$((secs+$1*60*60*24)) ;;
            w|wk|week|weeks)              secs=$((secs+$1*60*60*24*7)) ;;
            mo|mon|month|months)          secs=$((secs+$1*60*60*24*30)) ;;
            y|yr|year|years)              secs=$((secs+$1*60*60*24*365)) ;;
            *)
              echo "Unsupported unit: $2" 1>&2
              return ;;
          esac
          shift
        else
          secs=$((secs+$1))
        fi ;;
      *)
        echo "Not a number: $1" 1>&2
        return ;;
    esac
    if [ "$secs" -lt 0 ]; then
      echo 'Overflow!' 1>&2
      return
    fi
    shift
  done
  echo "$secs"
}
