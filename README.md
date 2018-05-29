# pepaste
Perl-based tool for advanced parsing of data on the fly. It can be used for parsing files but it also can handle data from pipe stream.

## Usage:
pepaste [-vh ] [ --num-words|-n NUM ] [ --split-delim|-d ' ' ] [ --match-word|-m '/match/' ] [ --match-line-regex|-M '/match/' ] [ --end-line-prefix|-e '' ] [ --output-word-separator|-w ' ' ] input_file


## Examples:
**$ ls /|pepaste**

Will split incoming data from 'ls /' command for 2 items space separated on each line by default.

**$ ls /|pepaste -n 4**

Same as above but data will be shown on 4 columns in each line

**$ cat data.txt|pepaste -n 4 -m '/^a/'**

It will show 4 items in each line but only items that matching regex '/^a/'(starting with letter 'a') will be printed, rest will be filtered out

**$ cat data.txt|pepaste -n 3 -e '\\'**

Data will be shown in thee columns and on each end of line ' \' sequence will be printed out:
aa bb cc \
dd ee


**$ cat data.txt|pepaste -n 3 -e '\\' -w ','**

Same as above but items will be separated with commas instead of spaces:
aa,bb,cc \
dd,ee
