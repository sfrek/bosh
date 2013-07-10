require 'fog'
require 'colorize'

# f = Fog::Compute.new({:provider => "Libvirt" , 
# 										 :libvirt_uri => "qemu:///system"})

# puts "Domains ( guest ) list".colorize( :light_white )
# puts "f.servers.all #{f.servers.all}".colorize( :blue )
# 
# puts "Volumes list".colorize( :light_white )
# puts "f.volumes.all #{f.volumes.all}".colorize( :green ) 
# 
# puts "Pools list".colorize( :light_white )
# puts "f.pools.all #{f.pools.all}".colorize( :magenta )
# 
# puts "Networks list".colorize( :light_white )
# puts "f.networks.all #{f.networks.all}".colorize( :light_red )
# 
# puts "Interfaces list".colorize( :light_white )
# puts "f.interfaces.all #{f.interfaces.all}".colorize( :yellow ) 
# 
# puts "Nodes list".colorize( :light_white )
# puts "f.nodes.all #{f.nodes.all}".colorize( :red ) 

class KvmQuick

	def initialize
	
		kvm_params = {
			:provider => "Libvirt",
			:libvirt_uri => "qemu:///system"
		}
		
		begin
			@kvm = Fog::Compute.new(kvm_params)
		rescue Exception => e
			one_error( "Error #{e}" )
		end
	
		begin
			@pool = @kvm.pools.new(:name => "bosh")
		rescue Exception => e
			one_error( "Error #{e}" )
		end

	end

	def info

		puts "Pools list".colorize( :light_white )
		puts "#{@kvm.pools.all}".colorize( :magenta )
		
		puts "Net list".colorize( :light_white )
		puts "#{@kvm.networks.all}".colorize( :green )

		puts "#{@pool}".colorize( :blue )
		puts "#{@pool.name}".colorize( :blue )
		puts @kvm.list_volumes(:pool_name => "#{@pool.name}")

	end

	def one_error(error_string)
		puts "#{error_string}".colorize( :light_red )
	end
	
end

k = KvmQuick.new
k.info
