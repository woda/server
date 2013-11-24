angular.module('Authentication').controller('AuthenticationController', ['$scope', '$cookieStore', 'Auth', function($scope, $cookieStore, Auth) {
	$scope.user = 'louis';
	$scope.password = 'azerty';

	$scope.login = function(user, password) {
		Auth.login({ user: user, password: password }, function(data, responseHeaders) {
				console.debug('cookie:', document.cookie);
				//console.debug($cookieStore.get('_server_session'));
				console.debug('responseHeader:', responseHeaders());
			}, function(data) {
				console.debug('login: error', data);
		});
/*
		Auth.read({}, function(data) {
				console.debug('read: success', data);
			}, function(data) {
				console.debug('read: error', data);
		});
/*
		Auth.create({
				user: 'toto',
				password: 'password',
				email: 'einsenhorn@gmail.com'
			}, function(data) {
				console.debug('create: success', data);
			}, function(data) {
				console.debug('create: error', data);
		});
*/
	};

	$scope.logout = function() {
		Auth.logout({}, function(data) {
				console.debug('logout: success', data);
			}, function(data) {
				console.debug('logout: error', data);
		});
	}

	$scope.delete = function() {
		Auth.delete({}, function(data) {
				console.debug('delete: success', data);
			}, function(data) {
				console.debug('delete: error', data);
		});
	}
}]);