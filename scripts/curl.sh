url=$1
while :
do
  sleep 2
  #curl -o /dev/null -s -w 'Connect: %{time_connect}\nLookup: %{time_namelookup}\nTransfer: %{time_starttransfer}\nTotal:%{time_total}\n\n\n' $url
  curl -o /dev/null -s -w 'Status Code: %{http_code}\n' $url
done
