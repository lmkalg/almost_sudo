# Almost-Sudo

## Disclaimer

This tiny script which performs an temporary sudo-alias was developed just with awareness and educational intentions.
Was tested in Ubuntu environments, using either BASH or ZSH shells.


## Requirements

* Access to a user shell (Most likely to a sudoer user)
* GPG, netcat installed.
* Network access to shared server.
* Public PGP-key server in the HTTP Server need to be called "pentesting_issues.pdf" (hardcoded)

## Steps to use it

1. Create a pgp-pair key. 
2. Log in to a shared server (between the target and yourself)
3. Set an HTTP-Server hosting the public PGP key at port 6666. (Right know is hardcoded, could be changed, but I don't think is necessary)
4. Set an Netcat-Server receiving connections at port 6667, logging all data received to a file. 
5. Run the script providing the ip/host of the shared server.
6. Wait for the password :)
7. Connect to the shared server and get the logging file from the NC sever.
8. Decript the file using the private PGP key.


## Future work

Every feedback/help will be very welcome.

1. Delete temp directory.
2. Remove public key from keyring.
3. More..



