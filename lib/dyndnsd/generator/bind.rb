
module Dyndnsd
  module Generator
    class Bind
      def initialize(domain, config)
        @domain = domain
        @ttl = config['ttl']
        @soa_dns = config['soa_dns']
        if config['dns']
          @dns = [config['dns']].flatten
        else
          @dns = [@soa_dns]
        end
        @ip = config['ip']
        @email_addr = config['email_addr']
        @additional_zone_content = config['additional_zone_content']
      end

      def generate(zone)
        out = []
        out << "$TTL #{@ttl}"
        out << "$ORIGIN #{@domain}."
        out << ""
        out << "@ IN SOA #{@soa_dns} #{@email_addr} ( #{zone['serial']} 3h 5m 1w 1h )"
        @dns.each do |ns|
          out << "@ IN NS #{ns}"
        end
        if @ip
          (@ip.is_a?(Array) ? @ip : [@ip]).each do |ip|
            ip = IPAddr.new(ip).native
            type = ip.ipv6? ? "AAAA" : "A"
            out << "@ IN #{type} #{ip}"
          end
        end
        out << ""
        zone['hosts'].each do |hostname,ips|
          (ips.is_a?(Array) ? ips : [ips]).each do |ip|
            ip = IPAddr.new(ip).native
            type = ip.ipv6? ? "AAAA" : "A"
            name = hostname.chomp('.' + @domain)
            out << "#{name} IN #{type} #{ip}"
          end
        end
        out << ""
        out << @additional_zone_content
        out << ""
        out.join("\n")
      end
    end
  end
end
