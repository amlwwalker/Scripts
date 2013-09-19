#!/usr/bin/perl


################################################################################################################################
#
# Title:  Nmap Report Generator Script
# Author: Dave Hartley
# E-Mail: dave_hartley@symantec.com
#
# Description:
# Import given Nmap (.xml format) report file and generate follwoing data:
#
#	[1] table of open TCP ports
#	[2] table of open UDP ports
#	[3] table of OS guess
#	[4] table of mac address and associated vendor identified
#	[5] table of TCP or UDP stats
#	[6] pie chart representing total number of each service/port found
#	[7] pie chart representing total number of each for tcp http/https
#	    web server version found
#
#
# Version: 0.1 First release
#
# Version: 0.2 Added statistical analysis sub routines
#
# Version: 0.3 Added pie chart generation for total number of each open port found
#
# Version: 0.4 Moved pie chart code to sub routine for more manageable code
#
# Version: 0.5 Added pie chart generation and stats collection for different types of
#	       HTTP and HTTPS web server types found.
#
# Version: 0.6 Added code to collect mac address and vendor info and write to table
#
# Version: 0.7 Added code to gather statistics for:
#
#		[1] average number of open ports per device/host
# 		[2] host/device with most open ports
# 		[3] most common port for all hosts/devices
#
# Version: 0.8 Added code to write statistics to statiscs table
#
# Version: 0.9 Added code to dynamically check the input .xml file for scan options and ensure
#              that we run the correct subs
#
# Version: 1.0 Added code to create one document for all tables as apposed to one doc per table
#
# Version: 1.1 ActivtyIM customised release
#
#
# Changes:
#		[1] Thu Jun 22 18:02:38 BST 2006: Official Release.
#		[2] Wed Jan 23 14:00:12 GMT 2008: Removed Chart subs
#										  Added Mac Address subs
#										  Did a bit of general housekeeping of code
#
#		[3] Thu Jan 24 11:23:10 GMT 2008: ActivtyIM Release.
#
#
################################################################################################################################

use Getopt::Long;
use Nmap::Parser;		# load the Nmap parser library
#use GD;				# load the GD library
#use GD::Graph::pie;		# load the pie chart module
#use GD::Graph::colour;		# load the module for colours

# ================================================
# 	[ Global Variables ]
# ================================================

# script version
my $script_version = "1.1";

# create an instance for our Nmap Parser Object
#my $np = new Nmap::Parser::XML;
my $np = new Nmap::Parser;

# multi dimensional arrays for GD::Graph plot data
my @common_ports_data;
my @web_server_version;

# file to parse
my $file_xml;

# file to output to
my $report;

# a couple of hash arrays to hold our open port stats
my %open_tcp_ports,%open_udp_ports;

# a hash array to hold our http/https version information
my %web_server_version;

# a hash array to hold the number of ports open per device/host
my %total_open_ports_per_host;

# a couple of effective boolean values (in the loosest sense of the word) for our run mode
my $mode,$tcp,$udp,$os,$versioninfo;

# holders for stats
my $average_num_ports_found,@hosts_with_most_open_ports,$most_common_port;

# ================================================
#     [ cmdparse - Parse commandline ]
# ===============================================

sub cmdparse {
	GetOptions (
			"h|help"	=> \$help,
			"f|file=s"      => \$file_xml,
			"r|report=s"	=> \$report,
		);

		if ($help) {
			usage();
			exit(0);
		}

        }	


# ================================================
#	[ usage - Display Help ]
# ================================================

sub usage {
print <<'__EOD_MARKER__';

NAME
	NMAParser.pl	[-h|--help] [-f|--file] [-r|--report]

OPTIONS
	--file
	    Full name of Nmap .xml file to use.
	
	--report
	    Name of the word.xml report file to create.
	
	--help
	    print this shit.

NOTES
	Import given Nmap (.xml format) report file and generate following data:

 	[1] table of open TCP ports
 	[2] table of open UDP ports
 	[3] table of OS guess
 	[4] table of mac address and associated vendor identified
	[5] table of TCP or UDP stats
	
 	** Any problems look at the source, still stuck? Mail me. **
	
__EOD_MARKER__
exit(0);
}	


