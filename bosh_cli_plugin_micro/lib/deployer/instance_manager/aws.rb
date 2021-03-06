# Copyright (c) 2009-2012 VMware, Inc.

module Bosh::Deployer
  class InstanceManager

    class Aws < InstanceManager

      # TODO extract
      def update_spec(spec)
        properties = spec.properties

        # pick from micro_bosh.yml the aws settings in `apply_spec` section (apply_spec.properties.aws),
        # and if it doesn't exist, use the bosh deployer aws properties (cloud.properties.aws)
        properties["aws"] = Config.spec_properties["aws"] || Config.cloud_options["properties"]["aws"].dup

        properties["aws"]["registry"] = Config.cloud_options["properties"]["registry"]
        properties["aws"]["stemcell"] = Config.cloud_options["properties"]["stemcell"]

        spec.delete("networks")
      end

      def configure
        properties = Config.cloud_options["properties"]
        @ssh_user = properties["aws"]["ssh_user"]
        @ssh_port = properties["aws"]["ssh_port"] || 22
        @ssh_wait = properties["aws"]["ssh_wait"] || 60

        key = properties["aws"]["ec2_private_key"]
        err "Missing properties.aws.ec2_private_key" unless key
        @ssh_key = File.expand_path(key)
        unless File.exists?(@ssh_key)
          err "properties.aws.ec2_private_key '#{key}' does not exist"
        end

        uri = URI.parse(properties["registry"]["endpoint"])
        user, password = uri.userinfo.split(":", 2)
        @registry_port = uri.port

        @registry_db = Tempfile.new("bosh_registry_db")

        @registry_connection_settings = {
            'adapter' => 'sqlite',
            'database' => @registry_db.path
        }

        registry_config = {
          "logfile" => "./bosh_registry.log",
          "http" => {
            "port" => uri.port,
            "user" => user,
            "password" => password
          },
          "db" => @registry_connection_settings,
          "cloud" => {
            "plugin" => "aws",
            "aws" => properties["aws"]
          }
        }

        @registry_config = Tempfile.new("bosh_registry_yml")
        @registry_config.write(Psych.dump(registry_config))
        @registry_config.close
      end

      def start
        configure()

        Sequel.connect(@registry_connection_settings) do |db|
          migrate(db)
          instances = @deployments["registry_instances"]
          db[:registry_instances].insert_multiple(instances) if instances
        end

        unless has_bosh_registry?
          err "bosh_registry command not found - " +
            "run 'gem install bosh_registry'"
        end

        cmd = "bosh_registry -c #{@registry_config.path}"

        @registry_pid = spawn(cmd)

        5.times do
          sleep 0.5
          if Process.waitpid(@registry_pid, Process::WNOHANG)
            err "`#{cmd}` failed, exit status=#{$?.exitstatus}"
          end
        end

        timeout_time = Time.now.to_f + (60 * 5)
        http_client = HTTPClient.new()
        begin
          http_client.head("http://127.0.0.1:#{@registry_port}")
          sleep 0.5
        rescue URI::Error, SocketError, Errno::ECONNREFUSED, HTTPClient::ReceiveTimeoutError => e
          if timeout_time - Time.now.to_f > 0
            retry
          else
            err "Cannot access bosh_registry: #{e.message}"
          end
        end

        logger.info("bosh_registry is ready on port #{@registry_port}")
      ensure
        @registry_config.unlink if @registry_config
      end

      def stop
        if @registry_pid && process_exists?(@registry_pid)
          Process.kill("INT", @registry_pid)
          Process.waitpid(@registry_pid)
        end

        return unless @registry_connection_settings

        Sequel.connect(@registry_connection_settings) do |db|
          @deployments["registry_instances"] = db[:registry_instances].map {|row| row}
        end

        save_state
        @registry_db.unlink if @registry_db
      end

      def discover_bosh_ip
        if exists?
          # choose elastic IP over public, as any agent connecting to the
          # deployed micro bosh will be cut off from the public IP when
          # we re-deploy micro bosh
          if cloud.ec2.instances[state.vm_cid].has_elastic_ip?
            ip = cloud.ec2.instances[state.vm_cid].elastic_ip.public_ip
          else
            ip = cloud.ec2.instances[state.vm_cid].public_ip_address
          end

          if ip && ip != Config.bosh_ip
            Config.bosh_ip = ip
            logger.info("discovered bosh ip=#{Config.bosh_ip}")
          end
        end

        super
      end

      def service_ip
        cloud.ec2.instances[state.vm_cid].private_ip_address
      end

      # @return [Integer] size in MiB
      def disk_size(cid)
        # AWS stores disk size in GiB but the CPI uses MiB
        cloud.ec2.volumes[cid].size * 1024
      end

      def persistent_disk_changed?
        # since AWS stores disk size in GiB and the CPI uses MiB there
        # is a risk of conversion errors which lead to an unnecessary
        # disk migration, so we need to do a double conversion
        # here to avoid that
        requested = (Config.resources['persistent_disk'] / 1024.0).ceil * 1024
        requested != disk_size(state.disk_cid)
      end

      private

      # TODO this code is similar to has_stemcell_copy?
      # move the two into bosh_common later
      def has_bosh_registry?(path=ENV['PATH'])
        path.split(":").each do |dir|
          return true if File.exist?(File.join(dir, "bosh_registry"))
        end
        false
      end

      def migrate(db)
        db.create_table :registry_instances do
          primary_key :id
          column :instance_id, :text, :unique => true, :null => false
          column :settings, :text, :null => false
        end
      end

    end
  end
end
