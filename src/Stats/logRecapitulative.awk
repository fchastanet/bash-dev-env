BEGIN {
  currentProcessLogs = ""
  currentContainsLogs = 0
}
{
  buffer = substr($0, 1, 150)
  if(match(buffer, /PROCESS - Processing ([^ ]+) \([0-9]+\/[0-9]+\)/, arr) != 0) {
    processNameName = arr[1]

    currentProcessLogs = currentProcessLogs "\033[44m--- Process " processNameName " ---\033[0m\n"
  } else if(match(buffer, /(ERROR|SKIPPED|WARN|HELP|FATAL)[ ]+- /, arr) != 0) {
    currentContainsLogs = 1
    currentProcessLogs = currentProcessLogs $0 "\n"
  }
}
END {
  if (currentContainsLogs == 1) {
    printf currentProcessLogs
  }
}
