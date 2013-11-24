angular.module('Authentication').factory('Auth', ['$resource', function($resource) {
	var headers = { 'Content-Type': 'application/x-www-form-urlencoded' };

	return ($resource('https://kobhqlt.fr:3000/users', {}, {
			login: {
				url: 'https://kobhqlt.fr:3000/users/:user/login',
				method:'POST',
				params: {
					user: '@user',
					password: '@password'
				},
				//withCredentials: true,
				headers: headers
			}, logout: {
				url: 'https://kobhqlt.fr:3000/users/logout',
				method:'GET',
				//withCredentials: true,
				headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
			}, read: {
				url: 'https://kobhqlt.fr:3000/users',
				method:'GET',
				headers: headers
			}, create: {
				url: 'https://kobhqlt.fr:3000/users/:user',
				method: 'PUT',
				params: {
					user: '@user',
					password: '@password',
					email: '@email'
				},
				headers: headers
			}, delete: {
				url: 'https://kobhqlt.fr:3000/users',
				method: 'DELETE',
				headers: headers
			}
		}
	));
}]);