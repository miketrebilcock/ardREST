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

    // jsonp callback
    ardREST = function(e) {
        if(e.status === 'success') {
            console.log('hier', e);
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

});