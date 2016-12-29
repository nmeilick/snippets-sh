#
# Convert a human readable string describing a size or throughput
# to bytes. All components are added. Whitespace is ignored.
# Float values are supported and only rounded at the end to the
# nearest byte.
#
# All common units are supported, short or long forms,
# Please notice that case is ignored, so MB and Mb are
# both considered megabyte.
#
# Options:
#   --si                     Use SI units (10^x instead of 2^x, 1 Megabyte = 1000000 bytes)"
#   -b, --byte               Return size in byte (Default)"
#   -k, --kb, --kilobyte     Return size in kilobyte"
#   -m, --mb, --megabyte     Return size in megabyte"
#   -g, --gb, --gigabyte     Return size in gigabyte"
#   -t, --tb, --terabyte     Return size in terabyte"
#   -p, --pb, --petabyte     Return size in petabyte"
#   -e, --eb, --exabyte      Return size in exabyte"
#   -z, --zb, --zettabyte    Return size in zettabyte"
#   -y, --yb, --yottabyte    Return size in yottabyte"
#   -P, --precision NUM      Round size to NUM decimal places (Default: 0)"
#   -h, --help               Display help text"
#
# First non-option argument:
#   String to convert
#
# Result:
#   stdout: The number of bytes
#   stderr: Any errors that occur
#
# Return code:
#   0: Success
#   1: Error
#
# Example:
#   "1.5TB 10MB 20000Mbit 3TiB"
#
ParseSize()
{
  local bits=0
  local calc=
  local m=1024
  local div=1
  local precision=0
  local num=

  while [ $# -gt 0 ]; do
    case "$1" in
      -[a-zA-Z]*|--[a-zA-Z]*)
        case "$1" in
          -h|--help)
            echo "Syntax: ParseSize [OPTIONS] SIZE..."
            echo ""
            echo "Valid options:"
            echo ""
            echo "  --si                     Use SI units (10^x instead of 2^x, 1 Megabyte = 1000000 bytes)"
            echo ""
            echo "  -b, --byte               Return size in byte (Default)"
            echo "  -k, --kb, --kilobyte     Return size in kilobyte"
            echo "  -m, --mb, --megabyte     Return size in megabyte"
            echo "  -g, --gb, --gigabyte     Return size in gigabyte"
            echo "  -t, --tb, --terabyte     Return size in terabyte"
            echo "  -p, --pb, --petabyte     Return size in petabyte"
            echo "  -e, --eb, --exabyte      Return size in exabyte"
            echo "  -z, --zb, --zettabyte    Return size in zettabyte"
            echo "  -y, --yb, --yottabyte    Return size in yottabyte"
            echo ""
            echo "  -P, --precision NUM      Round size to NUM decimal places (Default: 0)"
            echo ""
            echo "  -h, --help        Display this help text"
            echo
            return 1
            ;;
          --si) m=1000 ;;
          -k|--kb|--kilobyte)  div='x' ;;
          -m|--mb|--megabyte)  div='x*x' ;;
          -g|--gb|--gigabyte)  div='x*x*x' ;;
          -t|--tb|--terabyte)  div='x*x*x*x' ;;
          -p|--pb|--petabyte)  div='x*x*x*x*x' ;;
          -e|--eb|--exabyte)   div='x*x*x*x*x*x' ;;
          -z|--zb|--zettabyte) div='x*x*x*x*x*x*x' ;;
          -y|--yb|--yottabyte) div='x*x*x*x*x*x*x*x' ;;
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

  if [ -z "$num" ]; then
    echo "Error: Please specify the string to convert" >&2
    return 1
  fi

  set -- $(echo "$num" | sed "s/,/./g" | tr A-Z a-z | sed -r -e 's/([0-9.]+)/ \1 /g')
  while [ $# -gt 0 ]; do
    num="$1"

    if [ $# -gt 1 ]; then
      case "$2" in
        bit|bits|bps)                                                factor='1' ;;
        b|byte|bytes)                                                factor='8' ;;

        kibi|kibis|ki|kis|kibibit|kibibits|kibit|kibits)            factor='1024' ;;
        mebi|mebis|mi|mis|mebibit|mebibits|mibit|mibits)            factor='1024*1024' ;;
        gibi|gibis|gi|gis|gibibit|gibibits|gibit|gibits)            factor='1024*1024*1024' ;;
        tebi|tebis|ti|tis|tebibit|tebibits|tibit|tibits)            factor='1024*1024*1024*1024' ;;
        pebi|pebis|pi|pis|pebibit|pebibits|pibit|pibits)            factor='1024*1024*1024*1024*1024' ;;
        exbi|exbis|ei|eis|exbibit|exbibits|eibit|eibits)            factor='1024*1024*1024*1024*1024*1024' ;;
        zebi|zebis|zi|zis|zebibit|zebibits|zibit|zibits)            factor='1024*1024*1024*1024*1024*1024*1024' ;;
        yobi|yobis|yi|yis|yobibit|yobibits|yibit|yibits)            factor='1024*1024*1024*1024*1024*1024*1024*1024' ;;

        kibib|kibibs|kib|kibs|kibibyte|kibibytes|kibyte|kibytes)    factor='8*1024' ;;
        mebib|mebibs|mib|mibs|mebibyte|mebibytes|mibyte|mibytes)    factor='8*1024*1024' ;;
        gibib|gibibs|gib|gibs|gibibyte|gibibytes|gibyte|gibytes)    factor='8*1024*1024*1024' ;;
        tebib|tebibs|tib|tibs|tebibyte|tebibytes|tibyte|tibytes)    factor='8*1024*1024*1024*1024' ;;
        pebib|pebibs|pib|pibs|pebibyte|pebibytes|pibyte|pibytes)    factor='8*1024*1024*1024*1024*1024' ;;
        exbib|exbibs|eib|eibs|exbibyte|exbibytes|eibyte|eibytes)    factor='8*1024*1024*1024*1024*1024*1024' ;;
        zebib|zebibs|zib|zibs|zebibyte|zebibytes|zibyte|zibytes)    factor='8*1024*1024*1024*1024*1024*1024*1024' ;;
        yobib|yobibs|yib|yibs|yobibyte|yobibytes|yibyte|yibytes)    factor='8*1024*1024*1024*1024*1024*1024*1024*1024' ;;

        kbit|kbits|kilobit|kilobits|kbps)                            factor="$m" ;;
        mbit|mbits|megabit|megabits|mbps)                            factor="$m*$m" ;;
        gbit|gbits|gigabit|gigabits|gbps)                            factor="$m*$m*$m" ;;
        tbit|tbits|terabit|terabits|tbps)                            factor="$m*$m*$m*$m" ;;
        pbit|pbits|petabit|petabits|pbbs)                            factor="$m*$m*$m*$m*$m" ;;
        ebit|ebits|exabit|exabits|epbs)                              factor="$m*$m*$m*$m*$m*$m" ;;
        zbit|zbits|zetttabit|zettabits|zpbs)                         factor="$m*$m*$m*$m*$m*$m*$m" ;;
        ybit|ybits|yottabit|yottabits|ypbs)                          factor="$m*$m*$m*$m*$m*$m*$m*$m" ;;

        k|kb|kbyte|kbytes|kilobyte|kilobytes)                        factor="8*$m" ;;
        m|mb|mbyte|mbytes|megabyte|megabytes)                        factor="8*$m*$m" ;;
        g|gb|gbyte|gbytes|gigabyte|gigabytes)                        factor="8*$m*$m*$m" ;;
        t|tb|tbyte|tbytes|terabyte|terabytes)                        factor="8*$m*$m*$m*$m" ;;
        p|pb|pbyte|pbytes|petabyte|petabytes)                        factor="8*$m*$m*$m*$m*$m" ;;
        e|eb|ebyte|ebytes|exabyte|exabytes)                          factor="8*$m*$m*$m*$m*$m*$m" ;;
        z|zb|zbyte|zbytes|zetttabyte|zettabytes)                     factor="8*$m*$m*$m*$m*$m*$m*$m" ;;
        y|yb|ybyte|ybytes|yottabyte|yottabytes)                      factor="8*$m*$m*$m*$m*$m*$m*$m*$m" ;;

        *)
          echo "Unsupported unit: $2" >&2
          return 1;;
      esac
      shift
    else
      factor='8'
    fi

    bits=$(awk "BEGIN { printf(\"%f\", $bits + $num * $factor) }")
    shift
  done
  if [ -n "$div" ]; then
    div=$(echo "$div" | sed "s/x/$m/g")
    bits=$(awk "BEGIN { printf(\"%f\", $bits / ($div)) }")
  fi

  awk "BEGIN { printf(\"%.${precision}f\n\", $bits/8) }"
}
