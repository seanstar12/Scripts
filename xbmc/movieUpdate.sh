#!/bin/bash

USER="xbmc"
PASS="xbmc"
PORT="8086"
IP=( 0.0.0.0 )

CURL_LOCATION="/usr/bin/curl"
XBMC_URL="xbmcCmds/xbmcHttp?command=ExecBuiltIn"

##Done with Variables## 
convert () {
  echo $1 | sed -e 's/ /%20/g'
}

notify () {
      echo "  Notifying XBMC: $1"
      $CURL_LOCATION -silent -output bleh --url \
      "http://$USER:$PASS@$1:$PORT/$XBMC_URL(Notification(Download%20Finished%20and%20Processed,$MOVIENAME))" \
      | grep -sq OK && echo -e "    --Notify Success\n" || echo -e "    --Notify Failed \n";
      
}

update () {
      error=0
      echo "  Updating XBMC: $1"
      $CURL_LOCATION -silent -output bleh --url \
      "http://$USER:$PASS@$1:$PORT/$XBMC_URL&parameter=XBMC.UpdateLibrary(video)" \
      | grep -sq OK && echo -e "    --Update Success\n" || echo -e "    --Update Failed \n"
}

failed () {
      echo "  Notifying XBMC: $1"
      $CURL_LOCATION -silent -output bleh --url \
      "http://$USER:$PASS@$1:$PORT/$XBMC_URL(Notification($2,$MOVIENAME))" \
      | grep -sq OK && echo -e "    --Notify Success\n" || echo -e "    --Notify Failed \n"
}

echo -e "\nMovie Script Started \n"

MOVIENAME=$(convert "$1")

echo -e "Converting name of Title to Variable for URL send: $MOVIENAME \n"

case "$7" in
  0)
    echo -e "Downloaded NZB: $2 from Group: $6"
    echo -e "Final Directory of Movie: $1\n"
    echo "Starting Notifications"

    for address in ${IP[@]}
      do
       notify $address
    done
   
    echo -e "Starting Database Update"
    for address in ${IP[@]}
      do
        update $address
    done
   
    echo "Processing succeeded for $1"
;;
  1)
    FAULT="Verification Failed"
    
    echo "Processing Failed: $FAULT"
    for address in ${IP[@]}
      do
        failed $address $(convert "$FAULT")
    done
;;
  2)
    FAULT="Unpack Failed"
    echo "Processing Failed: $FAULT"
    for address in ${IP[@]} 
      do
        failed $address $(convert "$FAULT")
    done
;;
  3)
    FAULT="Something went WAY wrong"
    echo "Processing Failed: $FAULT"
    for addresss in ${IP[@]}
      do    
        failed $address $(convert "$FAULT")
    done
;;
esac