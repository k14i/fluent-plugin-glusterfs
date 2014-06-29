module Fluent

  class GlusterfsOutput < Fluent::Output
    Fluent::Plugin.register_output('glusterfs', self)

    config_param :volname, :string, :default => "fluentd"
    config_param :ipaddr, :string, :default => "127.0.0.1"
    config_param :base_dir, :string, :default => "/"

    attr_reader :volume
    attr_accessor :dir, :file

    def initialize(volume, dir, file)
      super
      require 'glusterfs'
      @volume = volume
      @dir = dir
      @file = file
    end

    def configure(conf)
      super
    end

    def start
      super
      mount(volname, ipaddr)
    end

    def shutdown
      super
    end

    def emit(tag, es, chain)
      chain.next
      es.each {|time,record|
        $stderr.puts "#{time}, #{record}"
      }
    end

    private

    def mount(volname, ipaddr)
      @volume = GlusterFS::Volume.new(volname)
      @volume.mount(ipaddr)
    end

    def mkdir(path)
      @dir = GlusterFS::Directory.new(@volume, path)
      @dir.create
    end

    def mknod(path, data)
      @file = GlusterFS::File.new(@volume, path)
      @file.write(data)
    end

    def unmount
      @volume.unmount
    end

  end

end
