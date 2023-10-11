echo "Closing deployment"

## === broadcast tx === ##
TX=$(echo "${PASSWORD}" | ${CLIENT} tx deployment close | jq -r '.txhash')
if test -z $TX; then
  echo "No TX broadcasted!"
  exit 1
fi
echo "TX: $TX"
sleep ${BLOCK_TIME}
RC=$(${CLIENT} query tx $TX | jq -r '.code')
case $RC in
  0)
    echo "TX successful"
    ;;
  11)
    echo "Out of gas! Consider raising AKASH_GAS_ADJUSTMENT and trying again."
    exit 1
    ;;
  *)
    echo "Transaction $TX failed with code: '$RC'"
    exit 1
    ;;
esac
## === broadcast tx === ##