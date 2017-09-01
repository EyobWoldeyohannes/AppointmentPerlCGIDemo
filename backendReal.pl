#!/usr/bin/perl

=begin comment
This cgi perl script is under construction.

It has functions(subs) for displaying the HTML form under differnet conditions(the idea of reentrant form),
and it also had functions for validating input form and make a search for the input text from the database.

=cut

use CGI;
use DBI;
#use strict;
#use warnings;
use DBD::mysql;

# Create the CGI object
my $cgi = new CGI;

# Output the HTTP header
print $cgi->header ( );

# Process form if submitted; otherwise display it
if ( $cgi->param("search") )
{
  #process_form ( );
  search();
}
else
{
  display_form ( );
}

sub search
{
            my $theSearchTerm = $cgi->param('searchTerm');
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

#            my $insertQuery = "INSERT INTO appointments (date, time, disc) VALUES (?,?,?)";
#            my $insertQueryHandle = $dbh->prepare($insertQuery);
#
#            if($parDate != NULL and $parDate != NULL){
#            # Validate form inputs before adding to database
#                $insertQueryHandle->execute($parDate, $parTime, $parDisc) or die $DBI::errstr;
#            }

            $queryHandle->execute() or die $DBI::errstr;

            $n = $queryHandle->rows;

            my $count = 0;
            
            my $json_message = "";
            my $error_message = "";

            if($n>=1){
           
            $json_message .= "{";
            $json_message .= "\"appointments\":";
            $json_message .= "[\n";

            while(($id, $date, $time, $disc) = $queryHandle->fetchrow()){

                if($count >0){
                    $json_message .= ",\n"; 
                }
                $json_message .= "{\"date\":\"$date\",\"time\":\"$time\",\"disc\":\"$disc\"}";
               $count++;
            }

            $json_message .= "]";
            $json_message .= "}";
            }
            else{
                $error_message .= "{";
                $error_message .= "\"error\":\"There is no result in the database\"";
                $error_message .= "}";
            }

            # disconnect from the MySQL database
            $dbh->disconnect();
            
            # Errors with the form - redisplay it and return failure
            display_form ( $json_message, $error_message, $searchText);
}

sub process_form
{
  if ( validate_form ( ) )
  {
    print <<END_HTML;
    <html><head><title>Thank You</title></head>
    <body>
    Thank you - your form was submitted correctly!
    </body></html>
END_HTML
  }
}

sub validate_form
{
  my $searchTerm = $cgi->param("searchTerm");
 

  my $error_message = "";

  $error_message .= "Please enter valid search text <br>" if ( !$searchTerm );
  
  if ( $error_message )
  {
    # Errors with the form - redisplay it and return failure
    display_form ( $error_message, $searchTerm );
    return 0;
  }
  else
  {
    # Form OK - return success
    return 1;
  }
}

sub display_form
{
  my $json_message = shift;
  my $error_message = shift;
  my $searchText = shift;

  # Remove any potentially malicious HTML tags
  $searchText =~ s/<([^>]|\n)*>//g;

  
  # Display the form
  print <<END_HTML;
  <html>
  <head>
    <meta charset="UTF-8">
    <title>Appointment</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script>
    <script src="frontEnd.js"></script>
    </head>
    <body>
            <div id="error" style="color:red">
                $error_message
            </div>

        <div id="content">
        <input id="btnNew" type="submit" value="NEW"/>
        <input id="btnCancel" type="button" value="CANCEL" hidden/>
        <br>
        <br> 
        <div id="input" hidden>
            <form id="submitForm" action="/cgi-bin/backend.pl" method="post">
            DATE :<input id="date" name="date" onchange="validateDate()" required type="date"><br>
            TIME :<input id="time" name="time" type="time"><br>
            DESC :<input id="disc" name="disc" type="text"><br><br> 
            <!--<input id="btnS" type="submit" value="Submit"/>-->
            </form>
        </div>
        <br>
    
          <form action="/cgi-bin/backendReal.pl" method="get">
              <input type="hidden" name="submit" value="Submit">

              Search text: <input type="text" name="searchTerm" value="$searchText">
              

               <input type="submit" name="search" value="Search">
          </form>
    
                <a href="/cgi-bin/backend.pl"> Click here to see the raw JSON data</a>
        </div>
        <br>
    
        <div id="appointments" style="color:blue">
        $json_message
        </div>
  </body></html>
END_HTML

}

