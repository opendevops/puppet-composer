# == Class: composer
#
# Full description of class composer here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#   ::composer{ target_dir => '/usr/local/bin'}
#
#
# === Authors
#
# Matthew Hansen
#
# === Copyright
#
# Copyright 2016 Matthew Hansen
#
define composer (
  $target_dir       = '/usr/local/bin',
  $command_name     = 'composer',
  $user             = 'root',
  $auto_update      = true,
  $group            = undef,
  $download_timeout = '0',
) {

  include composer::params

  $composer_target_dir = $target_dir ? {
    '/usr/local/bin' => $::composer::params::target_dir,
    default => $target_dir
  }

  $composer_command_name = $command_name ? {
    'composer' => $::composer::params::command_name,
    default => $command_name
  }

  $composer_user = $user ? {
    'root' => $::composer::params::user,
    default => $user
  }

  $target = $::composer::params::phar_location

  $composer_full_path = "${composer_target_dir}/${composer_command_name}"

  exec { 'composer-install':
    command => "/usr/bin/wget --no-check-certificate -O ${composer_full_path} ${target}",
    user    => $composer_user,
    creates => $composer_full_path,
    timeout => $download_timeout,
    # require => Package['wget'],
  }

  file { "${composer_target_dir}/${composer_command_name}":
    ensure  => file,
    owner   => $composer_user,
    mode    => '0755',
    group   => $group,
    require => Exec['composer-install'],
  }

  if $auto_update {
    exec { 'composer-update':
      command     => "${composer_full_path} self-update",
      environment => [ "COMPOSER_HOME=${composer_target_dir}" ],
      user        => $composer_user,
      require     => File["${composer_target_dir}/${composer_command_name}"],
    }
  }
}