Introduction
------------

This repository contains a vagrant configuration for spinning up a keycloak
instance and documentation for configuring it to demonstrate interoperability
with a domino server running a SAML idp (test configuration available at
https://github.com/DominoIDP/domino_idp).

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
CentOS openjdk 11 package. It then proceeds to install/configure the keycloak
server. The admin username is set to "admin", with a password of "password"
(Note from Captain Obvious - this entire setup is intended solely for testing
and feature validation, and does not represent a well secured or optimized
keycloak deployment).

Two realms are created, one named "local-[randomint]" and another
named "domino-[randomint]" ([randomint] is a random integer, used to ensure
two different people trying to test at the same time don't have conflicting
entity-id's when integrated with external services).

In the local realm, a a user named "localuser" is created with a password of
"localpass", an email address "localuser@local.domain", and a first/last name
of "Local"/"User".

In both realms, a client for the samltest.id SP test service is created,
releasing the username, email address, and first/last names as attributes.


Proof of Concept additional configuration
-----------------------------------------

Some additional configuration is necessary to complete the integration between
keycloak, the domino idp, and samltest before proceeding to interoperability
testing.

Open a browser tab/window and load the URL "http://127.0.0.1:8888/auth/admin"
on the system hosting the vagrant virtual machines and login using the username
"admin" and the password "password".

![](/screenshots/1.png)

You will see three realms listed, the local realm, the domino realm, and the
keycloak master realm.

![](/screenshots/2.png)

Select the local realm, which will display the realm settings. At the bottom of
the configuration screen in the "Endpoints" section right click on the "SAML
2.0 Identity Provider Metadata" option and save the link to your computer in a
file named "keycloak-local-idp.xml".

![](/screenshots/3.png)

![](/screenshots/4.png)

Open a new browser tab/window and load the URL
"https://samltest.id/upload.php". Select the "Choose File" button, and pick the
"keycloak-local-idp.xml" file just downloaded. Click the Upload button.

![](/screenshots/5.png)

You should see a "Metadata Upload Results" screen indicating the file was
successfully parsed and saved. At the bottom, it will display the metadata you
just uploaded. Save the value of the entityID attribute (eg
"http://127.0.0.1:8888/auth/realms/local-16509") for use later in testing.
Close this browser tab/window.

![](/screenshots/6.png)

Return to the keycloak browser tab/window and select the domino realm from the
menu at the upper left.

![](/screenshots/7.png)

At the bottom of the configuration screen in the "Endpoints" section right
click on the "SAML 2.0 Identity Provider Metadata" option and save the link to
your computer in a file named "keycloak-domino-idp.xml".

![](/screenshots/8.png)

![](/screenshots/9.png)

Open a new browser tab/window and load the URL
"https://samltest.id/upload.php". Select the "Choose File" button, and pick the
"keycloak-domino-idp.xml" file just downloaded. Click the Upload button.

![](/screenshots/10.png)

You should see a "Metadata Upload Results" screen indicating the file was
successfully parsed and saved. At the bottom, it will display the metadata you
just uploaded. Save the value of the entityID attribute (eg
"http://127.0.0.1:8888/auth/realms/domino-25636") for use later in testing.
Close this browser tab/window.

![](/screenshots/11.png)

Make sure the domino idp vagrant vm is running. Open a new browser tab/window
and open the URL "http://localhost:8080/idp/shibboleth". Save this xml file to
your local computer as "domino-idp.xml". Close this browser tab/window.

![](/screenshots/12.png)

![](/screenshots/13.png)

Returning to the keycloak browser tab/window, choose the "Identity Providers"
option from the menu on the left for the domino realm.

![](/screenshots/14.png)

Under "Add Provider", select "SAML v2.0".

![](/screenshots/15.png)

Update the "Alias" textbox to "domino-idp" and enter "Domino IDP" in the
"Display Name" field. Change the "Sync Mode" selection box to "force".

![](/screenshots/16.png)

Scroll down until you see the ""Principal Type" selection box and update it to
"Attribute [Name]". Enter "urn:oid:0.9.2342.19200300.100.1.1" in the "Principal
Attribute" textbox.

![](/screenshots/17.png)

Scroll to the bottom and find the "Import External IDP Config" section.  Click
the "Select file" button next to the label "Import from file". Pick the
"domino-idp.xml" file that was just downloaded.

![](/screenshots/18.png)

Click "Import". The message "Success! The IDP metadata has been loaded from
file" should appear at the top of the window.

![](/screenshots/19.png)

![](/screenshots/20.png)

Finally, click on "Save". The message "Success! The domino-idp provider has
been created" should appear at the top of the window.

![](/screenshots/21.png)

Scroll to top and choose the "Mappers" tab under "Domino IDP" and click
"Create".

![](/screenshots/22.png)

In the resulting "Add Identity Provider Mapping" form, enter "mail" in the
"Name" textbox, choose "Attribute Importer" for the "Mapper Type" selection
box, enter "urn:oid:0.9.2342.19200300.100.1.3" in the "Attribute Name" textbox,
and finally enter "email" in the "User Attribute Name" textbox. Click "Save".

![](/screenshots/23.png)

The message "Success! Mapper has been created" should appear at the top of the
window. Click on "Identity Provider Mappers" at the top to return to the
previous screen.

![](/screenshots/24.png)

Click "Create" again.

![](/screenshots/25.png)

In the "Add Identity Provider Mapping" form, enter "givenName" in the "Name"
textbox, choose "Attribute Importer" for the "Mapper Type" selection box, enter
"urn:oid:2.5.4.42" in the "Attribute Name" textbox, and finally enter
"firstName" in the "User Attribute Name" textbox. Click "Save".

![](/screenshots/26.png)

The message "Success! Mapper has been created" should appear at the top of the
window. Click on "Identity Provider Mappers" at the top to return to the
previous screen.

![](/screenshots/27.png)

Click "Create" again.

![](/screenshots/28.png)

In the "Add Identity Provider Mapping" form, enter "sn" in the "Name" textbox,
choose "Attribute Importer" for the "Mapper Type" selection box, enter
"urn:oid:2.5.4.4" in the "Attribute Name" textbox, and finally enter "lastName"
in the "User Attribute Name" textbox. Click "Save".

![](/screenshots/29.png)

The message "Success! Mapper has been created" should appear at the top of the
window. Click on "domino-idp" to the right of "Identity Providers" at the top
of the screen.

![](/screenshots/30.png)

Right click on "SAML 2.0 Service Provider Metadata" to the right of the
"Endpoints" option. Save the link to your computer in a file named
"keycloak-sp.xml".

![](/screenshots/31.png)

![](/screenshots/32.png)

Open a new browser tab/window and load the URL
"http://127.0.0.1:8080/idp/keycloak-metadata.jsp". Click "Choose File". Select
the file "keycloak-sp.xml" that was just saved, and then click "Upload".

![](/screenshots/33.png)

![](/screenshots/34.png)

![](/screenshots/35.png)

You should see "Metadata upload successful". Close this browser tab/window.

![](/screenshots/36.png)

Returning to the keycloak browser tab/window, Choose "Authentication" from the
list on the left side.

![](/screenshots/37.png)

The "Flows" tab should be displayed. Make sure that "Browser" is selected in
the popdown list. Click on "Actions" at the far right of the "Identity Provider
Redirector" row and chose "Config".

![](/screenshots/38.png)

In the resulting "Create authenticator config" screen, enter "domino-idp" in
the both the "Alias" and "Default Identity Provider" textboxes, then click
"Save".

![](/screenshots/39.png)

A message "Success! Config has been created" should be displayed at the top of
the screen.

![](/screenshots/40.png)

This completes the additional configuration process.


Proof of Concept testing/demonstration
--------------------------------------

Before starting the proof of concept testing, ensure that the domino server has
been started in the domino idp vagrant vm (it does not start by default and
must be started manually).

First, an authentication using a local user in a keycloak realm authenticated
by the local keycloak database will be demonstrated.

Open a new private/incognito browser tab/window and load the URL
"https://samltest.id/start-idp-test/". Enter the saved entity id from the local
keycloak realm (eg, http://127.0.0.1:8888/auth/realms/local-16509) in the
"Login Initiator" box and click "GO!"

![](/screenshots/41.png)

The login screen for the keycloak local realm will be displayed. Enter the
username "localuser" and password "localpass" into the login form and click
"Sign In".

![](/screenshots/42.png)

The "SAMLtest IdP Test Landing Page" with information about the successful
authentication will be displayed. Close this browser tab/window after reviewing
the results.

![](/screenshots/43.png)


Next, an authentication processed by keycloak but delegated to the domino idp
and authenticated by the domino user database will be demonstrated. This
authentication will either create or update a user in the keycloak realm based
on the data returned from domino through the idp.

Open a new new private/incognito browser tab/window and load the URL
"https://samltest.id/start-idp-test/".  Enter the saved entity id from the
domino keycloak realm (eg http://127.0.0.1:8888/auth/realms/domino-25636) in
the "Login Initiator" box and click "GO!"

![](/screenshots/44.png)

The browser will be redirected to keycloak.

![](/screenshots/45.png)

Which will redirect the browser to the embedded domino idp.

![](/screenshots/46.png)

Which finally redirects the browser to the domino login UI. Enter "IDP-Demo
Admin" in the "User Name" textfield, and "password" in the "Password"
textfield. Click the "Submit" button.

![](/screenshots/47.png)

The "Prominic Multi-Factor Authentication (MFA) Setup" screen will be
displayed. Click the "Later" button to skip MFA setup and continue with the
authentication process.

![](/screenshots/48.png)

The browser will be sent back to the domino idp, which will redirect to
keycloak, which will then redirect to samltest. The "SAMLtest IdP Test Landing
Page" with information about the successful authentication will be displayed.
Close this browser tab/window after reviewing the results.

![](/screenshots/49.png)


Return to the keycloak administration browser tab/window and choose the "Users"
option under "Manage" on the list on the left under the Domino realm. Click the
"View all users" button.

![](/screenshots/50.png)

Click on the "ID" for the "idp-demo admin" user to display its record.

![](/screenshots/51.png)

This user record was dynamically created based on the delegated authentication
to the domino idp. If any of the user attributes such as email or first/last
name change in domino, they will be updated in keycloak during the next user
authentication.
