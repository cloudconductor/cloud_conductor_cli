require 'thor'

module CloudConductorCli
  module Models
    class Audit < Thor
      include Models::Base

      desc 'list', 'List audits'
      method_option :project, type: :string, desc: 'Project name or id'
      def list
        project_id = find_id_by(:project, :name, options[:project]) if options[:project]
        payload = { 'project_id' => project_id }
        response = connection.get('/audits', payload)
        output(response)
      end
    end
  end
end
