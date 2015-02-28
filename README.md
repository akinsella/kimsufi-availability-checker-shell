# kimsufi-availability-checker-shell

Shell script to check availability of kimsufi server.

You can also check availability of any OVH reference in any zone provided you have the reference ... (So you Start, Kimsufi, OVH, ...)

## Author

Alexis Kinsella ( @alexiskinsella )


## Installation

### jq ( http://stedolan.github.io/jq/ )

Mac: 

	brew install jq

Linux:

	sudo yum install jq
	sudo apt-get install jq


### Mandrill account ( https://mandrillapp.com/ )

To send mail, you can use Mandrill. If you don't have a mandrill account, you need to create one ...


### Make your shell script executable

	chmod 744 ./kimsufi-availability.sh


## Execute

	./kimsufi-availability.sh 150sk60 rbx 0000000000000000000000 john.doe@gmail.com "John Doe" john.doe@gmail.com


### Parameters

    1 - Reference pattern (grep pattern) - Example: 150sk60
	2 - Zone pattern (zone pattern) - Example: rbx
	3 - Mandrill API key - Example: 0000000000000000000000
	4 - From email - Example: john.doe@gmail.com
	5 - From name - Example: John Doe
	6 - To email - Example: john.doe@gmail.com

### Cron your shell script

Edit your crontab:

	crontab -e

Create log file with expected log file mode.

Crontab entry:

	*/15 * * * * /home/<user>/kimsufi-availability-checker-shell/kimsufi-availability.sh 150sk60 rbx 0000000000000000000000 john.doe@gmail.com "John Doe" john.doe@gmail.com >> /var/log/kimsufi-availability.log 2>&1