require "minion/version"
require "evil-proxy"

module Minion
  def self.proxy(&block)
    Minion::Instance.new.tap { |m| m.instance_eval(&block) }
  end

  class Instance
    def initialize
      @hosts = {}
    end

    def host(name, &block)
      host = Minion::Host.new.tap { |h| h.instance_eval(&block) }
      @hosts[name] = host
    end

    def start
      mitm_pattern = /(#{@hosts.keys.map { |hostname| Regexp.escape(hostname) }.join('|')})/
      proxy = EvilProxy::MITMProxyServer.new Port: 8080, MITMPattern: mitm_pattern
      # todo - unsuckify
      @hosts.each do |hostname, minion_host|
        proxy.start_mitm_server(hostname, 0)
        proxy.instance_eval { minion_host.apply(@mitm_servers[hostname]) }
      end
      proxy.start
    end
  end

  class Host
    def initialize
      @handlers = {}
    end

    def get(expr, &block)
      @handlers[:get] ||= []
      @handlers[:get] << [expr, block]
    end

    def apply(mitm_server)
      @handlers.each do |method, cases|
        mitm_server.instance_eval do
          define_singleton_method "do_#{method.upcase}" do |req, res|
            match = cases.find { |(expr, _)| req.path =~ expr }
            if match.nil?
              super req, res
            else
              _, handler = match
              handler.call(req, res)
            end
          end
        end
      end
    end
  end
end
