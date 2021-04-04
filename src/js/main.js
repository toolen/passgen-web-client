(function () {
    var httpRequest,
        password = '',
        passwordLengthInput = document.getElementById('len'),
        err = document.getElementById('error'),
        excludePunctuationCheckbox = document.getElementById('exclude_punctuation'),
        outputElement = document.getElementById('out'),
        refreshButton = document.getElementById('refresh'),
        revealButton = document.getElementById('reveal'),
        copyToClipboardButton = document.getElementById('clipboard');

    function makeRequest() {
        var excludePunctuation = excludePunctuationCheckbox.checked ? 'true' : '';

        password = '';
        outputElement.value = '';
        err.innerText = '';

        httpRequest = new XMLHttpRequest();

        if (!httpRequest) {
            err.innerText = 'Giving up :( Cannot create an XMLHTTP instance';
            return false;
        }
        httpRequest.onreadystatechange = alertContents;
        httpRequest.open('GET', 'https://passgen.zakharov.cc/api/v1/passwords?length=' + passwordLengthInput.value + '&exclude_punctuation=' + excludePunctuation);
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
                            outputElement.value = outputElement.value + c
                        }, i * 20)
                    })(char);
                }
            } else {
                err.innerText = data['description'];
            }
        }
    }

    function reveal() {
        if(outputElement.type === 'password') {
            outputElement.type = 'text';
            revealButton.innerText = 'Hide password';
        } else {
            outputElement.type = 'password';
            revealButton.innerText = 'Show password';
        }
    }

    if (navigator.clipboard) {
        copyToClipboardButton.addEventListener('click', function() {
            navigator.clipboard.writeText(password).then(function() {
                //
            }, function() {
                //
            });
        });
    } else {
        copyToClipboardButton.style.display = 'none';
    }

    passwordLengthInput.addEventListener('input', makeRequest);
    excludePunctuationCheckbox.addEventListener('change', makeRequest);
    refreshButton.addEventListener('click', makeRequest);
    revealButton.addEventListener('click', reveal);

    makeRequest();
})();
