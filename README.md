fluent-plugin-glusterfs
=======================

fluentd Input plugin for GlusterFS logs.

## Installation

### for fluentd

`````
gem install fluent-plugin-glusterfs
`````

### for td-agent

`````
/usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-glusterfs
`````

## Configuration

### Log Level

You can specify the log level you want to output with fluentd/td-agent.
Originally it is set like following:

`````ruby
config_param :log_level, :string, :default => 'TDINWECA'
`````

For example you can set like following if you want it to send above warning level.

`````ruby
config_param :log_level, :string, :default => 'WECA'
`````

### Handling parse failure

Of course it can parse almost of major GlusterFS logs. But GlusterFS has too many logs to test. So this plugin is designed to be able to handle parse failures. Given failed to parse a line, it set whole line into message field and set component name field as fluent-plugin-glusterfs.
This configuration is written as following:

`````ruby
@handle_parse_failure ||= true
`````

You can disable it in following way:

`````ruby
@handle_parse_failure = false
@handle_parse_failure ||= true
`````

### Field names

You can modify the field names of JSON event log as you like.
The default setting is following:

`````ruby
field ||= {
  :date => 'date',
  :time => 'time',
  :time_usec => 'time_usec',
  :log_level => 'log_level',
  :source_file_name => 'source_file_name',
  :source_line => 'source_line',
  :function_name => 'function_name',
  :component_name => 'component_name',
  :message => 'message',
  :hostname => 'hostname'
}
`````

You might prefer another field name set so you can overwrite them like following:
`````ruby
field = {
  :date => 'date',
  :time => 'time',
  :time_usec => 'usec',
  :log_level => 'level',
  :source_file_name => 'source',
  :source_line => 'line',
  :function_name => 'function',
  :component_name => 'component',
  :message => 'msg',
  :hostname => 'peer'
}
field ||= {
  :date => 'date',
  :time => 'time',
  :time_usec => 'time_usec',
  :log_level => 'log_level',
  :source_file_name => 'source_file_name',
  :source_line => 'source_line',
  :function_name => 'function_name',
  :component_name => 'component_name',
  :message => 'message',
  :hostname => 'hostname'
}
`````

### Hostname

It outputs the hostname of the node into each JSON log.
But you might specify your customized name as the hostname, then you can overwrite the following part:

`````ruby
@hostname ||= Socket.gethostname
`````

Just do it like following:

`````ruby
@hostname = example.com
@hostname ||= Socket.gethostname
`````

## Usage

### on GlusterFS nodes

* Set read permission for the log file(s)

`````
chmod +r /var/log/glusterfs/usr-local-glusterfs-etc-glusterfs-glusterd.vol.log
`````

* Example for single log file

`````
<source>
  type glusterfs_log
  path /var/log/glusterfs/usr-local-glusterfs-etc-glusterfs-glusterd.vol.log
  pos_file /var/log/td-agent/usr-local-glusterfs-etc-glusterfs-glusterd.vol.log.pos
  tag glusterfs_log.glusterd
  format /^(?<message>.*)$/
  refresh_interval 1800
</source>
`````

* Example for multiple log files

`````
<source>
  type glusterfs_log
  path /var/log/glusterfs/usr-local-glusterfs-etc-glusterfs-glusterd.vol.log
  pos_file /var/log/td-agent/glusterfs_log/usr-local-glusterfs-etc-glusterfs-glusterd.vol.log.pos
  tag glusterfs_log.glusterd
  format /^(?<message>.*)$/
  refresh_interval 1800
</source>

<source>
  type glusterfs_log
  path /var/log/glusterfs/bricks/mnt-lv0-fluent-plugin-test.log
  pos_file /var/log/td-agent/glusterfs_log/mnt-lv0-fluent-plugin-test.log.pos
  tag glusterfs_log.mnt_lv0_fluent_plugin_test
  format /^(?<message>.*)$/
  refresh_interval 1800
</source>

<source>
  type glusterfs_log
  path /var/log/glusterfs/nfs.log
  pos_file /var/log/td-agent/glusterfs_log/nfs.log.pos
  tag glusterfs_log.nfs
  format /^(?<message>.*)$/
  refresh_interval 1800
</source>

<source>
  type glusterfs_log
  path /var/log/glusterfs/glustershd.log
  pos_file /var/log/td-agent/glusterfs_log/glustershd.log.pos
  tag glusterfs_log.glustershd
  format /^(?<message>.*)$/
  refresh_interval 1800
</source>

<source>
  type glusterfs_log
  path /var/log/glusterfs/cli.log
  pos_file /var/log/td-agent/glusterfs_log/cli.log.pos
  tag glusterfs_log.cli
  format /^(?<message>.*)$/
  refresh_interval 1800
</source>
`````

* Correct above logs onto a server

`````
<match glusterfs_log.**>
  type forward
  send_timeout 60s
  recover_wait 10s
  heartbeat_interval 1s
  phi_threshold 8
  hard_timeout 60s

  <server>
    name logserver
    host 192.168.0.3
    port 24224
    weight 60
  </server>

  <secondary>
    type file
    path /var/log/td-agent/forward-failed
  </secondary>
</match>
`````

### on a log server

* Example for single log file

`````
<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>

<match glusterfs_log.glusterd>
  type file
  path /var/log/td-agent/glusterd
</match>
`````

* Example for multiple log files separated

`````
<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>

<match glusterfs_log.glusterd>
  type file
  path /var/log/td-agent/glusterfs/glusterd
</match>

<match glusterfs_log.mnt_lv0_fluent_plugin_test>
  type file
  path /var/log/td-agent/glusterfs/mnt_lv0_fluent_plugin_test
</match>

<match glusterfs_log.nfs>
  type file
  path /var/log/td-agent/glusterfs/nfs
</match>

<match glusterfs_log.glustershd>
  type file
  path /var/log/td-agent/glusterfs/glustershd
</match>

<match glusterfs_log.cli>
  type file
  path /var/log/td-agent/glusterfs/cli
</match>
`````

* Example for all log files integrated

`````
<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>

<match glusterfs_log.**>
  type file
  path /var/log/td-agent/glusterfs
</match>
`````

## License

Apache License, Version 2.0