#===================================================================================================================
#	[ WORDML reuseable formatting subs ]
#===================================================================================================================

#===================================================================================================================
#	[ print WORDML report header ]
#===================================================================================================================

sub print_WORDML_Header(){
print REPORT <<'__EOD_MARKER__';
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<?mso-application progid="Word.Document"?>
<w:wordDocument 
	xmlns:aml="http://schemas.microsoft.com/aml/2001/core" 
	xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" 
	xmlns:mv="urn:schemas-microsoft-com:mac:vml" 
	xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main" 
	xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" 
	xmlns:o="urn:schemas-microsoft-com:office:office" 
	xmlns:v="urn:schemas-microsoft-com:vml" 
	xmlns:w10="urn:schemas-microsoft-com:office:word" 
	xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml" 
	xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint" 
	xmlns:wsp="http://schemas.microsoft.com/office/word/2003/wordml/sp2" 
	xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core" 
	w:macrosPresent="no" 
	w:embeddedObjPresent="no" 
	w:ocxPresent="no" 
	xml:space="preserve">
	<w:ignoreSubtree w:val="http://schemas.microsoft.com/office/word/2003/wordml/sp2"/>
	<o:DocumentProperties>
		<o:Author>Dave Hartley</o:Author>
		<o:LastAuthor>Dave Hartley</o:LastAuthor>
	</o:DocumentProperties>
__EOD_MARKER__

}

#===================================================================================================================
#	[ print WORDML fonts section ]
#===================================================================================================================

sub print_WORDML_Fonts{
print REPORT <<'__EOD_MARKER__';

<w:fonts>
	<w:defaultFonts w:ascii="Cambria" w:fareast="Cambria" w:h-ansi="Cambria" w:cs="Times New Roman"/>
	<w:font w:name="Times New Roman">
		<w:panose-1 w:val="02020603050405020304"/>
		<w:charset w:val="00"/>
		<w:family w:val="auto"/>
		<w:pitch w:val="variable"/>
		<w:sig w:usb-0="00000003" w:usb-1="00000000" w:usb-2="00000000" w:usb-3="00000000" w:csb-0="00000001" w:csb-1="00000000"/>
	</w:font>	
	<w:font w:name="Arial">
		<w:panose-1 w:val="020B0604020202020204"/>
		<w:charset w:val="00"/>
		<w:family w:val="auto"/>
		<w:pitch w:val="variable"/>
		<w:sig w:usb-0="00000003" w:usb-1="00000000" w:usb-2="00000000" w:usb-3="00000000" w:csb-0="00000001" w:csb-1="00000000"/>
	</w:font>	
	<w:font w:name="Cambria">
		<w:panose-1 w:val="02040503050406030204"/>
		<w:charset w:val="00"/>
		<w:family w:val="auto"/>
		<w:pitch w:val="variable"/>
		<w:sig w:usb-0="00000003" w:usb-1="00000000" w:usb-2="00000000" w:usb-3="00000000" w:csb-0="00000001" w:csb-1="00000000"/>
	</w:font>
</w:fonts>

__EOD_MARKER__
}

#===================================================================================================================
#	[ print WORDML report styles section ]
#===================================================================================================================

