require 'fog'
require 'colorize'

# f = Fog::Compute.new({:provider => "Libvirt" , 
# 										 :libvirt_uri => "qemu:///system"})

class KvmQuick

	def initialize(options)
		@options = options.dup

		puts "#{@options}".colorize( :light_green )
	
		kvm_params = {
			:provider => "Libvirt",
			:libvirt_uri => "qemu:///system"
		}

		@agent_properties = @options["agent"] || {}
		@pool = @options["pool"] || "bosh"
		@network = @options["network"] || "bosh"

		begin
			@kvm = Fog::Compute.new(kvm_params)
		rescue Exception => e
			one_error( "Error #{e}" )
		end

	end

	def info

		puts "Domains ( guest ) list".colorize( :light_white )
		puts "@kvm.servers.all #{@kvm.servers.all}".colorize( :blue )

		puts "Volumes list".colorize( :light_white )
		puts "@kvm.volumes.all #{@kvm.volumes.all}".colorize( :green ) 

		puts "Pools list".colorize( :light_white )
		puts "@kvm.pools.all #{@kvm.pools.all}".colorize( :magenta )

		puts "Networks list".colorize( :light_white )
		puts "@kvm.networks.all #{@kvm.networks.all}".colorize( :light_red )

		puts "Interfaces list".colorize( :light_white )
		puts "@kvm.interfaces.all #{@kvm.interfaces.all}".colorize( :yellow ) 

		puts "Nodes list".colorize( :light_white )
		puts "@kvm.nodes.all #{@kvm.nodes.all}".colorize( :red ) 

		puts "#{@pool}".colorize( :blue )
		puts @kvm.list_volumes(:pool_name => "#{@pool}")


		# request :list_domains
		# request :create_domain
		# request :define_domain
		# request :vm_action
		# request :list_pools
		# request :list_pool_volumes
		# request :define_pool
		# request :pool_action
		# request :list_volumes
		# request :volume_action
		# request :create_volume
		# request :list_networks
		# request :destroy_network
		# request :list_interfaces
		# request :destroy_interface
		# request :get_node_info
		# request :update_display


		puts "@kvm.list_domains".colorize( :light_white )
		puts @kvm.list_domains
		puts
		# puts @kvm.create_domain
		# puts @kvm.define_domain
		# puts @kvm.vm_action
		puts "@kvm.list_pools".colorize( :light_white )
		puts @kvm.list_pools
		@kvm.list_pools.each do |p|
			puts "#{p}".colorize( :light_yellow )
			puts "@kvm.list_pool_volumes(#{p[:uuid]})".colorize( :light_white )
			puts "#{@kvm.list_pool_volumes(p[:uuid])}".colorize( :yellow )
		end
		puts
		# puts @kvm.define_pool
		# puts @kvm.pool_action
		puts "@kvm.list_volumes".colorize( :light_white )
		puts @kvm.list_volumes
		# puts @kvm.volume_action
		# puts @kvm.create_volume
		puts "@kvm.list_networks".colorize( :light_white )
		puts @kvm.list_networks
		# puts @kvm.destroy_network
		puts "@kvm.list_interfaces".colorize( :light_white )
		puts @kvm.list_interfaces
		# puts @kvm.destroy_interface
		puts "@kvm.get_node_info".colorize( :light_white )	
		puts @kvm.get_node_info
		# puts @kvm.update_display

	end

	def one_error(error_string)
		puts "#{error_string}".colorize( :light_red )
	end
	
end

k = KvmQuick.new({})
k.info
