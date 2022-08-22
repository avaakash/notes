name=$1
kubectl logs -f $name -n litmus
