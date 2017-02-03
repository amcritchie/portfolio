class Planoadmin < ApplicationRecord
  def self.controller
    "```js
  // Employee | Create
  $scope.create = function() {
     employeeService.create(function(response) {
       employee = response.data;
       // Notify success
       notify.success('Employee ' + employee.user.person.email + ' created.');
       // Refresh the new_employee object.
       $scope.new_employee = {user: {model: {language: 'en', time_zone: 'pst'}}};
       // Push creeated employee into the employees index.
       $scope.employees.push(employee);
       // Bind edit_employee to created employee.
       bind_edit_employee_to(employee);
       // Setup edit_employee.
       $scope.edit(employee);
     });
   };
   // Employee | Read
   $scope.read = function(employee, target) {
     // Revert any unsaved changes to $scope.edit_employee.
     $scope.update_edit_employee_to($scope.original_employee);
     // Bind edit_employee to index employee.
     bind_edit_employee_to(employee);
     // Set target sub-tab for edit_employee.
     $scope.edit_tab = target || '#edit_employee_details_tab'
     // Get full employee object from PlanoCore, then setup edit_employee.
     employeeService.read(employee, $scope.edit);
   };
   // Employee | Edit
   $scope.edit = function(employee_or_response) {
     employee = employee_or_response.data || employee_or_response;
     // Show edit_employee_tab if not already shown.
     $('#employee_tabs [data-target=#edit_employee_tab]').tab('show');
     // Show edit_employee sub-tab
     $('[data-target=' + $scope.edit_tab + ']').tab('show');
     // Replace edit_employee with full employee object.
     $scope.update_edit_employee_to(employee);
     // Fetch first chunk of employees' roles and setup infinity scroll.
     employeeService.init_applications_index(employee.model.id, function(response, first_set) {
       // We want to add the users_roles to original_employee aswell so detecting a change between edit and original is accurate.
       $scope.edit_employee.users_roles = (first_set) ? response.data.list : $scope.edit_employee.users_roles.concat(response.data.list);
       $scope.original_employee.users_roles = (first_set) ? response.data.list : $scope.original_employee.users_roles.concat(response.data.list);
     });
   };
   // Employee | Update
   $scope.update = function() {
     employeeService.update(function(response) {
       // Notify success
       notify.success('Employee ' + response.data.user.person.email + ' updated.');
       // Update the scope of edit_employee.
       $scope.update_edit_employee_to(response.data);
     });
   };
    "
  end
end
