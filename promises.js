/* npm install q */
"use strict";

(function () {
	var Q = require("Q");
	var FS = require("fs");
	var output = function(tag) {
		return function(s) {
			console.log(tag, s);
		};
	};

	// Helpers
	var wrap = function (v) {
		return Q.fcall(function () {
			return v;
		});
	};

	var readFile = function (filename) {
		var deferred = Q.defer();
		FS.readFile(filename, "utf-8", function (error, text) {
			if (error) {
				deferred.reject(new Error(error));
			} else {
				deferred.resolve(text);
			}
		});
		return deferred.promise;
	};

	// Examples 1
	function example1() {
		wrap(1)
		.then(function(value) {
			if (value == 1) {
				return 2;
			} else {
				return 3;
			}
		})
		.then(output("example 1:"))
		.end();
	}

	// Example 2
	function example2() {
		var process1 = function (x) { return x + 2; };
		var process2 = function (x) { return x * 3; };

		wrap(4)
		.then(process1)
		.then(process2)
		.then(output("example 2:"))
		.end();
	}

	// Example 3
	function example3() {
		var process = function (x) { throw "error"; };

		wrap(3)
		.then(process)
		.then(function (value) {
			return value;
		}, function (error) {
			return 5;
		})
		.then(output("example 3:"))
		.end();
	}

	function example4() {
		var promise1 = wrap(1);
		var promise2 = wrap(2);

		Q.all([promise1, promise2])
		.then(function(xy) {
			return xy[0] + xy[1];
		})
		.then(output("example 4:"))
		.end();
	}

	function example5() {
		var promise1 = wrap(1);
		var promise2 = wrap(2);
		var promise3 = wrap(3);

		Q.all([promise1, promise2, promise3])
		.then(function(xs) {
			return xs.reduce(function(x, y) { return x + y }, 4);
		})
		.then(output("example 5:"))
		.end();
	}

	function example6() {
		readFile("promises.js")
		.then(function(value) {
			return value.slice(0, 100).toUpperCase();
		})
		.then(output("example 6:\n"))
		.end();
	}

	function example7() {
		var promise = wrap(15);

		promise.then(output("example 7:"));
		promise.then(output("example 7:"));
	}

	// Running examples
	example1();
	example2();
	example3();
	example4();
	example5();
	example6();
	example7();
}());
