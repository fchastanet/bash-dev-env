BEGIN {
  error=0
  warning=0
  skipped=0
  help=0
  success=0
}
{
  buffer = substr($0, 1, 20)
  if(match(buffer, /(ERROR)[ ]+- /, arr) != 0) {
    error+=1
  } else if(match(buffer, /(WARNING)[ ]+- /, arr) != 0) {
    warning+=1
  } else if(match(buffer, /(SKIPPED)[ ]+- /, arr) != 0) {
    skipped+=1
  } else if(match(buffer, /(ERROR)[ ]+- /, arr) != 0) {
    error+=1
  } else if(match(buffer, /(HELP)[ ]+- /, arr) != 0) {
    help+=1
  } else if(match(buffer, /(SUCCESS)[ ]+- /, arr) != 0) {
    success+=1
  }

}
END {
  print "error=" error
  print "warning=" warning
  print "skipped=" skipped
  print "help=" help
  print "success=" success
}
