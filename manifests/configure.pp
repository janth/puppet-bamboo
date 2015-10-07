class bamboo::configure (
  $version            = $bamboo::version,
  $app_dir            = $bamboo::app_dir,
  $homedir            = $bamboo::homedir,
  $user               = $bamboo::user,
  $group              = $bamboo::group,
  $java_home          = $bamboo::java_home,
  $jvm_xmx            = $bamboo::jvm_xmx,
  $jvm_xms            = $bamboo::jvm_xms,
  $jvm_permgen        = $bamboo::jvm_permgen,
  $jvm_opts           = $bamboo::jvm_opts,
  $jvm_optional       = $bamboo::jvm_optional,
  $context_path       = $bamboo::context_path,
  $tomcat_port        = $bamboo::tomcat_port,
  $max_threads        = $bamboo::max_threads,
  $min_spare_threads  = $bamboo::min_spare_threads,
  $connection_timeout = $bamboo::connection_timeout,
  $proxy              = $bamboo::proxy,
  $accept_count       = $bamboo::accept_count,
) {

  file { "${homedir}/bin/setenv.sh":
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template('bamboo/setenv.sh.erb'),
  }

  file { "${app_dir}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties":
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    content => "bamboo.home=${homedir}",
  }

  file { '/etc/default/bamboo':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    content => template('bamboo/sysconfig-rhel.erb'),
  }

  $_proxy = suffix(prefix(join_keys_to_values($proxy, " '"), 'set Server/Service/Connector/#attribute/'), "'")

  $changes = [
    "set Server/Service[#attribute/name='Catalina']/Engine/Host/Context/#attribute/path '${context_path}'",
    "set Server/Service/Connector/#attribute/maxThreads '${max_threads}'",
    "set Server/Service/Connector/#attribute/minSpareThreads '${min_spare_threads}'",
    "set Server/Service/Connector/#attribute/connectionTimeout '${connection_timeout}'",
    "set Server/Service/Connector/#attribute/port '${tomcat_port}'",
    "set Server/Service/Connector/#attribute/acceptCount '${accept_count}'",
    $_proxy,
  ]

  augeas { "${app_dir}/conf/server.xml":
    lens    => 'Xml.lns',
    incl    => "${app_dir}/conf/server.xml",
    changes => $changes,
  }

}
