# This class manages the installation and initialisation of a GitLab CI runner.
#
# @param ensure If to install or remove the GitLab CI runner
# @param auto_prerequisites If to automatically install all the prerequisites
#                           resources needed to install the runner
# @param template The path to the erb template (as used in template()) to use
#                 to populate the Runner configuration file. Note that if you
#                 use the runners parameter this file is automatically generated
#                 during runners registration
# @param options An open hash of options you may use in your template
# @param runners An hash which is used to create one or more runners instances.
#                It should be an array of hashes which is passed to the define
#                tools::gitlab::runner
# @param sudo_template The path to the erb template to use for gitlab runner
#                      sudoers file. If undef file is not managed
#
class profile::gitlab::runner (
  String           $ensure        = 'present',
  Boolean          $auto_prerequisites = true,
  Optional[String] $template      = undef, # 'profile/gitlab/runner/config.toml.erb',
  Hash             $options       = { },
  Hash             $runners       = { },
  String           $sudo_template = 'profile/gitlab/runner/sudo.erb',
  Optional[String] $pe_user                 = undef,
  Optional[String] $pe_password             = undef,
  Optional[String] $runner_user             = 'gitlab-runner',
  Optional[String] $pe_token_lifetime                = '5y',
  Boolean          $use_docker    = false,
) {

  if $use_docker {
    include ::docker
    # Quick and very dirty
    exec { 'usermod -a -G docker gitlab-runner':
      refreshonly => true,
      subscribe   => Class['docker'],
    }
  }
  $options_default = {
  }
  $gitlab_runner_options = $options_default + $options
  ::tp::install { 'gitlab-runner' :
    ensure             => $ensure,
    auto_prerequisites => $auto_prerequisites,
  }

  if $template {
    ::tp::conf { 'gitlab-runner':
      ensure       => $ensure,
      template     => $template,
      options_hash => $gitlab_runner_options,
    }
  }

  if $runners != {} {
    $runners.each | $k , $v | {
      tools::gitlab::runner { $k:
        * => $v,
      }
    }
  }

  if $sudo_template {
    tools::sudo::directive { 'gitlab-runner':
      template => $sudo_template,
    }
  }

  if $pe_user and $pe_password {
    tools::puppet::access { 'gitlab-runner':
      pe_user     => $pe_user,
      pe_password => $pe_password,
      run_as_user => $runner_user,
      lifetime    => $pe_token_lifetime,
    }
  }
}
