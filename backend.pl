#!/usr/bin/perl 

=begin comment
This is the backend cgi perl script which is working.

It is called from the front end javascript (frontEnd.js). It takes request and make a database search(get) and insert (post) using different prepared query statements.

It returns a JSON object to the frontEnd.js which will be processed accordingly and populated to the html DOM areas.

Run the 'ATandTDemo_appointments.sql' script to create appointments table in database and populate it with sample data set.

=cut

use CGI;
use DBI;
#use strict;
#use warnings;
use DBD::mysql;

# Initialize CGI and read the CGI params
my $cgi = CGI->new();
my $theSearchTerm = $cgi->param('searchTerm');

my $parDate = $cgi->param('date');
my $parTime = $cgi->param('time');
my $parDisc = $cgi->param('disc');

# Print the HTTP header
print $cgi->header;

# Mysql Connection
# connection parameters
my $db="ATandTDemo";
my $host="localhost";
my $user="root";
my $password="12345";

# connect to MySQL database
my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host",
                           $user,
                           $password) 
                           or die "Can't connect to database: $DBI::errstr\n";

# Query statements and execution
#my $query = qq(select * from appointments);
my $query = "SELECT id, date, time, disc FROM appointments WHERE disc like '%$theSearchTerm%'";
my $queryHandle = $dbh->prepare($query);

my $insertQuery = "INSERT INTO appointments (date, time, disc) VALUES (?,?,?)";
my $insertQueryHandle = $dbh->prepare($insertQuery);

if($parDate != NULL and $parDate != NULL){
# Validate form inputs before adding to database
    $insertQueryHandle->execute($parDate, $parTime, $parDisc) or die $DBI::errstr;
}

$queryHandle->execute() or die $DBI::errstr;

$n = $queryHandle->rows;

my $count = 0;

if($n>=1){
print "{";
print "\"appointments\":";
print "[\n";

while(($id, $date, $time, $disc) = $queryHandle->fetchrow()){
    
    if($count >0){
        print ",\n"; 
    }
    print "{\"date\":\"$date\",\"time\":\"$time\",\"disc\":\"$disc\"}";
   $count++;
}

print "]";
print "}";
}
else{
print "{";
print "\"error\":\"There is no result in the database\"";

print "}";
}

# disconnect from the MySQL database
$dbh->disconnect();

# End of HTML
#print $cgi->end_html;

# Return JSON string to the frontend.js
#print $cgi->header(-type => "application/json", -charset => "utf-8");

