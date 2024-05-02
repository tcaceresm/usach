#!/usr/bin/bash

python3 ./assess_normalized_dope.py | grep -i 'normalized\|model number' > normalized_dope_scores.txt
