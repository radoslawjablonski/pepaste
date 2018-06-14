# pepaste
Perl-based tool for advanced parsing of data on the fly. It can be used for parsing incoming pipe streams, similar way to 'paste' unix tool but with way more options like regex matching and with more control over formatting output data 

## Usage:
pepaste [-vh ] [ --num-words|-n NUM ]                                                                                                                     
[ --columns-selected|-c ]                                                                                                                                                  
[ --split-delim|-d ' ' ]                                                                                                                                                   
[ --match-word-regex|-w 'regex_match(without //)' ]                                                                                                                        
[ --exclude-word-regex|-W 'no_match_regex(without //)']                                                                                                                    
[ --exclude-line-regex|-L 'no_match_regex(without //)']                                                                                                                    
[ --match-line-regex|-l 'regex_match(without //)' ]                                                                                                                        
[ --end-line-string|-e '' ]                                                                                                                                                
[ --out-of-bounds-str|-o '']                                                                                                                                               
[ --output-word-separator|-s ' ' ]                                                                                                                                         
[ --version ]                    


## Examples:
1. Calling 'pepaste' without arguments by default will put every word found on input (no matter if found in same line or in next line) and use single space as a separator. In other words, behavior will be similar to *paste -sd " "* command
```
$ ls /|pepaste
bin boot cdrom dev etc home initrd.img lib lib64 lost+found media mnt opt proc root run sbin snap srv sys tmp usr var vmlinuz
```

2. Output entries can be grouped in lines using *-n* parameter - we can set how many elements(columns) will be printed in each line
```
$ ls /|pepaste -n 3
in boot cdrom
dev etc home
initrd.img lib lib64
lost+found media mnt
opt proc root
run sbin snap
srv sys tmp
usr var vmlinuz
```


3. There is possibility to put custom char sequence on the end of each line using *-e ''* parameter. It is quite handy when content has to be pasted into some script and interpreted as one very long line. 
```
$ ls /|pepaste -n 3 -e ' \'                                                                                                             
bin boot cdrom \
dev etc home \
initrd.img lib lib64 \
lost+found media mnt \
opt proc root \
run sbin snap \
srv sys tmp \
usr var vmlinuz \

```

4. If some words should be removed, it can be done via regex using *-W* parameter. Big *-W* is for entries that have to be removed (everything else will be accepted), small *-w* works in opposite way. As an example let's remove entries starting with *b* letter (*bin* and *boot* should dissapear):
```
$ ls /|pepaste -n 3 -e ' \' -W "^b"                                                                                                     
cdrom dev etc \
home initrd.img lib \
lib64 lost+found media \
mnt opt proc \
root run sbin \
snap srv sys \
tmp usr var \
vmlinuz \
```
...or show only words that contain special (non-word) characters:
```
ls /|pepaste -n 3 -e ' \' -w "\W"                                                                                                     
initrd.img lost+found \
```
