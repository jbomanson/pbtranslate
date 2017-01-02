#! /bin/bash

readarray -t a < <(compgen -c lpconvert)
((${#a} != 0)) && echo "${a[0]}"
