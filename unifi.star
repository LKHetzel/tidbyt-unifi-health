"""
Applet: Unifi Health
Summary: Monitor network status
Description: Monitor Ubiquiti Unifi network health.
Author: LKHetzel
"""

load("encoding/base64.star", "base64")
load("http.star", "http")
load("math.star", "math")
load("render.star", "render")
load("schema.star", "schema")

def get_apstatus(API_BASE_URL, token, site):
    call = "%s/api/s/%s/stat/health" % (API_BASE_URL, site)
    rep = http.get(call, headers = {"Cookie": "TOKEN %s" % token})

    if rep.status_code != 200:
        return None

    return rep.json()

def main(config):
    username = config.get("username")
    password = config.get("password")
    url = config.get ("url")
    site = config.get("site")
    udm = config.bool("udm_check", False)
    if udm:
        API_BASE_URL = "%s/proxy/network" % (url)
        API_AUTH_URL = "%s/api/auth/login" % (url)
    else:
        API_BASE_URL = "%s/" % (url)
        API_AUTH_URL = "%s/api/login" % (url)

    token = http.get(API_AUTH_URL, headers = {"Authorization": "Basic " + base64.encode(username + ":" + password)})


# Renders

    top_bar = render.Stack(
        children = [
            render.Box(width = 64, height = 8, color = "#007AFF", child = render.Box(color = "#000000", width = 48, height = 6)),
            render.Row(
                main_align = "center",
                cross_align = "center",
                expanded = True,
                children = [render.Text("Unifi Stats", height = 7, font = "tom-thumb", color = "#ffffff")],
            ),
        ],
    )

    return render.Root(
        child = render.Column(
            children = [top_bar],
        ),
    )


def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "username",
                name = "Username",
                desc = "Unifi Username",
                icon = "person",
            ),
            schema.Text(
                id = "password",
                name = "Password",
                desc = "Password for Unifi Account",
                icon = "key",
            ),
            schema.Text(
                id = "url",
                name = "Gateway/UDM IP/Host",
                desc = "IP or Hostname of your gateway, including https://.",
                icon = "globe",
            ),            
            schema.Text(
                id = "site",
                name = "Site Name",
                desc = "Name of the Site you want to monitor. Leave empty if you only have one site.",
                icon = "networkWired",
                default = "default"
            ),
            schema.Toggle(
                id = "udm_check",
                name = "Dream Machine",
                desc = "Enable if using Dream Machine series gateway.",
                icon = "server",
                default = False,
            ),
        ],
    )