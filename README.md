Introduction
------------

This repository contains a vagrant configuration for spinning up a keycloak
instance and documentation for configuring it to demonstrate interoperability
with a domino server running a SAML idp.

Prerequisites to using it include an installation of vagrant itself, the
vagrant-vbguest plugin, and virtualbox. Only the virtualbox provider has been
tested and at this time it is not recommended to use any other vagrant
provider. The vagrant configuration has been tested under Mac OS X and Windows,
and is known to have issues under Linux, which is also not recommended to use
at this time (in particular, vagrant under linux does not support the reboot
guest capability natively, and while there is a plugin to add it
(https://github.com/secret104278/vagrant_reboot_linux/tree/master) it didn't
seem to work reliably).

Download and install virtualbox on your chosen platform:

	https://www.virtualbox.org/wiki/Downloads


Next, download and install vagrant on your chosen platform:

	https://www.vagrantup.com/downloads


Once vagrant has been installed, provision the vbguest plugin by running:

	vagrant plugin install vagrant-vbguest


Clone this git repository onto your system:

	git clone https://github.com/DominoIDP/keycloak_demo.git

If you want to change the version of keycloak, the default admin username or
password, or the keycloak server name / port, copy the file
keycloak_config/DEFAULTS.sh to keycloak_config/CONFIG.sh, update the values
you wish to change, and remove the ones you want to leave at defaults.

At this point, you can execute 'vagrant up' in the git checkout directory
to spin up a vm instance, or use the utility scripts
vagrant_up.sh/vagrant_up.ps1 to create a log file with the initialization
output in addition to showing on the screen.

Once the system has been provisioned, you can use 'vagrant ssh' to access
it, or again the utility scripts vagrant_ssh.sh/vagrant_ssh.ps1 to create
a log file of the ssh session.

Provisioning details
--------------------

The vagrant configuration begins with a CentOS 7 box image and initially
installs/configures the virtual box guest tools on it. Next, it installs the
CentOS openjdk 11 package.  It then proceeds to install/configure the keycloak
server. A realm named "local" is created along with a user named "localuser"
with a password of "localpass". In addition, a realm named "domino" is
created.

Next steps yet to be committed will be to automate as much of the integration
between keycloak and domino as reasonable in the vagrant config, and supply
documentation for the additional steps to complete the PoC that will need to
be done manually.
