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
			:libvirt_uri => "#{@options["kvm"]["libvirt_uri"]}"
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
		
		@kvm.servers.all.each do |s|
			s.volumes.each do |v|
				puts "#{v.id}"
			end
		end

		@kvm.servers.all.each do |s|
			get_disks( s.uuid )
		end

		puts "------------------------------------------------------".colorize( :light_red )
		
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

		puts "\nGeneral Options".colorize( :light_blue )
		puts @options
		puts @agent_properties
		puts @pool
		puts @network
		puts @options["kvm"]
		puts @options["kvm"]["libvirt_uri"]

		puts "#{@pool}".colorize( :blue )
		puts @kvm.list_volumes(:pool_name => "#{@pool}")

		puts "#{@network}".colorize( :blue )
		puts @kvm.list_networks(:network_name => "#{@network}")

	end
	
	##
	# Get the vm_id of this host
	#
	# @return [String] opaque id later used by other methods of the CPI
	def current_vm_id
		not_implemented(:current_vm_id)
	end

	def create_stemcell(image_path, cloud_properties)
		# Not implement, or:
		# - Download stemcell from image_path
		# - Insert stemcell image into the pool passed through cloud_properties ( ovf? )
		# - return uuid 
	end

	def delete_stemcell(stemcell_id)
		# delete 
	end

	def one_error(error_string)
		puts "#{error_string}".colorize( :light_red )
	end

	# Create Pool
	# @param [Hash] Pool properties, ...
	# TODO: Only one template to Pool 'type="dir"'
	def create_pool(properties)
	end

	##
	# Creates a VM - creates (and powers on) a VM from a stemcell with the proper resources
	# and on the specified network. When disk locality is present the VM will be placed near
	# the provided disk so it won't have to move when the disk is attached later.
	#
	# Sample networking config:
	#  {"network_a" =>
	#    {
	#      "netmask"          => "255.255.248.0",
	#      "ip"               => "172.30.41.40",
	#      "gateway"          => "172.30.40.1",
	#      "dns"              => ["172.30.22.153", "172.30.22.154"],
	#      "cloud_properties" => {"name" => "VLAN444"}
	#    }
	#  }
	#
	# Sample resource pool config (CPI specific):
	#  {
	#    "ram"  => 512,
	#    "disk" => 512,
	#    "cpu"  => 1
	#  }
	# or similar for EC2:
	#  {"name" => "m1.small"}
	#
	# @param [String] agent_id UUID for the agent that will be used later on by the director
	#                 to locate and talk to the agent
	# @param [String] stemcell stemcell id that was once returned by {#create_stemcell}
	# @param [Hash] resource_pool cloud specific properties describing the resources needed
	#               for this VM
	# @param [Hash] networks list of networks and their settings needed for this VM
	# @param [optional, String, Array] disk_locality disk id(s) if known of the disk(s) that will be
	#                                    attached to this vm
	# @param [optional, Hash] env environment that will be passed to this vm
	# @return [String] opaque id later used by {#configure_networks}, {#attach_disk},
	#                  {#detach_disk}, and {#delete_vm}
	def create_vm(agent_id, stemcell_id, resource_pool,
								networks, disk_locality = nil, env = nil)
		not_implemented(:create_vm)
	end

	##
	# Deletes a VM
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @return [void]
	def delete_vm(vm_id)
		not_implemented(:delete_vm)
	end

	##
	# Checks if a VM exists
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @return [Boolean] True if the vm exists
	def has_vm?(vm_id)
		not_implemented(:has_vm?)
	end

	##
	# Reboots a VM
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @param [Optional, Hash] CPI specific options (e.g hard/soft reboot)
	# @return [void]
	def reboot_vm(vm_id)
		not_implemented(:reboot_vm)
	end

	##
	# Set metadata for a VM
	#
	# Optional. Implement to provide more information for the IaaS.
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @param [Hash] metadata metadata key/value pairs
	# @return [void]
	def set_vm_metadata(vm, metadata)
		not_implemented(:set_vm_metadata)
	end

	##
	# Configures networking an existing VM.
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @param [Hash] networks list of networks and their settings needed for this VM,
	#               same as the networks argument in {#create_vm}
	# @return [void]
	def configure_networks(vm_id, networks)
		not_implemented(:configure_networks)
	end

	##
	# Creates a disk (possibly lazily) that will be attached later to a VM. When
	# VM locality is specified the disk will be placed near the VM so it won't have to move
	# when it's attached later.
	#
	# @param [Integer] size disk size in MB
	# @param [optional, String] vm_locality vm id if known of the VM that this disk will
	#                           be attached to
	# @return [String] opaque id later used by {#attach_disk}, {#detach_disk}, and {#delete_disk}
	def create_disk(size, vm_locality = nil)
		not_implemented(:create_disk)
	end

	##
	# Deletes a disk
	# Will raise an exception if the disk is attached to a VM
	#
	# @param [String] disk disk id that was once returned by {#create_disk}
	# @return [void]
	def delete_disk(disk_id)
		not_implemented(:delete_disk)
	end

	##
	# Attaches a disk
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @param [String] disk disk id that was once returned by {#create_disk}
	# @return [void]
	def attach_disk(vm_id, disk_id)
		not_implemented(:attach_disk)
	end

	# Take snapshot of disk
	# @param [String] disk_id disk id of the disk to take the snapshot of
	# @return [String] snapshot id
	def snapshot_disk(disk_id, metadata={})
		not_implemented(:snapshot_disk)
	end

	# Delete a disk snapshot
	# @param [String] snapshot_id snapshot id to delete
	def delete_snapshot(snapshot_id)
		not_implemented(:delete_snapshot)
	end

	##
	# Detaches a disk
	#
	# @param [String] vm vm id that was once returned by {#create_vm}
	# @param [String] disk disk id that was once returned by {#create_disk}
	# @return [void]
	def detach_disk(vm_id, disk_id)
		not_implemented(:detach_disk)
	end

	##
	# List the attached disks of the VM.
	#
	# @param [String] vm_id is the CPI-standard vm_id (eg, returned from current_vm_id)
	#
	# @return [array[String]] list of opaque disk_ids that can be used with the
	# other disk-related methods on the CPI
	def get_disks(vm_id)
		# not_implemented(:get_disks)
		puts vm_id
		puts "#{@kvm.servers.all(:uuid => vm_id)}".colorize( :light_magenta )
		s = @kvm.servers.all(:uuid => vm_id)
		# s.volumes.each do |v|
			puts s.volumes		# end
		# disks = []
		# @kvm.server(:uuid=>"#{vm_id}").volumes.each do |v|
		# 	disks << v.id
		# end
	end

	##
	# Validates the deployment
	# @api not_yet_used
	def validate_deployment(old_manifest, new_manifest)
		not_implemented(:validate_deployment)
	end

	private

	def not_implemented(method)
		raise Bosh::Clouds::NotImplemented,
					"`#{method}' is not implemented by #{self.class}"
	end

end

k = KvmQuick.new({"agent" => "agente", 
								 "pool" => "default", 
 									"network" => "vagrant", 
								 "kvm" => {"libvirt_uri" => "qemu:///system"}})

puts k

k.info
