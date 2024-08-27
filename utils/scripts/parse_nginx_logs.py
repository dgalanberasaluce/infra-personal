# Parses a nginx log file and write the output to a json file
import sys
import re
import json

if len(sys.argv) == 1:
    sys.stdout.write("Usage: %s <file_name>\n"%sys.argv[0])
    sys.exit(0)

filename = sys.argv[1]
log_filename = f"{filename}.log"
output_filename = f"{filename}.json"

print(f"Reading file: {log_filename}")
print(f"Writing to file: {output_filename}")

log_pattern = (
    r'(?P<remote_addr>\S+) - (?P<remote_user>\S*) \[(?P<time_local>[^\]]+)\] "(?P<request>[^"]*)"\s+'
    r'(?P<status>\d+) (?P<body_bytes_sent>\d+) "(?P<http_referer>[^"]*)" "(?P<http_user_agent>[^"]*)"\s+'
    r'(?P<request_length>\d+) (?P<request_time>[0-9.]+) \[(?P<proxy_upstream_name>[^\]]*)\] \[(?P<proxy_alternative_upstream_name>[^\]]*)\]\s+'
    r'(?P<upstream_addr>-|\S*) (?P<upstream_response_length>-|\d*) (?P<upstream_response_time>-|[0-9.]*) (?P<upstream_status>-|\d*) (?P<req_id>\S+)'
)


with open (f"{filename}-errors.log","w") as errors:
  with open(f"{output_filename}", "w") as json_file:
    with open(log_filename, 'r') as log_file:
     for line in log_file:
        m = re.match(log_pattern, line)
        if m:
           log_fields = m.groupdict()
           json_file.write(json.dumps(log_fields) + '\n')
        else:
            errors.write(line)