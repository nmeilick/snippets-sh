#
# Convert size in bytes to a human readable string
#
# Options:
#   --si                     Use SI units (10^x instead of 2^x, 1 Megabyte = 1000000 bytes)"
#   -P, --precision NUM      Round size to NUM decimal places (Default: 2)"
#   -h, --help               Display help text"
#
# First non-option argument:
#   Size in bytes
#
# Result:
#   stdout: The human readable size
#   stderr: Any errors that occur
#
# Return code:
#   0: Success
#   1: Error
#
FormatSize()
{
  local num=
  local m=1024
  local precision=2

  while [ $# -gt 0 ]; do
    case "$1" in
      -[a-zA-Z]*|--[a-zA-Z]*)
        case "$1" in
          -h|--help)
            echo "Syntax: FormatSize [OPTIONS] SIZE"
            echo ""
            echo "Valid options:"
            echo ""
            echo "  --si                     Use SI units (10^x instead of 2^x, 1 Megabyte = 1000000 bytes)"
            echo "  -P, --precision NUM      Round size to NUM decimal places (Default: $precision)"
            echo ""
            echo "  -h, --help        Display this help text"
            echo
            return 1
            ;;
          --si) m=1000 ;;
          -P|--precision)
            if [ "$#" = 1 -o -z "$2" ]; then
              echo "Error: $1: Missing argument" >&2
              return 1
            fi
            precision="$2"
            shift
            ;;
          *)
            echo "Invalid argument: $1" >&2
            return 1
            ;;
        esac
        ;;
      *)
        if [ -n "$num" ]; then
          echo "Error: $1: Extraneous argument" >&2
          return 1
        fi
        num="$1"
        ;;
    esac
    shift
  done

  n=0
  val="$num"
  pval="$num"
  while true; do
    val=$(awk "BEGIN { printf(\"%.${precision}f\", $val/$m) }")
    if [ "$n" = 8 ]; then
      val=0
    fi
    case "$val" in
      0*)
        case "$n" in
          0) echo "${val}KB" ;;
          1) echo "${pval}KB" ;;
          2) echo "${pval}MB" ;;
          3) echo "${pval}GB" ;;
          4) echo "${pval}TB" ;;
          5) echo "${pval}PB" ;;
          6) echo "${pval}EB" ;;
          7) echo "${pval}ZB" ;;
          8) echo "${pval}YB" ;;
        esac
        return 0
        break
        ;;
    esac
    pval="$val"
    n=$((n+1))
  done
}
