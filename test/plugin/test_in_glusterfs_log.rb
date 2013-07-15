require 'helper'
require 'socket'

class GlusterfsLogInputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    @hostname = Socket.gethostname
    @time_format = '%Y-%m-%dT%H:%M:%S'
  end

  TMP_DIR = File.dirname(__FILE__) + '/../tmp'

  log_file_path = 'test/plugin/data/log'
  test_log_file_path = "#{log_file_path}/test_in_glusterfs/%Y%m%d-%H%M%S.log"
  glusterfs_log_file_path = "#{log_file_path}/glusterfs/**/**/*.log"
  config_format = '/^(?<message>.*)$/'
  CONFIG = %[
    tag glusterfs_log.glusterd
    path #{test_log_file_path},#{glusterfs_log_file_path}
    format #{config_format}
    pos_file #{TMP_DIR}/etc-glusterfs-glusterd.vol.log.pos
    refresh_interval 1800
    rotate_wait 2s
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::GlusterfsLogInput).configure(conf)
  end

  def test_parse_line_client_glusterd_w_readv_failed
    line = '[2013-07-15 13:45:05.309889] W [socket.c:514:__socket_rwv] 0-management: readv failed (No data available)'
    time = Time.strptime("2013-07-15T13:45:05+9:00", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:05',
      :time_usec => '309889',
      :log_level => 'W',
      :source_file_name => 'socket.c',
      :source_line => '514',
      :function_name => '__socket_rwv',
      :component_name => '0-management',
      :message => 'readv failed (No data available)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glusterd_w_reading_from_socket_failed
    line = '[2013-07-15 13:45:05.309954] W [socket.c:1962:__socket_proto_state_machine] 0-management: reading from socket failed. Error (No data available), peer (192.168.0.12:24007)'
    time = Time.strptime("2013-07-15T13:45:05", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:05',
      :time_usec => '309954',
      :log_level => 'W',
      :source_file_name => 'socket.c',
      :source_line => '1962',
      :function_name => '__socket_proto_state_machine',
      :component_name => '0-management',
      :message => 'reading from socket failed. Error (No data available), peer (192.168.0.12:24007)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glusterd_e_connection_refused
    line = '[2013-07-15 13:45:07.090755] E [socket.c:2157:socket_connect_finish] 0-management: connection to 192.168.0.12:24007 failed (Connection refused)'
    time = Time.strptime("2013-07-15T13:45:07", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:07',
      :time_usec => '090755',
      :log_level => 'E',
      :source_file_name => 'socket.c',
      :source_line => '2157',
      :function_name => 'socket_connect_finish',
      :component_name => '0-management',
      :message => 'connection to 192.168.0.12:24007 failed (Connection refused)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glusterd_i_received_friend_update
    line = '[2013-07-15 13:45:32.902716] I [glusterd-handler.c:2020:__glusterd_handle_friend_update] 0-glusterd: Received friend update from uuid: 9d07f8cc-b0a1-417c-a132-4b3310f98945'
    time = Time.strptime("2013-07-15T13:45:32", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:32',
      :time_usec => '902716',
      :log_level => 'I',
      :source_file_name => 'glusterd-handler.c',
      :source_line => '2020',
      :function_name => '__glusterd_handle_friend_update',
      :component_name => '0-glusterd',
      :message => 'Received friend update from uuid: 9d07f8cc-b0a1-417c-a132-4b3310f98945',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glusterd_i_de_registered_nfsv3_successfully
    line = '[2013-07-15 13:46:08.751129] I [glusterd-utils.c:3627:glusterd_nfs_pmap_deregister] 0-: De-registered NFSV3 successfully'
    time = Time.strptime("2013-07-15T13:46:08", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:08',
      :time_usec => '751129',
      :log_level => 'I',
      :source_file_name => 'glusterd-utils.c',
      :source_line => '3627',
      :function_name => 'glusterd_nfs_pmap_deregister',
      :component_name => '0-',
      :message => 'De-registered NFSV3 successfully',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glusterd_e_failed_to_remove_socket
    line = '[2013-07-15 13:46:09.753811] E [glusterd-utils.c:3583:glusterd_nodesvc_unlink_socket_file] 0-management: Failed to remove /var/run/9603d75b8cac40f80e82ca4f161672b9.socket error: No such file or director'
    time = Time.strptime("2013-07-15T13:46:09", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:09',
      :time_usec => '753811',
      :log_level => 'E',
      :source_file_name => 'glusterd-utils.c',
      :source_line => '3583',
      :function_name => 'glusterd_nodesvc_unlink_socket_file',
      :component_name => '0-management',
      :message => 'Failed to remove /var/run/9603d75b8cac40f80e82ca4f161672b9.socket error: No such file or director',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_nfs_i_started_running
    line = '[2013-07-15 13:42:34.485000] I [glusterfsd.c:1878:main] 0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs: Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs -s localhost --volfile-id gluster/nfs -p /var/lib/glusterd/nfs/run/nfs.pid -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/nfs.log -S /var/run/e771e6272849a2f9b9b77d1cba799ae9.socket)'
    time = Time.strptime("2013-07-15T13:42:34", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:42:34',
      :time_usec => '485000',
      :log_level => 'I',
      :source_file_name => 'glusterfsd.c',
      :source_line => '1878',
      :function_name => 'main',
      :component_name => '0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs',
      :message => 'Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs -s localhost --volfile-id gluster/nfs -p /var/lib/glusterd/nfs/run/nfs.pid -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/nfs.log -S /var/run/e771e6272849a2f9b9b77d1cba799ae9.socket)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_nfs_w_readv_failed
    line = '[2013-07-15 13:42:34.742845] W [socket.c:514:__socket_rwv] 0-fluent-plugin-test-client-0: readv failed (No data available)'
    time = Time.strptime("2013-07-15T13:42:34", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:42:34',
      :time_usec => '742845',
      :log_level => 'W',
      :source_file_name => 'socket.c',
      :source_line => '514',
      :function_name => '__socket_rwv',
      :component_name => '0-fluent-plugin-test-client-0',
      :message => 'readv failed (No data available)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_mnt_i_started_running
    line = '[2013-07-15 13:44:04.812937] I [glusterfsd.c:1878:main] 0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs: Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs --volfile-id=fluent-plugin-test --volfile-server=localhost /mnt/glusterfs/fluent-plugin-test)'
    time = Time.strptime("2013-07-15T13:44:04", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:44:04',
      :time_usec => '812937',
      :log_level => 'I',
      :source_file_name => 'glusterfsd.c',
      :source_line => '1878',
      :function_name => 'main',
      :component_name => '0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs',
      :message => 'Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs --volfile-id=fluent-plugin-test --volfile-server=localhost /mnt/glusterfs/fluent-plugin-test)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_mnt_w_shutting_down
    line = '[2013-07-15 13:45:50.657199] W [glusterfsd.c:970:cleanup_and_exit] (-->/lib64/libc.so.6(clone+0x6d) [0x7fe6d511790d] (-->/lib64/libpthread.so.0(+0x7851) [0x7fe6d5763851] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs(glusterfs_sigwaiter+0xe4) [0x407b7b]))) 0-: received signum (15), shutting down'
    time = Time.strptime("2013-07-15T13:45:50", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:50',
      :time_usec => '657199',
      :log_level => 'W',
      :source_file_name => 'glusterfsd.c',
      :source_line => '970',
      :function_name => 'cleanup_and_exit',
      :component_name => '(-->/lib64/libc.so.6(clone+0x6d) [0x7fe6d511790d] (-->/lib64/libpthread.so.0(+0x7851) [0x7fe6d5763851] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs(glusterfs_sigwaiter+0xe4) [0x407b7b]))) 0-',
      :message => 'received signum (15), shutting down',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glustershd_i_started_running
    line = '[2013-07-15 13:42:34.498071] I [glusterfsd.c:1878:main] 0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs: Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs -s localhost --volfile-id gluster/glustershd -p /var/lib/glusterd/glustershd/run/glustershd.pid -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/glustershd.log -S /var/run/9603d75b8cac40f80e82ca4f161672b9.socket --xlator-option *replicate*.node-uuid=000fcaf8-f160-4933-ad79-f02b309c3000)'
    time = Time.strptime("2013-07-15T13:42:34", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:42:34',
      :time_usec => '498071',
      :log_level => 'I',
      :source_file_name => 'glusterfsd.c',
      :source_line => '1878',
      :function_name => 'main',
      :component_name => '0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs',
      :message => 'Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs -s localhost --volfile-id gluster/glustershd -p /var/lib/glusterd/glustershd/run/glustershd.pid -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/glustershd.log -S /var/run/9603d75b8cac40f80e82ca4f161672b9.socket --xlator-option *replicate*.node-uuid=000fcaf8-f160-4933-ad79-f02b309c3000)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_glustershd_w_shutting_down
    line = '[2013-07-15 13:46:08.751690] W [glusterfsd.c:970:cleanup_and_exit] (-->/lib64/libc.so.6(clone+0x6d) [0x7f3bad27090d] (-->/lib64/libpthread.so.0(+0x7851) [0x7f3bad8bc851] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs(glusterfs_sigwaiter+0xe4) [0x407b7b]))) 0-: received signum (15), shutting down'
    time = Time.strptime("2013-07-15T13:46:08", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:08',
      :time_usec => '751690',
      :log_level => 'W',
      :source_file_name => 'glusterfsd.c',
      :source_line => '970',
      :function_name => 'cleanup_and_exit',
      :component_name => '(-->/lib64/libc.so.6(clone+0x6d) [0x7f3bad27090d] (-->/lib64/libpthread.so.0(+0x7851) [0x7f3bad8bc851] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs(glusterfs_sigwaiter+0xe4) [0x407b7b]))) 0-',
      :message => 'received signum (15), shutting down',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_cli_i_create_volume
    line = '[2013-07-15 13:41:22.447332] I [cli-rpc-ops.c:798:gf_cli_create_volume_cbk] 0-cli: Received resp to create volume'
    time = Time.strptime("2013-07-15T13:41:22", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:41:22',
      :time_usec => '447332',
      :log_level => 'I',
      :source_file_name => 'cli-rpc-ops.c',
      :source_line => '798',
      :function_name => 'gf_cli_create_volume_cbk',
      :component_name => '0-cli',
      :message => 'Received resp to create volume',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_cli_i_start_volume
    line = '[2013-07-15 13:42:34.606620] I [cli-rpc-ops.c:1011:gf_cli_start_volume_cbk] 0-cli: Received resp to start volume'
    time = Time.strptime("2013-07-15T13:42:34", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:42:34',
      :time_usec => '606620',
      :log_level => 'I',
      :source_file_name => 'cli-rpc-ops.c',
      :source_line => '1011',
      :function_name => 'gf_cli_start_volume_cbk',
      :component_name => '0-cli',
      :message => 'Received resp to start volume',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_client_cli_i_stop_volume
    line = '[2013-07-15 13:46:11.781550] I [cli-rpc-ops.c:1089:gf_cli_stop_volume_cbk] 0-cli: Received resp to stop volume'
    time = Time.strptime("2013-07-15T13:46:11", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:11',
      :time_usec => '781550',
      :log_level => 'I',
      :source_file_name => 'cli-rpc-ops.c',
      :source_line => '1089',
      :function_name => 'gf_cli_stop_volume_cbk',
      :component_name => '0-cli',
      :message => 'Received resp to stop volume',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glusterd_w_reading_from_socket_failed
    line = '[2013-07-15 13:45:21.758927] W [socket.c:1962:__socket_proto_state_machine] 0-management: reading from socket failed. Error (No data available), peer (192.168.0.12:24007)'
    time = Time.strptime("2013-07-15T13:45:21", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:21',
      :time_usec => '758927',
      :log_level => 'W',
      :source_file_name => 'socket.c',
      :source_line => '1962',
      :function_name => '__socket_proto_state_machine',
      :component_name => '0-management',
      :message => 'reading from socket failed. Error (No data available), peer (192.168.0.12:24007)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glusterd_e_connection_failed
    line = '[2013-07-15 13:45:24.637443] E [socket.c:2157:socket_connect_finish] 0-management: connection to 192.168.0.12:24007 failed (Connection refused)'
    time = Time.strptime("2013-07-15T13:45:24", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:45:24',
      :time_usec => '637443',
      :log_level => 'E',
      :source_file_name => 'socket.c',
      :source_line => '2157',
      :function_name => 'socket_connect_finish',
      :component_name => '0-management',
      :message => 'connection to 192.168.0.12:24007 failed (Connection refused)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glusterd_e_unable_to_open_pidfile
    line = '[2013-07-15 13:46:26.209153] E [glusterd-utils.c:1082:glusterd_service_stop] 0-management: Unable to open pidfile: /var/lib/glusterd/vols/fluent-plugin-test/run/glusterfs-unstable-01-mnt-lv0-fluent-plugin-test.pid'
    time = Time.strptime("2013-07-15T13:46:26", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:26',
      :time_usec => '209153',
      :log_level => 'E',
      :source_file_name => 'glusterd-utils.c',
      :source_line => '1082',
      :function_name => 'glusterd_service_stop',
      :component_name => '0-management',
      :message => 'Unable to open pidfile: /var/lib/glusterd/vols/fluent-plugin-test/run/glusterfs-unstable-01-mnt-lv0-fluent-plugin-test.pid',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glusterd_e_failed_to_remove_socket
    line = '[2013-07-15 13:46:26.209800] E [glusterd-utils.c:1455:glusterd_brick_unlink_socket_file] 0-management: Failed to remove /var/run/5bfeb92485191dab05ce086134861afd.socket error: No such file or directory'
    time = Time.strptime("2013-07-15T13:46:26", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:26',
      :time_usec => '209800',
      :log_level => 'E',
      :source_file_name => 'glusterd-utils.c',
      :source_line => '1455',
      :function_name => 'glusterd_brick_unlink_socket_file',
      :component_name => '0-management',
      :message => 'Failed to remove /var/run/5bfeb92485191dab05ce086134861afd.socket error: No such file or directory',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glusterd_i_removing_brick
    line = '[2013-07-15 13:46:28.231270] I [glusterd-pmap.c:271:pmap_registry_remove] 0-pmap: removing brick /mnt/lv0/fluent-plugin-test on port 49155'
    time = Time.strptime("2013-07-15T13:46:28", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:28',
      :time_usec => '231270',
      :log_level => 'I',
      :source_file_name => 'glusterd-pmap.c',
      :source_line => '271',
      :function_name => 'pmap_registry_remove',
      :component_name => '0-pmap',
      :message => 'removing brick /mnt/lv0/fluent-plugin-test on port 49155',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glustershd_i_started_running
    line = '[2013-07-15 13:42:51.088334] I [glusterfsd.c:1878:main] 0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs: Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs -s localhost --volfile-id gluster/glustershd -p /var/lib/glusterd/glustershd/run/glustershd.pid -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/glustershd.log -S /var/run/08d90b8cacfaaf498f725ad25fa58da0.socket --xlator-option *replicate*.node-uuid=9d07f8cc-b0a1-417c-a132-4b3310f98945)'
    time = Time.strptime("2013-07-15T13:42:51", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:42:51',
      :time_usec => '088334',
      :log_level => 'I',
      :source_file_name => 'glusterfsd.c',
      :source_line => '1878',
      :function_name => 'main',
      :component_name => '0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs',
      :message => 'Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfs version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs -s localhost --volfile-id gluster/glustershd -p /var/lib/glusterd/glustershd/run/glustershd.pid -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/glustershd.log -S /var/run/08d90b8cacfaaf498f725ad25fa58da0.socket --xlator-option *replicate*.node-uuid=9d07f8cc-b0a1-417c-a132-4b3310f98945)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glustershd_e_all_subvolumes_are_down
    line = '[2013-07-15 13:46:26.213025] E [afr-common.c:3735:afr_notify] 0-fluent-plugin-test-replicate-0: All subvolumes are down. Going offline until atleast one of them comes back up.'
    time = Time.strptime("2013-07-15T13:46:26", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:26',
      :time_usec => '213025',
      :log_level => 'E',
      :source_file_name => 'afr-common.c',
      :source_line => '3735',
      :function_name => 'afr_notify',
      :component_name => '0-fluent-plugin-test-replicate-0',
      :message => 'All subvolumes are down. Going offline until atleast one of them comes back up.',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_glustershd_w_shutting_down
    line = '[2013-07-15 13:46:27.227274] W [glusterfsd.c:970:cleanup_and_exit] (-->/lib64/libc.so.6(clone+0x6d) [0x7f67143bf90d] (-->/lib64/libpthread.so.0(+0x7851) [0x7f6714a0b851] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs(glusterfs_sigwaiter+0xe4) [0x407b7b]))) 0-: received signum (15), shutting down'
    time = Time.strptime("2013-07-15T13:46:27", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:27',
      :time_usec => '227274',
      :log_level => 'W',
      :source_file_name => 'glusterfsd.c',
      :source_line => '970',
      :function_name => 'cleanup_and_exit',
      :component_name => '(-->/lib64/libc.so.6(clone+0x6d) [0x7f67143bf90d] (-->/lib64/libpthread.so.0(+0x7851) [0x7f6714a0b851] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfs(glusterfs_sigwaiter+0xe4) [0x407b7b]))) 0-',
      :message => 'received signum (15), shutting down',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_brick_i_started_running
    line = '[2013-07-15 13:42:50.952881] I [glusterfsd.c:1878:main] 0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd: Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd -s glusterfs-unstable-01 --volfile-id fluent-plugin-test.glusterfs-unstable-01.mnt-lv0-fluent-plugin-test -p /var/lib/glusterd/vols/fluent-plugin-test/run/glusterfs-unstable-01-mnt-lv0-fluent-plugin-test.pid -S /var/run/5bfeb92485191dab05ce086134861afd.socket --brick-name /mnt/lv0/fluent-plugin-test -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/bricks/mnt-lv0-fluent-plugin-test.log --xlator-option *-posix.glusterd-uuid=9d07f8cc-b0a1-417c-a132-4b3310f98945 --brick-port 49155 --xlator-option fluent-plugin-test-server.listen-port=49155)'
    time = Time.strptime("2013-07-15T13:42:50", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:42:50',
      :time_usec => '952881',
      :log_level => 'I',
      :source_file_name => 'glusterfsd.c',
      :source_line => '1878',
      :function_name => 'main',
      :component_name => '0-/usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd',
      :message => 'Started running /usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd version 3.4.0beta2 (/usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd -s glusterfs-unstable-01 --volfile-id fluent-plugin-test.glusterfs-unstable-01.mnt-lv0-fluent-plugin-test -p /var/lib/glusterd/vols/fluent-plugin-test/run/glusterfs-unstable-01-mnt-lv0-fluent-plugin-test.pid -S /var/run/5bfeb92485191dab05ce086134861afd.socket --brick-name /mnt/lv0/fluent-plugin-test -l /usr/local/glusterfs-3.4.0beta2/var/log/glusterfs/bricks/mnt-lv0-fluent-plugin-test.log --xlator-option *-posix.glusterd-uuid=9d07f8cc-b0a1-417c-a132-4b3310f98945 --brick-port 49155 --xlator-option fluent-plugin-test-server.listen-port=49155)',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

  def test_parse_line_server_brick_w_shutting_down
    line = '[2013-07-15 13:46:26.207044] W [glusterfsd.c:970:cleanup_and_exit] (-->/lib64/libc.so.6(+0x43b70) [0x7fe8eb17eb70] (-->/usr/local/glusterfs-3.4.0beta2/lib/libglusterfs.so.0(synctask_wrap+0x38) [0x7fe8ebf17909] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd(glusterfs_handle_terminate+0x27) [0x408c77]))) 0-: received signum (15), shutting down'
    time = Time.strptime("2013-07-15T13:46:26", @time_format).to_i
    record = {
      :date => '2013-07-15',
      :time => '13:46:26',
      :time_usec => '207044',
      :log_level => 'W',
      :source_file_name => 'glusterfsd.c',
      :source_line => '970',
      :function_name => 'cleanup_and_exit',
      :component_name => '(-->/lib64/libc.so.6(+0x43b70) [0x7fe8eb17eb70] (-->/usr/local/glusterfs-3.4.0beta2/lib/libglusterfs.so.0(synctask_wrap+0x38) [0x7fe8ebf17909] (-->/usr/local/glusterfs-3.4.0beta2/sbin/glusterfsd(glusterfs_handle_terminate+0x27) [0x408c77]))) 0-',
      :message => 'received signum (15), shutting down',
      :hostname => @hostname
    }
    assert_equal [time, record], create_driver.instance.parse_line(line)
  end

end
