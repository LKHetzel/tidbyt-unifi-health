# Unifi AP Health
## Shows how many APs are online or offline on a Ubiquiti Unifi Network

# Requirements (PLEASE READ CAREFULLY!)
This Tidbyt app does not "just work". A fair amount of one-time setup is required. If you have configured this for another Unifi Tidbyt App, you can add the app and skip the Prerequisite Setup.

Ubiquiti does not provide API access via the Cloud Console, so all requests must be done locally, and there are requirements for your Tidbyt and the Unifi device to communicate.

Due to limitations in the Starlark/Pixlet `http` module, invalid/self-signed certificates(such as the one installed by default on your Unifi device's local IP address) are not allowed, and will cause the app to fail. Maybe this changes one day.

I will provide some guidance for these items in the setup section below:

1. A "read-only" role on your Unifi console.
2. A dedicated user with the "read-only" role attached to it. Do NOT use a Super Admin role!
3. A Fully Qualified Domain Name that resolves to the local IP address of your Unifi gateway (i.e router.example.com `A record` 192.168.1.1)
4. Root CA (think LetsEncrypt) signed certificates installed on your UDM device, tied to the FQDN you set up for item 3.

# How this works:
I noted above that "Ubiquiti does not provide API access via the Cloud Console". The more accurate statement is "Ubiquiti does not provide API access/documentation. 

A lot of the work for this app comes from https://ubntwiki.com/products/software/unifi-controller/api

The Ubiquiti community at large has reverse engineered portions of the Unifi API, and that's what makes this possible, and they are to thank for this.

This app is simply authenticating as your read-only user, and executing a command to pull down health data about your network, and rendering it on the Tidbyt.

# Prerequisite Setup

## Read Only Role and User
It's very important to use a read only user in this case. The Unifi API has some commands that can disrupt your network, and you are technically transmitting the username and password via the Internet.
Limiting the access the Tidbyt user has is very important for the security of your network and to avoid potentially malicious apps that you may run on your Tidbyt and not know about it.

You should:
 - Use a dedicated user (I used tidbyt)
 - Use a unique, complex password

### Creating the Role
1. Log into your Unifi Console
2. Go to OS Settings
3. Go to Admins and Users, and stay on the Admins tab.
4. Click the "Manage Roles" button (it is the person icon, next to the plus icon)
5. Add a new role, give it a name.
6. Give the role "View Only" permissions to "Network". Set all other applications to "None".
7. Save the role.

### Creating a User
1. On the same Admins and Users page from above, click the "Add Admin" button (the plus icon next to the Manage Roles button)
2. Check the box for "Restrict to local access only."
3. Set a Username and Password. You will need these later when configuring the app using the Tidbyt mobile app.
4. Assign it the role you created earlier using the "Use a Predefined Role" dropdown.
5. Add the user.

### FQDN and TLS Certificate

There are a number of ways you can go about this, I recommend Scott Helme's great guide to setting HTTPS up on your Unifi device.
https://scotthelme.co.uk/setting-up-https-on-the-udm-pro/

As far as DNS and the TLS certificate working together, I did the following:
1. I set up an `A` Record (example: router.example.com ) on one of my domain names I own, pointing to `192.168.1.1` (The internal gateway IP the Tidbyt device can communicate to),
2. I used acme.sh to generate a certificate for `router.example.com`, but also used DNS validation (https://github.com/acmesh-official/acme.sh/wiki/dnsapi) to connect to my DNS Provider (Cloudflare) to automatically verify ownership of the domain.
3. I replaced the certificates on the UDM as described on Scott Helme's blog linked above. Since LetsEncrypt certificates are only valid for 60 days, I have a script that replaces them and restarts the Unifi software running on a Raspberry Pi I use for general internal hosting/automation/etc. It may be possible to do this directly on the UDM, but I am trying to have that be as stock as possible.
4. Finally, you have to set the "Name" of your UDM or Unifi device to the hostname you set up in DNS. This is done on the OS Settings > Console Settings page. That will make it so your router is advertising itself on your local network as that name. If you can navigate to https://<your_new_router_domain_here> in a browser and get to the Unifi Console that way, you're ready to move on.

# Connecting Tidbyt to Unifi
Congratulations on making it this far! You're now ready to use the Tidbyt mobile app to add the Unifi app(s) to your Tidbyt! You will need:
1. The Username and Password for the read-only user,
2. The domain name you set up.
3. If you have multiple sites on your Unifi Console, the name of the site.

You also need to know if you're using a CloudKey(or other legacy Unifi gateway) or one of the newer Dream Machine series gateways.

Find the App in the Tidbyt apps store, and fill in the items as directed. If you only have one site, or you do not know what a 'site' means in this context, leave the text box set to "default".

Add the app, and that's it! You should be seeing data related to the Unifi App you have installed.

If you want to use other apps in the Unifi app series, you can configure them the same way using the same settings.