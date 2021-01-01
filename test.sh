#!/bin/bash
echo "["ASDF","VBAVA"]" | grep A  
[ $? = 0 ] && echo "ASDF"