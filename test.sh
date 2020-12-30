#!/bin/bash

echo -n "${green} Please type a version update type {major, minor, patch}: "
read UPDATE_TYPE

[[ "$UPDATE_TYPE" =~ ^(major|minor|patch|[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?)$ ]] || { echo "${red} Please Type One of {major, minor, patch}"; exit 1; } 

echo "ASDF"