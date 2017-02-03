// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require tether
//= require bootstrap
//= require jquery_ujs
//= require turbolinks
//= require_tree .



// // PlanoCore Callers.
//  this.create = function(callback) {
//    validate.submit_input_visible('#create_employee_form', function() {
//      planocore.write('/planoadmin/employees/create', $('#create_employee_form'), callback);
//    });
//  };
//  this.clone = function(callback) {
//    validate.submit_input_visible('#clone_employee_form', function() {
//      planocore.write('/planoadmin/employees/create/clone', $('#clone_employee_form'), callback);
//    });
//  };
//  this.validate_new_employee_email = function(callback) {
//    planocore.write('/planoadmin/employees/create/check_email', $('#new_employee_email_check_form'), callback);
//  };
//  this.read = function(employee, callback) {
//    planocore.read('/planoadmin/employees/read', employee.model.id, callback);
//  };
//  this.update = function(callback) {
//    validate.submit_input_visible('#update_employee_form', function() {
//      planocore.write('/planoadmin/employees/update', $('#update_employee_form'), callback);
//    });
//  };