sub print_WORDML_Styles(){

print REPORT <<'__EOD_MARKER__';
<w:styles>
	<w:versionOfBuiltInStylenames w:val="2"/>
	<w:style w:type="paragraph" w:default="on" w:styleId="Normal">
		<w:name w:val="Normal"/>
		<w:rsid w:val="00A00840"/>
		<w:pPr>
			<w:spacing w:before="120" w:after="180"/>
		</w:pPr>
	</w:style>
	<w:style w:type="character" w:default="on" w:styleId="DefaultParagraphFont">
		<w:name w:val="Default Paragraph Font"/>
	</w:style>
	<w:style w:type="table" w:default="on" w:styleId="TableNormal">
		<w:name w:val="Normal Table"/>
		<wx:uiName wx:val="Table Normal"/>
		<w:rPr>
			<wx:font wx:val="Cambria"/>
			<w:lang w:val="EN-GB" w:fareast="EN-US" w:bidi="AR-SA"/>
		</w:rPr>
		<w:tblPr>
			<w:tblInd w:w="0" w:type="dxa"/>
			<w:tblCellMar>
				<w:top w:w="0" w:type="dxa"/>
				<w:left w:w="108" w:type="dxa"/>
				<w:bottom w:w="0" w:type="dxa"/>
				<w:right w:w="108" w:type="dxa"/>
			</w:tblCellMar>
		</w:tblPr>
	</w:style>
	<w:style w:type="list" w:default="on" w:styleId="NoList">
		<w:name w:val="No List"/>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableText">
		<w:name w:val="Table Text"/>
		<w:basedOn w:val="Normal"/>
		<w:link w:val="TableTextChar"/>
		<w:rsid w:val="00A00840"/>
		<w:pPr>
			<w:keepLines/>
			<w:suppressAutoHyphens/>
			<w:spacing w:after="120"/>
		</w:pPr>
		<w:rPr>
			<w:rFonts w:ascii="Activity Char" w:h-ansi="Activity Char"/>
			<wx:font wx:val="Activity Char"/>
			<w:sz w:val="16"/>
			<w:sz-cs w:val="16"/>
		</w:rPr>
	</w:style>
	<w:style w:type="character" w:styleId="TableTextChar">
		<w:name w:val="Table Text Char"/>
		<w:basedOn w:val="DefaultParagraphFont"/>
		<w:link w:val="TableText"/>
		<w:rsid w:val="00A00840"/>
		<w:rPr>
			<w:rFonts w:ascii="Activity Char" w:fareast="Times New Roman" w:h-ansi="Activity Char" w:cs="Times New Roman"/>
			<w:kern w:val="16"/>
			<w:sz w:val="16"/>
			<w:sz-cs w:val="16"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableHeadingRow">
		<w:name w:val="Table Heading Row"/>
		<w:basedOn w:val="Normal"/>
		<w:rsid w:val="00A00840"/>
		<w:pPr>
			<w:keepNext/>
			<w:keepLines/>
			<w:spacing w:before="160" w:after="80"/>
		</w:pPr>
		<w:rPr>
			<w:rFonts w:ascii="Activity Char" w:h-ansi="Activity Char"/>
			<wx:font wx:val="Activity Char"/>
			<w:b/>
			<w:sz w:val="16"/>
			<w:sz-cs w:val="16"/>
		</w:rPr>
	</w:style>
</w:styles>
<w:body>
__EOD_MARKER__
}

#===================================================================================================================
#	[ print WORDML table header ]
#===================================================================================================================

