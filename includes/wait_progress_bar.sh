#!/bin/bash

pause ()
{
  echo -ne '\n['
  COUNTER=$1
  until [  $COUNTER -lt 0 ]; do
    echo -ne ' '
    let COUNTER-=1
  done
  echo -ne "] Wait for $1 seconds...\r"
  echo -ne '['
  COUNTER=$1
  until [  $COUNTER -lt 0 ]; do
    echo -ne '|'
    sleep 1
    let COUNTER-=1
  done
  echo -e ']\n'
}

