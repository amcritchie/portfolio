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

  def self.service
    "```js
    // PlanoCore Callers.
     this.create = function(callback) {
       validate.submit_input_visible('#create_employee_form', function() {
         planocore.write('/planoadmin/employees/create', $('#create_employee_form'), callback);
       });
     };
     this.clone = function(callback) {
       validate.submit_input_visible('#clone_employee_form', function() {
         planocore.write('/planoadmin/employees/create/clone', $('#clone_employee_form'), callback);
       });
     };
     this.validate_new_employee_email = function(callback) {
       planocore.write('/planoadmin/employees/create/check_email', $('#new_employee_email_check_form'), callback);
     };
     this.read = function(employee, callback) {
       planocore.read('/planoadmin/employees/read', employee.model.id, callback);
     };
     this.update = function(callback) {
       validate.submit_input_visible('#update_employee_form', function() {
         planocore.write('/planoadmin/employees/update', $('#update_employee_form'), callback);
       });
     };
    "
  end

  def self.edit_form
    "```html
    <div>
      <!-- Employee Avatar -->
      <div class='gradient-container'>
        <img height='70' width='70' class='img-circle pull-left margin-right-15' ng-click='edit_avatar(edit_employee);' data-toggle='modal' data-target='#upload_employee_avatar_modal' data-backdrop='static' alt='Avatar' ng-src='{{edit_employee.user.avatar.asset.file_path || $root.vendor.mark.asset.file_path || '/assets/planomatic_mark.jpg'}}'>
        <div class='gradient sm-circle-gradient'>
          <p class='gradient-message-24'>Update</p>
        </div>
      </div>
      <!-- Actions -->
      <h2 class='margin-top-10' ng-class='!edit_employee.user.model.active ? 'text-red' : '''>Edit
        <div class='pull-right margin-top--5'>
          <input ng-if='employee_changed && edit_employee.user.person.email' class='btn btn-success' type='submit' value='Update'>
          <a ng-if='employee_changed' class='btn btn-danger' ng-click='update_edit_employee_to(original_employee)'>Revert</a>
          <a class='btn btn-primary' ng-click='new()'><i class='fa fa-times'></i></a>
        </div>
      </h2>
    </div>
    <!-- Employee's Full Name -->
    <div>
      <h3 class='margin-top-10' ng-class='!edit_employee.user.model.active ? 'text-red' : '''>
        {{edit_employee.user.person.first_name}}&nbsp;{{edit_employee.user.person.last_name}}
        <span ng-if='!edit_employee.user.model.active && $root.session.access.permissions.employees.dispose' ng-mouseenter='show = true' ng-mouseleave='show = false'>
          <a ng-show='!show' class='btn btn-danger margin-left-10 margin-top--5 pull-right' data-toggle='modal' data-target='#confirm_activate_employee_modal'>Deactive</a>
          <a ng-show='show' class='btn btn-success margin-left-10 margin-top--5 pull-right' data-toggle='modal' data-target='#confirm_activate_employee_modal'>Activate</a>
        </span>
        <span ng-if='!edit_employee.user.model.active && !$root.session.access.permissions.employees.dispose' ng-mouseenter='show = true' ng-mouseleave='show = false' class='text-red pull-right'>
          Deactive
        </span>
      </h3>
    </div>
    <!-- Form Tabs -->
    <ul class='nav nav-tabs'>
      <li class='active'><a data-target='#edit_employee_details_tab' data-toggle='tab'>Details</a></li>
      <li ng-if='(edit_employee.user.person.email)'><a data-target='#edit_employees_roles_tab' data-toggle='tab'>Roles</a></li>
      <li ng-if='(edit_employee.user.person.email)'><a data-target='#edit_employees_actions_tab' data-toggle='tab'>Actions</a></li>
    </ul>
    <!-- Tab Content -->
    <div class='tab-content'>
      <!-- Employee's Details -->
      <div class='tab-pane active' id='edit_employee_details_tab'>
        <br>
        <div class='row'>
          <div class='form-group col-xs-6'>
            <label for='user.person.first_name'>First Name:</label>
            <input class='form-control' type='text' ng-model='edit_employee.user.person.first_name' name='employee[user_attributes][person_attributes][first_name]' ng-change='change()'>
          </div>
          <div class='form-group col-xs-6'>
            <label for='user.person.last_name'>Last Name:</label>
            <input class='form-control' type='text' ng-model='edit_employee.user.person.last_name' name='employee[user_attributes][person_attributes][last_name]' ng-change='change()'>
          </div>
        </div>
        <div class='row'>
          <div class='form-group col-xs-12'>
            <label for='user.person.email'>Email:</label>
            <input slugify class='form-control' type='text' ng-model='edit_employee.user.person.email' name='employee[user_attributes][person_attributes][email]' ng-change='change()'>
          </div>
        </div>
        <div class='row'>
          <div class='form-group col-xs-12'>
            <label for='user.password'>Password:</label>
            <input class='form-control' type='password' ng-model='edit_employee.user.model.password' name='employee[user_attributes][password]' ng-change='change()'>
          </div>
        </div>
        <div class='row'>
          <div class='form-group col-xs-12'>
            <label for='language'>Language:</label>
            <select class='form-control' ng-model='edit_employee.user.model.language' name='employee[user_attributes][language]' ng-change='change()'>
              <option value='en'>English</option>
              <option value='sp'>Spanish</option>
            </select>
          </div>
        </div>
        <div class='row'>
          <div class='form-group col-xs-12'>
            <label for='time_zone'>Time Zone:</label>
            <select class='form-control' ng-model='edit_employee.user.model.time_zone' name='employee[user_attributes][time_zone]' ng-change='change()'>
              <option value='pst'>Pacific Standard Time</option>
              <option value='mst'>Mountain Standard Time</option>
              <option value='cst'>Central Standard Time</option>
              <option value='est'>Eastern Standard Time</option>
            </select>
          </div>
        </div>
        <div class='row'>
          <div class='form-group col-xs-12'>
            <label for='department'>Department:</label>
            <select name='employee[department_id]' ng-model='edit_employee.model.department_id' ng-change ='change()' class='form-control' ng-options='department.id as department.name for department in $root.vendor.departments'>
              <option value=''>None</option>
            </select>
          </div>
        </div>
      </div>
    </div>
    "
  end
end