sub print_WORDML_TABLE_Header{

my ($col_1,$col_2) = @_;

chomp $col_1;
chomp $col_2;

print REPORT <<'__EOD_MARKER__';
<!-- START OF TABLE HEADERS ROW -->
	<w:tbl>
		<w:tblPr>
			<w:tblW w:w="0" w:type="auto"/>
			<w:tblInd w:w="10" w:type="dxa"/>
			<w:shd w:val="clear" w:color="auto" w:fill="FFFFFF"/>
			<w:tblCellMar>
				<w:left w:w="40" w:type="dxa"/>
				<w:right w:w="100" w:type="dxa"/>
			</w:tblCellMar>
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="2660"/>
			<w:gridCol w:w="5770"/>
		</w:tblGrid>
		<w:tr wsp:rsidR="00A00840" wsp:rsidRPr="00623431">
			<w:trPr>
				<w:cantSplit/>
				<w:tblHeader/>
			</w:trPr>
			<w:tc>
				<w:tcPr>
					<w:tcW w:w="0" w:type="auto"/>
					<w:tcBorders>
						<w:top w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:left w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:bottom w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:right w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
					</w:tcBorders>
					<w:shd w:val="clear" w:color="auto" w:fill="7DB6EA"/>
				</w:tcPr>
				<w:p wsp:rsidR="00A00840" wsp:rsidRPr="00623431" wsp:rsidRDefault="00A00840">
					<w:pPr>
						<w:pStyle w:val="TableHeadingRow"/>
						<w:rPr>
							<w:rFonts w:ascii="Arial" w:h-ansi="Arial"/>
							<wx:font wx:val="Arial"/>
							<w:b w:val="off"/>
							<w:sz w:val="20"/>
						</w:rPr>
					</w:pPr>
					<w:r>
						<w:rPr>
							<w:rFonts w:ascii="Arial" w:h-ansi="Arial"/>
							<wx:font wx:val="Arial"/>
							<w:b w:val="off"/>
							<w:sz w:val="20"/>
						</w:rPr>
						<w:t>
__EOD_MARKER__
print REPORT $col_1;
print REPORT <<'__EOD_MARKER__';
						</w:t>
					</w:r>
				</w:p>
			</w:tc>
			<w:tc>
				<w:tcPr>
					<w:tcW w:w="0" w:type="auto"/>
					<w:tcBorders>
						<w:top w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:left w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:bottom w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:right w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
					</w:tcBorders>
					<w:shd w:val="clear" w:color="auto" w:fill="7DB6EA"/>
				</w:tcPr>
				<w:p wsp:rsidR="00A00840" wsp:rsidRPr="00623431" wsp:rsidRDefault="00A00840">
					<w:pPr>
						<w:pStyle w:val="TableHeadingRow"/>
						<w:rPr>
							<w:rFonts w:ascii="Arial" w:h-ansi="Arial"/>
							<wx:font wx:val="Arial"/>
							<w:b w:val="off"/>
							<w:sz w:val="20"/>
						</w:rPr>
					</w:pPr>
					<w:r>
						<w:rPr>
							<w:rFonts w:ascii="Arial" w:h-ansi="Arial"/>
							<wx:font wx:val="Arial"/>
							<w:b w:val="off"/>
							<w:sz w:val="20"/>
						</w:rPr>
						<w:t>
__EOD_MARKER__
print REPORT $col_2;
print REPORT <<'__EOD_MARKER__';
						</w:t>
					</w:r>
				</w:p>
			</w:tc>
		</w:tr>
<!-- END OF TABLE HEADERS ROW -->
__EOD_MARKER__
}


#===================================================================================================================
#	[ print WORDML table row ]
#===================================================================================================================

sub start_table_row{
print REPORT <<'__EOD_MARKER__';
<!-- START OF TABLE DATA ROW -->
		<w:tr wsp:rsidR="00A00840" wsp:rsidRPr="00623431">
			<w:trPr>
				<w:cantSplit/>
			</w:trPr>
__EOD_MARKER__
}

#===================================================================================================================
#	[ print WORDML table row ]
#===================================================================================================================

sub print_table_row{

my ($col_1) = @_;
chomp $col_1;

print REPORT <<'__EOD_MARKER__';
<!-- START OF TABLE DATA COLUMN -->
			<w:tc>
				<w:tcPr>
					<w:tcW w:w="0" w:type="auto"/>
					<w:tcBorders>
						<w:top w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
						<w:bottom w:val="dotted" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/>
					</w:tcBorders>
				</w:tcPr>
				<w:p wsp:rsidR="00A00840" wsp:rsidRPr="00623431" wsp:rsidRDefault="00A00840">
					<w:pPr>
						<w:pStyle w:val="TableText"/>
						<w:rPr>
							<w:rFonts w:ascii="Arial" w:h-ansi="Arial"/>
							<wx:font wx:val="Arial"/>
						</w:rPr>
					</w:pPr>
					<w:r wsp:rsidRPr="00623431">
						<w:rPr>
							<w:rFonts w:ascii="Arial" w:h-ansi="Arial"/>
							<wx:font wx:val="Arial"/>
						</w:rPr>
__EOD_MARKER__
print REPORT "\t\t\t\t\t\t<w:t>".$col_1."</w:t>\n";
print REPORT <<'__EOD_MARKER__';
					</w:r>
				</w:p>
			</w:tc>
<!-- END OF TABLE DATA COLUMN -->
__EOD_MARKER__
}


#===================================================================================================================
#	[ print WORDML table row closing tags ]
#===================================================================================================================

