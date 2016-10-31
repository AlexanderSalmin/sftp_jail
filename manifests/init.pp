# Class: sftp_jail
# ===========================
#
# Based on puppetlabs sftp_jail
#
# Parameters in hiera
# ----------
# 
# sftp_jail::user: <user>
# sftp_jail::group: <group>
# sftp_jail::chroot: <path>
#
#
class sftp_jail (
  $user = 'undef',
  $group = 'undef',
  $chroot = '/chroot',
) {

  validate_string($user)
  validate_string($group)
  validate_string($chroot)

  file { $chroot:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file { "${chroot}/${user}":
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }
  package { 'sftp_jail':
    ensure => latest,
  }

  ssh::server::match_block { $group:
    type    => 'Group',
    options => {
      'ChrootDirectory'        => $chroot,
      'ForceCommand'           => 'internal-sftp',
      'PasswordAuthentication' => 'no',
      'AllowTcpForwarding'     => 'no',
      'X11Forwarding'          => 'no',
    },
  }

  service { 'sftp_jail':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
