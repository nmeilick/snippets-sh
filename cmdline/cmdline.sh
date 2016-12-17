# If $1 is a option in the format --option=..., set 'arg' to the
# option value and return true, otherwise set arg empty and return
# false. 'arg' should be a local variable in the calling function.
GetOptionArg() {
  case "$1" in
    ?*=*)
      arg="${1#*=}"
      return 0 ;;
    *)
      arg=''
      return 1 ;;
  esac
}

# Return true if the argument is a option in the format --option=...
OptionHasArg() {
  case "$1" in
    ?*=*) return 0 ;;
    -*) [ $# -gt 1 ] ;;
  esac
}

# Return true if the first argument is a option in the format --option=...
# with a non-empty value or if is there is more than one argument and the
# second one is non-empty.
OptionHasNonEmptyArg() {
  case "$1" in
    ?*=*) [ -n "${1#*=}" ] ;;
    -*) [ -n "$2" ] ;;
  esac
}

# Return true if there is an option with argument in $2..$3, otherwise
# log an error with the given prefix ($1) and return false.
OptionNeedArg() {
  local prefix="$1"
  shift

  if OptionHasArg "$@"; then
    return 0
  fi
  echo "Argument missing: ${1%%=*}" 1>&2
  return 1
}

# Return true if there is an option with non-empty argument in $2..$3,
# otherwise log an error with the given prefix ($1) and return false.
OptionNeedNonEmptyArg() {
  local prefix="$1"
  shift

  if OptionNeedArg "$prefix" "$@"; then
    if OptionHasNonEmptyArg "$@"; then
      return 0
    else
      echo "Argument may not be empty for option ${1%%=*}"
      return 1
    fi
  else
    return 1
  fi
}

CommandLineParser()
{
  local func="CommandLineParser"
  local arg

  while [ $# -gt 0 ]; do
    case "$1" in
      --) break ;;
      -r|--reset) reset=1 ;;
      -f|--file|--file=*)
        OptionNeedArg "$func" "$@" || return 1
        GetOptionArg "$1" || arg="$2"  && shift
        ;;
     -h|--help)
        echo "Syntax: FC_SetupErrorHandler [OPTIONS]"
        echo
        echo "Valid options:"
        echo "   -r, --reset               Reset options to their default (should be first argument)"
        echo
        echo "   -e, --stderr              Log errors to stderr"
        echo "   -E, --no-stderr           Do not log errors to stderr"
        echo "   -f, --file FILE           Log errors to this file (empty = disabled)"
        echo
        echo "   -s, --strip-func          Strip function name from error messages"
        echo "   -S, --no-strip-func       Do not strip function names from error messages"
        echo
        echo "   -F, --filter FUNC         Function filtering the error message"
        echo
        echo "   -p, --prefix TEXT         Prepend the given text"
        echo "   -d, --date                Prepend the current date"
        echo "   -D, --no-date             Do not Prepend the current date"
        echo "       --date-format TEXT    Format string to format date"
        echo
        return 0
        ;;
      -*)
        FC_LogError "$func: Invalid option: $1"
        return 1 ;;
      *)
        if [ $url_was_set = 1 ]; then
          FC_LogError "$func: More than one URL specified: '$1'"
          return 1
        fi
        url="$1" url_was_set=1 ;;
    esac
    shift
  done
}
