var woda = angular.module('Woda', [
  'ngRoute',
  'Authentication'
]);

woda.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/login', {
        templateUrl: 'app/src/views/login.html',
        controller: 'AuthenticationController'
      }).
      when('/list', {
        templateUrl: 'app/src/views/list.html',
        //controller: 'PhoneDetailCtrl'
      }).
      otherwise({
        redirectTo: (false) ? '/list' : '/login'
      });
}]);

woda.value('version', '0.1');