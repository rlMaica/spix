(function() {
	angular.module('mainController.ctrl', []).controller('MainControllerCtrl', ['$rootScope', '$scope', '$http', function($rootScope, $scope, $http) {

		// var socket = io('http://10.2.15.36:3000');
		var socket = io('http://172.27.2.174:3000');

		$scope.key = '';
		$scope.album = [];
		$scope.selectedPhoto = null;
		$scope.showQrCode = true;
		$scope.showPhoto = false;

		$scope.init = function() {

			$scope.initQrCode();

			socket.emit('join', $scope.key);

			socket.on('user-connected', function(data) {
				$scope.showQrCode = false;
				$scope.$apply();
			});

			socket.on('send-front', function(data) {
				console.log("Foto: " + data.index);
				data.image = 'data:image/png;base64,' + data.image;
				$scope.album.push(data);
				$scope.$apply();

				$scope.setPhoto(data.image);
			});

			socket.on('reset-connection', function(data) {
				console.log('Reset Connection');
				$scope.resetConnection();
				$scope.initQrCode();
			})
		};

		$scope.initQrCode = function() {
			$scope.key = document.getElementById('key').value;

			var qrcode = new QRCode(document.getElementById("qrcode"), {
				width : 300,
				height : 300,
				colorDark : "#333333",
				colorLight : "#ffffff",
				correctLevel : QRCode.CorrectLevel.H
			});
			qrcode.makeCode($scope.key);
		};

		$scope.resetConnection = function() {
			$scope.key = '';
			$scope.album = [];
			$scope.selectedPhoto = null;
			$scope.showPhoto = false;
			$scope.showQrCode = true;
			$scope.$apply();
		};

		$scope.setPhoto = function(img){
			$scope.selectedPhoto = img;
			$scope.showPhoto = true;
			$scope.showQrCode = false;
			$scope.$apply();
		};
	}]);
})();