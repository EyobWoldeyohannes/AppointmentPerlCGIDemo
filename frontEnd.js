$(function() { // document ready function...we can not access DOM elements before the page has been constructed
    
var btnCancel = document.getElementById('btnCancel');
var btnSearch = document.getElementById('btnSearch');
var input = document.getElementById('input'); 
    
$("#btnNew").click(function(){
    let btnNew = document.getElementById('btnNew');
    let v = btnNew.value;
    
    if(v === "NEW"){
        input.hidden = false;
        btnCancel.hidden = false;
        btnNew.value = "ADD";
    }
    else if(v === "ADD"){ // send input data to backend
        // alert("sending data to database");
         $('#submitForm').submit(); // dynamically submit the form if the ADD button is clicked   
        
    }
     
    }                
);
    

       
$("#btnCancel").click(function(){
    document.getElementById('date').value='';
    document.getElementById('time').value='';
    $('#disc').val('');
    
    this.hidden = true; // 'this' has a function scope and refers to the cancel button at this point
    input.hidden = true;
    btnNew.value = "NEW";
});
    
$("#btnSearch").click(function getAppointments(){
   // Clear error and appointment div's
    $('#error').text("");
    $('#appointments').text("");
    
    var txtParam = document.getElementById("txtParam").value;
    //alert("Making Ajax call....."+txtParam);
    
    var resultObject;
    
    $.ajax(
            "/cgi-bin/backend.pl",
            {
            type: "GET",
            data: {'searchTerm':txtParam}, // send search input text as parameter to perl cgi script
            dataType: "json", // we expect json result from the backend script
            async: false,
            success: getApp,   
            failure: getAjaxFail,
            complete: function(response, textstatus){
               // return alert();
            }
        });
   
//    getApp(resultObject);
});
    
function getApp(jsonData){ // populates the appointments DOM by a table     
    
    if(jsonData.error){ 
        $('#error').text("Search Result :"+jsonData.error);
    }
    else{ // If there is no error in the returned json data, then there must be an appointments list
        
    var appointmentsList = jsonData.appointments; // appointments array
    
    // Extract Column headings
    // { 'date', 'time', and 'disc'}
    var colNames=[];
    for(var i=0; i<appointmentsList.length; i++){
        for(var k in appointmentsList[i]){
            if(colNames.indexOf(k) === -1){
                colNames.push(k);
            }
        }
    }
        
    // Create table dynamically
    var resultTable = document.createElement("table");
    
    var tr = resultTable.insertRow(-1);
    
    for(var i=0; i<colNames.length; i++){
        var th = document.createElement("th");
        th.innerHTML = colNames[i].toUpperCase();
        tr.appendChild(th);
    }
    
    // Add recieved JSON data to each table rows
    for(var i=0; i<appointmentsList.length; i++){
        
        tr = resultTable.insertRow(-1);
        
        for(var j=0; j<colNames.length; j++){
            var tabCell = tr.insertCell(-1);
            tabCell.innerHTML = appointmentsList[i][colNames[j]];
        }
    }
    
    // Add the dynamically populated table to a div element on the HTML front end
    var divAppointments = document.getElementById("appointments");
    divAppointments.innerHTML=""; // clear its content before adding new results
    divAppointments.appendChild(resultTable);
    
    } // end of else
}
function getAjaxFail(xhr, status, exception){
      //console.log(xhr, status, exception);
    let divError = document.getElementById("error");
    divError.innerHTML="error is here";
    divError.appendChild(xhr.status);
}
    
});
