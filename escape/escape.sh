# Escape arguments for safe use as a shell parameter
EscapeShell() {
  echo "$*" | sed -e "s/'/'\\\\''/g; 1s/^/'/; \$s/\$/'/"
}
