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

## License

Apache License, Version 2.0
