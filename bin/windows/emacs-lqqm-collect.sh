#!/bin/bash
grep '��  ��\|http.*8080'|perl -npe 's!(http:.*8080)!<img src=\1!; s!$!></src><p>!' >>~/lqqm.html


