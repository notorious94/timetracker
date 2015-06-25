$(document).ready(function() {
    $('#monthly-attendance-table, #raw-data-table').dataTable({
        "order": [[ 1, "desc" ]],
        "iDisplayLength": 100,
        dom: 'T<"clear">lfrtip',
        tableTools: {
            "sSwfPath": "http://cdn.datatables.net/tabletools/2.2.2/swf/copy_csv_xls_pdf.swf",
            "aButtons": ["pdf", "print", "xls" ]
        }

    });

    $("#hidden-names").dataTable({
        "order": [[ 0, "desc" ]],
        "iDisplayLength": 100,
        dom: 'T<"clear">lfrtip',
        tableTools: {
            "sSwfPath": "http://cdn.datatables.net/tabletools/2.2.2/swf/copy_csv_xls_pdf.swf",
            "aButtons": ["pdf", "print", "xls" ]
        }
    });
    //============ Disabling IN/Out button =======
    var entry = $('#todays_entry').val();
    if (entry){
        $("#in").attr("disabled", "disabled");
    } else {
        $("#out").attr("disabled", "disabled");
    }
    //=========== Setting Desktop Notification ====
    notify();
} );

function notify() {
    var data = $('#salat').val();

    var zohrWaqt = new Date(JSON.parse(data)[0].time);
    var zohrWaqtHour = zohrWaqt.getHours() + 6;
    var zohrWaqtMinute = zohrWaqt.getMinutes() - 10;

    var asorWaqt = new Date(JSON.parse(data)[1].time);
    var asorWaqtHour = asorWaqt.getHours() + 6;
    var asorWaqtMinute = asorWaqt.getMinutes() - 10;

    var magribWaqt = new Date(JSON.parse(data)[2].time);
    var magribWaqtHour = magribWaqt.getHours() + 6;
    var magribWaqtMinute = magribWaqt.getMinutes() - 10;

    var currentTime = new Date(), zohr = new Date(), asor = new Date(), magrib = new Date();

    zohr.setHours(zohrWaqtHour);
    zohr.setMinutes(zohrWaqtMinute);

    asor.setHours(asorWaqtHour);
    asor.setMinutes(asorWaqtMinute);

    magrib.setHours(magribWaqtHour);
    magrib.setMinutes(magribWaqtMinute);

    if (currentTime < zohr){
         var timeout = zohr - currentTime;
        zohrMinute = (zohr.getMinutes() % 60) + 10;
        var options = {
            body: "যোহরের  নামাজে যোগ দিন।" + zohr.getHours() % 12 + ":" + zohrMinute  + " এ জামাত শুরু হবে।"
        };
    } else if (currentTime > zohr && currentTime < asor) {
        var timeout = asor - currentTime;
        asorMinute = (asor.getMinutes() % 60) + 10;
        var options = {
            body: "আসরের নামাজে যোগ দিন।" + asor.getHours() % 12 + ":" + asorMinute + " এ জামাত শুরু হবে।"
        };
    } else if (currentTime > asor && currentTime < magrib) {
        var timeout = magrib - currentTime;
        magribMinute = (magrib.getMinutes() % 60) + 10;
        var options = {
            body: "মাগরিবের নামাজে যোগ দিন।" + magrib.getHours() % 12 + ":"  + magribMinute + " এ জামাত শুরু হবে।"
        };
    }
    if (currentTime < magrib ){
        setTimeout(function() {
           if (Notification.permission === "granted") {
                var notification = new Notification("আসসালামু আলাইকুম!", options);
            }
            setTimeout(function(){
                location.reload();
            }, 60000);
        }, timeout);
    }
}

$(document).on('click', '#save', function(){

    var id, time;
    var jsonObj = [];
    $('[contenteditable=true]').each(function(){
        var item = {};

        item["id"] = $(this).attr('id');
        item["time"] = $(this).html();

        jsonObj.push(item);
    });

    $.ajax({
        url: "/attendances/update_salaat_time",
        type: "GET",
        dataType: 'json',
        data: {salaat: jsonObj},
        success: function(result){

        }
    });
})

