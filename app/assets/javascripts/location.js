function selectionChanged(category) {
  var loclist  = document.getElementById("select_" + category)
  $.ajax({
    url: "/companies/" + loclist.value + ".json",
    type: "GET", 
    success: function(data) { 
      document.getElementById(category + "_postcode").value = data.postcode;
      document.getElementById(category + "_address").value = data.address;
      document.getElementById(category + "_phone_no").value = data.phone_no;
      document.getElementById(category + "_destination_name").value = data.destination_name	;
      
      }
    })
  }

function placeChanged(category) {
  var plclist  = document.getElementById("select_" + category)
  $.ajax({
    url: "/places/" + plclist.value + ".json",
    type: "GET", 
    success: function(data) { 
      document.getElementById(category + "_postcode").value = data.postcode;
      document.getElementById(category + "_address").value = data.address;
      document.getElementById(category + "_phone_no").value = data.phone_no;
      document.getElementById(category + "_destination_name").value = data.destination_name	;
      
      }
    })
  }

