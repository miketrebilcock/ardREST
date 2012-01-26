$(document).ready(function () {
    // make a jsonp request
    function makeRequest(data) {
        $.ajax({
            type: 'GET',
            url: 'http://192.168.250.4/' + data,
            dataType: 'jsonp',
            jsonp: 'jsonp'
        });
    }

    function checkValues() {
        $('.check').each(function () {
            var pin = $(this).get(0).id.substr(3);
            makeRequest(pin);
        });
    }

    // jsonp callback
    ardREST = function(e) {
        if(e.status === 'success') {
            if(e.value === 'HIGH') {
                $('#pin' + e.pin.substring(0,1)).prop("checked", true);
            }
        }
    };

    // trigger checkboxes
    $('.check').each(function () {
        $(this).click(function (e) {
            var pin,
                checked,
                value,
                data;

            pin = e.target.id.substring(3);
            checked = e.target.checked;
            if(checked === true) {
                value = 'HIGH';
            } else {
                value = 'LOW';
            }
            data = pin + '/' + value;

            makeRequest(data);

        });
    });

    // uncomment the line below to check current values of the pins
    //checkValues();

});