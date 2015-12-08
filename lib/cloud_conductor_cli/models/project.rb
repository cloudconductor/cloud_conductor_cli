require 'thor'

module CloudConductorCli
  module Models
    class Project < Thor
      include Models::Base

      desc 'list', 'List projects'
      def list
        response = connection.get('/projects')
        output(response)
      end

      desc 'show PROJECT', 'Show project details'
      def show(project)
        id = find_id_by(:project, :name, project)
        response = connection.get("/projects/#{id}")
        output(response)
      end

      desc 'create', 'Create new project'
      method_option :name,          type: :string, required: true, desc: 'User specified project name'
      method_option :description,   type: :string, desc: 'Project description'
      def create
        payload = declared(options, self.class, :create)
        response = connection.post('/projects', payload)
        message('Create completed successfully.')
        output(response)
      end

      desc 'update PROJECT', 'Update project information'
      method_option :name,        type: :string, desc: 'User specified project name'
      method_option :description, type: :string, desc: 'Project description'
      def update(project)
        id = find_id_by(:project, :name, project)
        payload = declared(options, self.class, :update)
        response = connection.put("/projects/#{id}", payload)
        message('Update completed successfully.')
        output(response)
      end

      desc 'delete PROJECT', 'Delete project'
      def delete(project)
        id = find_id_by(:project, :name, project)
        connection.delete("/projects/#{id}")
        message('Delete completed successfully.')
      end

      desc 'list-account PROJECT', 'List account on project'
      def list_account(project)
        id = find_id_by(:project, :name, project)
        payload = declared(options, self.class, :list_account)
        payload = payload.merge('project_id' => id)
        response = connection.get('/accounts', payload)
        output(response)
      end

      desc 'add-account PROJECT', 'Add account to project'
      method_option :account, type: :string, required: true, desc: 'Account email or id'
      def add_account(project)
        project_id = find_id_by(:project, :name, project)
        account_id = find_id_by(:account, :email, options[:account])
        payload = declared(options, self.class, :add_account)
                  .except('account')
                  .merge('project_id' => project_id, 'account_id' => account_id)

        response = connection.post('/assignments', payload)
        output(response)
      end

      desc 'remove-account PROJECT', 'Remove account from project'
      method_option :account, type: :string, required: true, desc: 'Account email or id'
      def remove_account(project)
        project_id = find_id_by(:project, :name, project)
        account_id = find_id_by(:account, :email, options[:account], project_id: project_id)
        assignment_id = find_id_by(:assignment, :account_id, account_id, project_id: project_id)

        connection.delete("/assignments/#{assignment_id}")
        message('Delete completed successfully.')
      end
    end
  end
end
