require 'thor'

module CloudConductorCli
  module Models
    class Role < Thor
      include Models::Base

      desc 'list', 'List roles'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        payload = declared(options, self.class, :list).except('project')
                  .merge('project_id' => project_id)
        response = connection.get('/roles', payload)
        output(response)
      end

      desc 'show ROLE', 'Show role details'
      method_option :project, type: :string, desc: 'Project name or id'
      def show(role)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:role, :name, role, project_id: project_id)
        response = connection.get("/roles/#{id}")
        output(response)

        response = connection.get("/roles/#{id}/permissions")
        message('Permissions:')
        output(response)
      end

      desc 'create', 'Create role'
      method_option :project, type: :string, required: true, desc: 'Project name or id'
      method_option :name, type: :string, required: true, desc: 'Role name'
      method_option :description, type: :string, desc: 'Role description'
      def create
        project_id = find_id_by(:project, :name, options[:project])
        payload = declared(options, self.class, :create).except('project').merge('project_id' => project_id)
        response = connection.post('/roles', payload)
        message('Create completed successfully.')
        output(response)
      end

      desc 'update ROLE', 'Update role'
      method_option :name, type: :string, desc: 'Role name'
      method_option :description, type: :string, desc: 'Role description'
      method_option :project, type: :string, desc: 'Project name or id'
      def update(role)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:role, :name, role, project_id: project_id)

        payload = declared(options, self.class, :update).except(:project)
        response = connection.put("/roles/#{id}", payload)
        message('Update completed successfully.')
        output(response)
      end

      desc 'delete ROLE', 'Delete role'
      method_option :project, type: :string, desc: 'Project name or id'
      def delete(role)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:role, :name, role, project_id: project_id)
        connection.delete("/roles/#{id}")
        message('Delete completed successfully.')
      end

      desc 'add-permission ROLE', 'Add permission'
      method_option :model, type: :string, required: true, desc: 'model name'
      method_option :action, type: :string, required: true, desc: 'action(manage, read, create, update, destroy) '
      method_option :project, type: :string, desc: 'Project name or id'
      def add_permission(role)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:role, :name, role, project_id: project_id)
        payload = declared(options, self.class, :add_permission).except(:project)
        response = connection.post("/roles/#{id}/permissions", payload)
        message('Update completed successfully.')
        output(response)
      end

      desc 'remove-permission ROLE', 'Remove permission'
      method_option :model, type: :string, required: true, desc: 'model name'
      method_option :action, type: :string, required: true, desc: 'action (manage, read, create, update, destroy) '
      method_option :project, type: :string, desc: 'Project name or id'
      def remove_permission(role)
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        id = find_id_by(:role, :name, role, project_id: project_id)
        records = where(:permission, { model: options[:model] }, parent_model: :role, parent_id: id)
        records = records.select do |record|
          record['action'] == options[:action]
        end if records
        error_exit("permission {:model => '#{options[:model]}', :action => '#{options[:action]}'} does not exist.") if records.length == 0
        records.each do |record|
          connection.delete("/roles/#{id}/permissions/#{record['id']}")
        end
        message('Delete completed successfully.')
      end
    end
  end
end
