#!bin/bash
#The first parameters is used to determine the environment
#Execute as: ./log.sh ENV (test01,test02,test03...)
#bash ./log.sh test03
#IFS="\n"
user=$(whoami)
fecha=$(date '+%b %d')

        case $1 in
                dev01)  terminal="x9dev1"
                        user="usrdev01";;
                dev02)  terminal="x9dev2"
                        user="usrdev02";;
                dev03)  terminal="x9dev3"
                        user="usrdev03";;
                dev04)  terminal="x9dev4"
                        user="usrdev04";;
                dev05)  terminal="x9dev5"
                        user="usrdev05";;
                test01) terminal="y9test1"
                        user="usrtest01";;
                test02) terminal="y9test2"
                        user="usrtest02";;
                test03) terminal="y9test3"
                        user="usrtest03";;
                test04) terminal="y9test4"
                        user="usrtest04";;
                test05) terminal="y9test5"
                        user="usrtest05";;
                *)
        esac

command="ls -l /u01/app/om/$1/log/ | grep -v \"$fecha\" | grep -v sci | awk '{print \$9}' | xargs rm -rf ";
space="df -h . | tail -1 | awk '{print \"Current space: \"\$4}'"

ssh -q $user@$terminal "cd /u001/$1/log/; $space ; $command ; $space"
