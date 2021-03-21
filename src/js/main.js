(function () {
    var httpRequest,
        password = '',
        len = document.getElementById('len'),
        btn = document.getElementById('btn'),
        out = document.getElementById('out'),
        err = document.getElementById('error'),
        clipboard = document.getElementById('clipboard');

    function makeRequest() {
        password = '';
        out.value = '';
        err.innerText = '';

        httpRequest = new XMLHttpRequest();

        if (!httpRequest) {
            err.innerText = 'Giving up :( Cannot create an XMLHTTP instance';
            return false;
        }
        httpRequest.onreadystatechange = alertContents;
        httpRequest.open('GET', 'https://passgen.zakharov.cc/api/v1/passwords?length=' + len.value);
        httpRequest.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
        httpRequest.responseType = 'json';
        httpRequest.send();
    }

    function alertContents() {
        if (httpRequest.readyState === XMLHttpRequest.DONE) {
            var data = httpRequest.response;
            if (httpRequest.status === 200) {
                var char;
                password = data['password'];
                for (var i=0; i < password.length; i++) {
                    char = password[i];
                    (function(c) {
                        setTimeout(function() {
                            out.value = out.value + c
                        }, i * 20)
                    })(char);
                }
            } else {
                err.innerText = data['description'];
            }
        }
    }

    if (navigator.clipboard) {
        clipboard.addEventListener('click', function() {
            navigator.clipboard.writeText(password).then(function() {
                //
            }, function() {
                //
            });
        });
    } else {
        clipboard.style.display = 'none';
    }

    len.addEventListener('input', makeRequest);
    btn.addEventListener('click', makeRequest);

    makeRequest();
})();
