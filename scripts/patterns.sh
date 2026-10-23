# SPDX-License-Identifier: Apache-2.0
# Sensitive patterns, shared by guardrails.sh (sources) and check-pdf.sh (built PDF text).
# Extended regular expressions; a line matching SENSITIVE_ALLOW is not reported.
SENSITIVE_PATTERNS=(
  'AKIA[0-9A-Z]{16}'                          # AWS access key id
  'dt0[a-z][0-9]{2}\.[A-Z0-9]{24}'             # Dynatrace token
  'gh[pousr]_[A-Za-z0-9]{30,}'                 # GitHub token
  'xox[baprs]-[A-Za-z0-9-]{10,}'               # Slack token
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'            # IPv4
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' # e-mail
  '\b[a-z0-9-]+\.(internal|corp|local|lan)\b'  # internal hostnames
  '\.live\.dynatrace\.com|\.apps\.dynatrace\.com' # tenant URLs
)
SENSITIVE_ALLOW='@bogomazov\.us|scripts/patterns\.sh'
