class Planocore < ApplicationRecord
  def self.controller
    "```ruby
    def create
      employee = Employee.new(employee_params)
      employee.user.person.vendor_id = @session.user.person.vendor.id
      validate_action(employee.planoadmin_read_view, 'Employee created.', Proc.new { employee.save })
    end

    def read
      employee = params[:id] ? Employee.find(params[:id]) : nil
      validate_action(employee.planoadmin_read_view, 'Employee read.')
    end

    def update
      employee = params[:id] ? Employee.find(params[:id]) : nil
      validate_action(employee.planoadmin_read_view, 'Employee updated.', Proc.new { employee.update(employee_params) })
    end
    "
  end
end