sub close_table_row(){
print REPORT <<'__EOD_MARKER__';
		</w:tr>
<!-- END OF TABLE DATA ROW -->
__EOD_MARKER__
}


#===================================================================================================================
#	[ End of WORDML reuseable formatting subs ]
#===================================================================================================================


#===================================================================================================================
#	[ stats subs ]
#===================================================================================================================

#===================================================================================================================
#	[ process the tcp stats gathered from the tcp info sub ]
#===================================================================================================================

sub get_tcp_stats(){

my $common_port;
my $max = 0;
	
	foreach $key (keys %open_tcp_ports){
	
		## code to dymanically update @common_ports_data array
		## for the pie chart
		
		push @ports, $key;
		push @counts, $open_tcp_ports{$key};
		
		if ($open_tcp_ports{$key} > $max){
			$max = $open_tcp_ports{$key};
			$common_port = $key;
		}
	}
		
	push @common_ports_data, [@ports];
	push @common_ports_data, [@counts];
	$most_common_port = $common_port." (".$max.")";
	
	## set the report up
	$csv = "tcp.port.data.csv";
	open(CSV, ">>$csv") || die("Couldn't open report file $csv!\n");
	
	for $j ( 0 .. $#{$common_ports_data[0]} ) {
		print CSV "$common_ports_data[0][$j],$common_ports_data[1][$j]\n"; 
	}
}
	

#===================================================================================================================
#	[ process the udp stats gathered from the udp info sub ]
#===================================================================================================================

sub get_udp_stats(){

my $common_port;
my $max = 0;

	foreach $key (keys %open_udp_ports){
		## code to dymanically update @common_ports_data array
		## for the pie chart
		push @ports, $key;
		push @counts, $open_udp_ports{$key};
		
		if ($open_udp_ports{$key} > $max){
			$max = $open_udp_ports{$key};
			$common_port = $key;
		}
	}
		
	push @common_ports_data, [@ports];
	push @common_ports_data, [@counts];
	$most_common_port = $common_port." (".$max.")";
	
	## set the report up
	$csv = "udp.port.data.csv";
	open(CSV, ">>$csv") || die("Couldn't open report file $csv!\n");
	
	for $j ( 0 .. $#{$common_ports_data[0]} ) {
		print CSV "$common_ports_data[0][$j],$common_ports_data[1][$j]\n"; 
	}
}

#===================================================================================================================
#	[ process the web server version stats gathered from the tcp/udp info sub ]
#===================================================================================================================

sub get_web_server_stats(){

	foreach $key (keys %web_server_version){
		## code to dymanically update @web_server_version data array
		## for the pie chart
		push @version, $key;
		push @count, $web_server_version{$key};
	}
		
	push @web_server_version, [@version];
	push @web_server_version, [@count];
}

#===================================================================================================================
#	[ process the tcp/udp ports stats gathered from the tcp/udp info sub ]
#===================================================================================================================

## gets hosts with most open ports ##
## gets average number of ports open per host ##

sub get_host_n_port_stats(){

my $host,$max;
$max = 0;

my $total_hosts = 0;
my $num_ports = 0;

	foreach $key (keys %total_open_ports_per_host){
		$total_hosts++;
		$num_ports = $num_ports + $total_open_ports_per_host{$key};
		if ($total_open_ports_per_host{$key} > $max){
			$max = $total_open_ports_per_host{$key};
		}
	}
	
	foreach $key (keys %total_open_ports_per_host){
		if ($total_open_ports_per_host{$key} eq $max){
			$max = $total_open_ports_per_host{$key};
			$host = $key;
			push (@hosts_with_most_open_ports, $host." (".$max.")");
		}
	}
	
## do the math
if ($num_ports > 0){
	$average_num_ports_found = $num_ports/$total_hosts;

	## round the decimal
	$average_num_ports_found =  int($average_num_ports_found + .5 * ($average_num_ports_found <=> 0));
	}
}

#===================================================================================================================
#       [ print stats table sub ]
#
#	[1] print average number of open ports per device/host
# 	[2] print host/device with most open ports
# 	[3] print most common port for all hosts/devices
#
#===================================================================================================================

