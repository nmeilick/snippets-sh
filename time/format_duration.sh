#
# Convert seconds to a human readable string
#
# Arguments:
#   $1      - number of seconds
#   $2      - units to use (ywdhms)
#
# Result:
#   stdout: The duration
#   stderr: Any errors that occur
#
format_duration()
{
  local secs="$1"
  local validunits=$(echo "${2:-ywdhms}" | tr A-Z a-z)
  local text=
  local div
  local unit

  for x in y:31536000 w:604800 d:86400 h:3600 m:60 s:1; do
    unit="${x%:*}" div="${x#*:}"

    case "$validunits" in
      ""|*$unit*)
        if [ "$secs" -ge $div ]; then
          text="$text$((secs/$div))$unit"
          secs=$((secs%$div))
        fi
        ;;
    esac
  done
  [ -z "$text" ] && text="${secs}s"
  echo "$text"
}
