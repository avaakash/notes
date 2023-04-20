url=$1
while :
do
  sleep 2
  #curl -o /dev/null -s -w 'Total:%{time_total}\n\n\n' $url
  curl -o /dev/null -s -w 'Status Code: %{http_code}\n' $url
done