sub print_stats(){
	my $data;
	start_table_row();
	print_table_row("Average number of ports found per host");
	print_table_row($average_num_ports_found);
	close_table_row();

	start_table_row();
	print_table_row("Host(s) with most open ports");
	foreach (@hosts_with_most_open_ports){
		$data = $data.$_." ";
	}
	print_table_row($data);
	close_table_row();
	
	start_table_row();
	print_table_row("Most common port");
	print_table_row($most_common_port);
	close_table_row();
}

#===================================================================================================================
#	[ end of stats subs ]
#===================================================================================================================

#===================================================================================================================
#	[ graph sub passes the data to GD to generate pie charts]
#===================================================================================================================

sub create_pie_chart{
	
	my ($array_ref,$filename) = @_;
	my @data = @$array_ref;
	
	# create a new graph instance
	my $graph = GD::Graph::pie->new(400, 300);
	
	# plot the graph
	my $gd = $graph->plot(\@data) or die $graph->error;
	
	# export the graph to an image
	open(IMG, ">$filename") or die $!;
	binmode IMG;
	print IMG $gd->png;
}

#===================================================================================================================
#	[ end of graph sub ]
#===================================================================================================================

#===================================================================================================================
# 	[ parsing subs ]
#===================================================================================================================


#===================================================================================================================
#	[ NMAP Session sub gets the session info so that we know what we have to parse ]
#===================================================================================================================

## Get Current Session Info ##
sub get_session_info{

my $session  = $np->get_session(); #set the Nmap::Parser::Session object

my $scanargs = $session->scan_args();

## regex time again  :-( 

if ($scanargs =~ m/-sS/){
	#print "\n[x] $file_xml contains tcp results\n";
	$tcp = "true";
	}
	
if ($scanargs =~ m/-sU/){
	#print "\n[x] $file_xml contains ucp results\n";
	$udp = "true";
	}
	
if ($scanargs =~ m/-A/){
	#print "\n[x] $file_xml contains service version information\n";
	$versioninfo = "true";
	$os = "true";
	}
if ($scanargs =~ m/-sV/){
	#print "\n[x] $file_xml contains service version information\n";
	$versioninfo = "true";
	}
	
if ($scanargs =~ m/-O/){
	#print "\n[x] $file_xml contains operating system fingerprint results\n";
	$os = "true";
	}
}

#===================================================================================================================
# 	[ OS Info sub ]
#===================================================================================================================

sub print_os_info(){
	## OS fingerprinting
	for my $host ($np->all_hosts(up)){
		my $hostname = $host->hostname;
		my $ipaddr = $host->addr;
		my $os = $host->os_sig;
		my $name = $os->name;
		my $family = $os->osfamily;
		my $data;
		
		if ($family ne ""){
			start_table_row();
			if (!$hostname){print_table_row($ipaddr);}
			else {print_table_row($ipaddr." (".$hostname.")");}
			$data = $family;
			if ($name ne ""){
				$data = $data." (".$name.")";
				}
			else {$data = $data;}
			print_table_row($data);
			close_table_row();
		}
	}
}

#===================================================================================================================
# 	[ TCP Info sub ]
#===================================================================================================================

