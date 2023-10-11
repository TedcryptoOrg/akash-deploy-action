unset AKASH_DSEQ
echo "Find and close all stale deployment requests if any (to release the deposited AKT from escrow account)"
# add "--gseq 0 --oseq 0" -- to catch all (for future placement groups support)
${CLIENT} query market order list | jq -r '.orders[] | select(.state == "open") | .order_id.dseq' |
  while read AKASH_DSEQ; do
    export AKASH_DSEQ
    LEASE_STATE=$(${CLIENT} query market lease list | jq -r '.leases[].lease.state')
    if test -z "$LEASE_STATE" || [[ "$LEASE_STATE" == "closed" ]]; then

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

    fi  ## if test -z $LEASE_STATE || [[ "$LEASE_STATE" == "closed" ]];
  done  ## while read AKASH_DSEQ;