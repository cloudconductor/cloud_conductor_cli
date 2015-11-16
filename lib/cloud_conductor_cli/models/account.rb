require 'thor'

module CloudConductorCli
  module Models
    class Account < Thor
      include Models::Base

      desc 'list', 'List accounts'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        payload = declared(options, self.class, :list).except('project')
        if options['project']
          project_id = find_id_by(:project, :name, options[:project])
          payload = payload.merge('project_id' => project_id)
        end
        response = connection.get('/accounts', payload)
        output(response)
      end

      desc 'show ACCOUNT', 'Show account details'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(account)
        payload = declared(options, self.class, :list).except('project')
        if options['project']
          project_id = find_id_by(:project, :name, options[:project])
          id = find_id_by(:account, :email, account, project_id: project_id)
          payload = payload.merge('project_id' => project_id)
        else
          id = find_id_by(:account, :email, account)
        end
        response = connection.get("/accounts/#{id}", payload)
        output(response)

        return unless options['project']

        payload = payload.merge('account_id' => id)
        response = connection.get('/roles', payload)
        message('Roles:')
        output(response)
      end

      desc 'create', 'Create new account'
      method_option :email, type: :string, required: true, desc: 'Account email'
      method_option :name, type: :string, required: true, desc: 'Account user name'
      method_option :password, type: :string, required: true, desc: 'Account password'
      method_option :admin, type: :boolean, desc: 'Admin or not', default: false
      method_option :project, type: :string, desc: 'Project name or id'
      method_option :role, type: :string, desc: 'Role name or id'
      def create
        payload = declared(options, self.class, :create)
                  .except('project', 'role')
                  .merge('password_confirmation' => options['password'],
                         'admin' => options['admin'] ? 1 : 0)
        if options['project']
          project_id = find_id_by(:project, :name, options[:project])
          payload = payload.merge('project_id' => project_id)
          if options['role']
            role_id = find_id_by(:role, :name, options[:role], project_id: project_id)
            payload = payload.merge('role_id' => role_id)
          end
        end
        response = connection.post('/accounts', payload)

        message('Create completed successfully.')
        output(response)
      end

      desc 'update ACCOUNT', 'Update account'
      method_option :email, type: :string, desc: 'Account email'
      method_option :name, type: :string, desc: 'Account user name'
      method_option :password, type: :string, desc: 'Account password'
      method_option :admin, type: :boolean, desc: 'Admin or not', default: false
      def update(account)
        id = find_id_by(:account, :email, account)
        payload = declared(options, self.class, :update)
                  .merge('password_confirmation' => options['password'],
                         'admin' => options['admin'] ? 1 : 0)
        response = connection.put("/accounts/#{id}", payload)

        message('Update completed successfully.')
        output(response)
      end

      desc 'delete ACCOUNT', 'Delete account'
      def delete(account)
        id = find_id_by(:account, :email, account)
        connection.delete("/accounts/#{id}")

        message('Delete completed successfully.')
      end

      desc 'add-role ACCOUNT', 'Add role to account'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :role, type: :string, required: true, desc: 'Role name or id'
      def add_role(account)
        account_id = find_id_by(:account, :email, account)
        project_id = find_id_by(:project, :name, options['project'])
        role_id = find_id_by(:role, :name, options['role'], project_id: project_id)
        assignment_id = find_id_by(:assignment, :account_id, account_id, project_id: project_id)

        payload = declared(options, self.class, :update)
                  .except('project', 'role')
                  .merge('role_id' => role_id)

        response = connection.post("/assignments/#{assignment_id}/roles", payload)
        message('Create completed successfully.')
        output(response)
      end

      desc 'remove-role ACCOUNT', 'Remove role from account'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :role, type: :string, required: true, desc: 'Role name or id'
      def remove_role(account)
        account_id = find_id_by(:account, :email, account)
        project_id = find_id_by(:project, :name, options['project'])
        role_id = find_id_by(:role, :name, options['role'], project_id: project_id)
        assignment_id = find_id_by(:assignment, :account_id, account_id, project_id: project_id)
        assignment_role_id = find_id_by(:role, :role_id, role_id, parent_model: :assignment, parent_id: assignment_id, project_id: project_id)

        connection.delete("/assignments/#{assignment_id}/roles/#{assignment_role_id}")
        message('Delete completed successfully.')
      end
    end
  end
end