sub print_tcp_info{
	## Open TCP Ports
	
	my $data;
	
	for my $host ($np->all_hosts(up)){
	
		my $device = $host->addr;
		my $hostname = $host->hostname;
		my $port_count = 0;
		my $portCount = 0;
		
		for my $port ($host->tcp_ports('open')){$portCount++;}
		my $numPorts = $portCount;
		
		if ($numPorts ne 0){
			
			start_table_row();
			
			if (!$hostname){print_table_row($device);}
			else {print_table_row($device." (".$hostname.")");}
			
			$data = "";
			
			for my $port ($host->tcp_ports('open')){
			$port_count++;
			
				## add host to total open ports per host hash array
				if (exists($total_open_ports_per_host{$device})){
					delete($total_open_ports_per_host{$device});
					}
				$total_open_ports_per_host{$device} = $port_count;
				
				for my $svc ($host->tcp_service($port)){
					$version = $svc->product." ".$svc->version;
					$svcPort = $port." ".$svc->name;
					$svcName = $svc->name;
					if ($svcName ne ""){
						if ($svcName ne "unknown"){
								$svcDataPort = $port." (".$svc->name.") ".$version;
								}	
						else {$svcDataPort = $port;}
							}
					else {
						$svcDataPort = $port;
						}
					
					if ($numPorts eq 1){$data = $data.$svcDataPort;}
				
					else {$data = $data.$svcDataPort."<w:br/>"}
				
					$numPorts = $numPorts-1;
				
					## web server versions hash array
					if ($svc->name eq "http"|"https"){
						if (exists($web_server_version{$version})){
							my $count = $web_server_version{$version};
							$count++;
							delete($web_server_version{$version});
							$web_server_version{$version} = $count;
							}					
					else {my $count = 1;$web_server_version{$version} = $count;}
					}
				 }
					
				## open ports hash array
				if (exists($open_tcp_ports{$svcPort})){
			   		my $count = $open_tcp_ports{$svcPort};
			   		$count++;
			   		delete($open_tcp_ports{$svcPort});
			   		$open_tcp_ports{$svcPort} = $count;
			 		}
			
			 	else {my $count = 1;$open_tcp_ports{$svcPort} = $count;}
				}
			print_table_row($data);
			close_table_row();										
		}
	}
}


#===================================================================================================================
# 	[ UDP Info sub ]
#===================================================================================================================

sub print_udp_info{
	## Open UDP Ports
	
	my $data;
	
	for my $host ($np->all_hosts(up)){
	
		my $device = $host->addr;
		my $hostname = $host->hostname;
		my $port_count = 0;
		my $portCount = 0;
		
		for my $port ($host->udp_ports('open')){$portCount++;}
		my $numPorts = $portCount;
		
		if ($numPorts ne 0){
			
			start_table_row();
			
			if (!$hostname){print_table_row($device);}
			else {print_table_row($device." (".$hostname.")");}
			
			$data = "";
			
			for my $port ($host->udp_ports('open')){
			$port_count++;
			
				## add host to total open ports per host hash array
				if (exists($total_open_ports_per_host{$device})){
					delete($total_open_ports_per_host{$device});
					}
				$total_open_ports_per_host{$device} = $port_count;
				
				for my $svc ($host->udp_service($port)){
						$version = $svc->product." ".$svc->version;
					$svcPort = $port." ".$svc->name;
					$svcName = $svc->name;
					if ($svcName ne ""){
						if ($svcName ne "unknown"){
								$svcDataPort = $port." (".$svc->name.") ".$version;
								}	
						else {$svcDataPort = $port;}
							}
					else {
						$svcDataPort = $port;
						}
					}
				 
				if ($numPorts eq 1){$data = $data.$svcDataPort;}
				
				else {$data = $data.$svcDataPort."<w:br/>"}
				
				$numPorts = $numPorts-1;
					
				## open ports hash array
				if (exists($open_udp_ports{$svcPort})){
			   		my $count = $open_udp_ports{$svcPort};
			   		$count++;
			   		delete($open_udp_ports{$svcPort});
			   		$open_udp_ports{$svcPort} = $count;
			 		}
			
			 	else {my $count = 1;$open_udp_ports{$svcPort} = $count;}
				}
			print_table_row($data);
			close_table_row();										
		}
	}
}

#===================================================================================================================
# 	[ mac address sub ]
#===================================================================================================================

sub get_mac_addr_info(){

	my $data;
	
	for my $host ($np->all_hosts(up)){
	
	my $device = $host->addr;
	my $hostname = $host->hostname;	
	my $mac = $host->mac_addr();
	my $vendor = $host->mac_vendor();

	start_table_row();
	
	if (!$hostname){print_table_row($device);}
	else {print_table_row($device." (".$hostname.")");}
	
	if (!$vendor){$data = "$mac";}
	else {$data = "$mac ($vendor)";}
	print_table_row($data);
	close_table_row();	
	}
}
	
#===================================================================================================================
# 	[ end of parsing subs ]
#===================================================================================================================

#===================================================================================================================
# 	[ ::Main:: where the action is :-)]
#===================================================================================================================

## get command line switches
cmdparse();

