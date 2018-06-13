(function() {
	"use strict";

	angular.module('app', [
		'mainController.ctrl'
	]);

	// .config(['$routeProvider', '$httpProvider', function($routeProvider, $httpProvider) {
	// 	$routeProvider.when("/", {
	// 		redirectTo: "/home"
	// 	})
	// 	.when('/home', {
	// 		templateUrl: 'views/login.html',
	// 		controller: 'LoginCtrl'
	// 	})
	// 	.otherwise({
	// 		redirectTo: '/home'
	// 	})
	// }]);
})();