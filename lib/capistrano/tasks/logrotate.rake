namespace :load do
  task :defaults do
    set :logrotate_role, :app
    set :logrotate_conf_path, -> { File.join('/etc', 'logrotate.d', "#{fetch(:application)}_#{fetch(:stage)}") }
    set :logrotate_log_path, -> { File.join(shared_path, 'log') }
  end
end

namespace :logrotate do
  desc 'Setup logrotate config file'
  task :config do
    on roles(fetch(:logrotate_role)) do |role|
      upload_logrotate_template
    end
  end

  def upload_logrotate_template
    path = File.expand_path("../../templates/logrotate.erb", __FILE__)

    if File.file?(path)
      erb = File.read(path)
      config_path = File.join(shared_path, 'logrotate_conf')
      logrotate_conf = fetch(:logrotate_conf_path)
      upload! StringIO.new(ERB.new(erb).result(binding)), config_path

      sudo "mv '#{config_path}' '#{logrotate_conf}'"
      sudo "chown root:root '#{logrotate_conf}'"
    end
  end
end