## if no inputs shout at the idiot!
if (!$file_xml){usage()}
if (!$report){usage()}

## pretty screen text stuff ##
print "[ NMAParser.pl $script_version ]\n\n";

## parse the results file
$np->parsefile($file_xml);

## pretty screen text stuff ##
print "[x] loaded results file: $file_xml\n";

## get the session infor from the results file so we know what to do
get_session_info();

## set the report up
open(REPORT, ">>$report") || die("Couldn't open report file $report!\n");

## pretty screen text stuff ##
print "[x] creating $report\n";

print_WORDML_Header();
print_WORDML_Fonts();
print_WORDML_Styles();

## decisions, decisions


if ($tcp eq "true"){

	## pretty screen text stuff ##
	print "[x] creating open tcp ports table\n";
	
	print_WORDML_TABLE_Header("IP Address", "Ports");
	print_tcp_info();
	print REPORT "\n</w:tbl>\n";
	print REPORT "<w:p></w:p>\n";
	
	if ($os eq "true"){
	
		## pretty screen text stuff ##
		print "[x] creating operating system guess table\n";
		print_WORDML_TABLE_Header("IP Address", "OS");
		print_os_info();
		print REPORT "\n</w:tbl>\n";
		print REPORT "<w:p></w:p>\n";
		}
		
	## pretty screen text stuff ##
	print "[x] creating mac table\n";
	
	print_WORDML_TABLE_Header("Host Address", "Mac Address");
	get_mac_addr_info();
	print REPORT "\n</w:tbl>\n";
	print REPORT "<w:p></w:p>\n";
	
	get_tcp_stats();
	get_host_n_port_stats();
	
	## pretty screen text stuff ##
	print "[x] creating tcp stats table\n";
	
	print_WORDML_TABLE_Header("Description", "Data");
	print_stats();
	print REPORT "\n</w:tbl>\n";
	print REPORT "<w:p></w:p>\n";
	
	## pretty screen text stuff ##
	print "[x] creating tcp common ports stats pie chart\n";
	
#	create_pie_chart(\@common_ports_data,"$report.total_tcp_ports.png");
	
#	if ($versioninfo eq "true"){
#		get_web_server_stats();
		
		## pretty screen text stuff ##
#		print "[x] creating tcp web server versions pie chart\n";
#		create_pie_chart(\@web_server_version,"$report.web_server.png");
#		}
	}
	
if ($udp eq "true"){

	## pretty screen text stuff ##
	print "[x] creating open udp ports table\n";
	
	print_WORDML_TABLE_Header("IP Address", "Ports");
	print_udp_info();
	print REPORT "\n</w:tbl>\n";
	print REPORT "<w:p></w:p>\n";
	
	if ($os eq "true"){
	
		## pretty screen text stuff ##
		print "[x] creating operating system guess table\n";
		
		print_WORDML_TABLE_Header("IP Address", "OS");
		print_os_info();
		print REPORT "\n</w:tbl>\n";
		print REPORT "<w:p></w:p>\n";
		}
	
	
	## pretty screen text stuff ##
	print "[x] creating mac table\n";
	
	print_WORDML_TABLE_Header("Host Address", "Mac Address");
	get_mac_addr_info();
	print REPORT "\n</w:tbl>\n";
	print REPORT "<w:p></w:p>\n";
	
	get_udp_stats();
	get_host_n_port_stats();
	
	## pretty screen text stuff ##
	print "[x] creating udp stats table\n";
	
	print_WORDML_TABLE_Header("Description", "Data");
	print_stats();
	print REPORT "\n</w:tbl>\n";
	print REPORT "<w:p></w:p>\n";
	
	## pretty screen text stuff ##
#	print "[x] creating udp common ports stats pie chart\n";
	
#	create_pie_chart(\@common_ports_data,"$report.total_udp_ports.png");
	}
	

### close off the report ###
print REPORT "</w:body>\n";
print REPORT "</w:wordDocument>\n";
close(REPORT);
## pretty screen text stuff ##
print "\n[ finished ]\n";
exit();

#===================================================================================================================
# 	[ end of the road ]
#===================================================================================================================




