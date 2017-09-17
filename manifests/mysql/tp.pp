# This class manages the installation and initialisation of mysql
#
# @param ensure If to install or remove mysql
# @param template The path to the erb template (as used in template()) to use
#                 to populate the Runner configuration file. Note that if you
#                 use the runners parameter this file is automatically generated
#                 during runners registration
# @param options An open hash of options you may use in your template
#
class psick::mysql::tp (
  String                $ensure      = 'present',
  Optional[String]      $template    = undef,
  Optional[String]      $content     = undef,
  Optional[String]      $epp         = undef,
  Hash                  $options     = { },
  Boolean       $auto_prerequisites  = true,
) {

  $options_default = {
  }
  $real_options = $options_default + $options
  ::tp::install { 'mysql' :
    ensure             => $ensure,
    auto_prerequisites => $auto_prerequisites,
  }

  if $template {
    ::tp::conf { 'mysql':
      ensure       => $ensure,
      template     => $template,
      content      => $content,
      epp          => $epp,
      base_dir     => 'conf',
      options_hash => $real_options,
    }
  }

}
