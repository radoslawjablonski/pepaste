alias 'dk'='sudo docker'
alias 'dkim'='sudo docker images'
alias 'dkps'='sudo docker ps -a'
alias 'dkls'="sudo docker images|pepaste -c '1,2' -s ':'"
alias 'dkrm_all_running'='sudo docker rm -f `sudo docker ps|omit-header|pepaste -c 1`'
alias 'dkrm_empty_im'='sudo docker images|perl -ane '\''print "$F[2] " if $F[0] eq "<none>"'\''|xargs sudo docker rmi'

# omit one line
# perl -ne 'print if $. > 1'
alias 'omit-header'='perl -ne '\''print if $. > 1'\''   '
