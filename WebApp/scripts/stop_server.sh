#!/bin/bash
isExistApp = `pgrep httpd`
if [[ -n  $isExistApp ]]; then
    service httpd stop 
    sudo rm -f /var/www/html/index.html
fi



