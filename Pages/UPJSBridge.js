(function() {
	// Times 33 hash
	String.prototype.times33Hash = function() {
		var hash = 5381, index = this.length;
		while (index) {
			hash = (hash * 33) ^ this.charCodeAt(--index);
		}
		return hash >>> 0;
	}

	// Simple AJAX
	function ajax(options) {
		options = options || {};
		options.type = (options.type || "GET").toUpperCase(); 
		options.dataType = options.dataType || 'json';
	 	options.async = options.async || true;
		var params = getParams(options.data);
		var xhr; 
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		} else {
			xhr = new ActiveXObject('Microsoft.XMLHTTP')
		} 
		xhr.onreadystatechange = function() { 
			if (xhr.readyState == 4) {
				var status = xhr.status;
				if (status >= 200 && status < 300) {
					options.success && options.success(xhr.responseText,xhr.responseXML);
				} else {
					options.error && options.error(status);
				}
			 } 
	 	};
		if (options.type == 'GET') { 
			xhr.open("GET", options.url + '?' + params, options.async);
			xhr.send(null);
		} else if (options.type == 'POST') { 
			xhr.open('POST', options.url, options.async);
			xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
			xhr.send(params);
		}

		function getParams(data) {
			var arr = [];
			for (var param in data) {
				arr.push(encodeURIComponent(param) + '=' +encodeURIComponent(data[param]));
			}
			return arr.join('&');
		}
	}

	window.UPJSBridge = {
  	random: function(n, m) {
        return Math.random() * (m - n) + n
    },
  	callNativeByURL: function(opt) {
  		if (window.bridgeWebView) {
  			var api = opt.api || null;
	  		var params = opt.params || {};
	  		var callback = opt.callback || function() {};
	  		var callURL = ['upbridgescheme://' + api];

	  		// Add API name
	  		callURL.push('?wv=' + window.bridgeWebView);

	  		// Add random callback name, need remove when finished.
	  		var timestamp = Date.parse(new Date());
	  		var paramString = encodeURIComponent(JSON.stringify(params));
	  		var randomNum = Math.ceil(UPJSBridge.random(0, 10000));
	  		var callIdentifier = (api + paramString + timestamp + randomNum).times33Hash();
	  		console.log(callIdentifier);
	  		var callbackRand = 'cb' + callIdentifier;
	        window[callbackRand] = function() {
	            // Can only run once.
	            if (window[callbackRand]._exec > 0) return;
	            window[callbackRand]._exec++;
	            callback(arguments[0]);
	            // Remove random function
	            setTimeout(function() {
	                delete window[callbackRand];
	                // Remove random parameters
	                delete window[paramRand];
	            }, 100);
	        };
	        window[callbackRand]._exec = 0;
	        callURL.push('&cb=' + callbackRand);

	        // Add random params name, need remove when finished.
	        var paramRand = 'p' + callIdentifier;
	        window[paramRand] = JSON.stringify(params);
	        callURL.push('&p=' + paramRand);

	        // New iframe open URL.
			var iframe = document.createElement('iframe');
		    iframe.style.display = 'none';
		    iframe.src = callURL.join('');
		    document.documentElement.appendChild(iframe);
		    setTimeout(function() { 
		      	document.documentElement.removeChild(iframe);
		    }, 1000);
		} else {
			console.log('No bridgeWebView set.');
		}
  	},
  	callNativeByAJAX: function(opt) {
  		var api = opt.api || null;
  		var params = opt.params || {};
  		var callback = opt.callback || function() {};
  		var baseAJAXURL = 'http://ajax.call.native/';
  		ajax({
			url: baseAJAXURL + api,
	      	data: params,
	      	success: function(data) {
	        	callback(data);
			},
			error: function(status) {
				console.log('ajax error status: ' + status);
			}
		});
  	}
  };
})();