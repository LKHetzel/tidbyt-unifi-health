"""
Applet: Unifi Health
Summary: Monitor network status
Description: Monitor Ubiquiti Unifi network health.
Author: LKHetzel
"""

load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

# Graphics
CHECKBOX = base64.decode("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAsklEQVQYV2NkAIIFT1b9//nvF4gJB+xMbAwJc7OaGBWPGv+X5BVBkfzB/JMh9VQkwwr9jQyMDPv4/zOwosgz/Lf5wMB4RICB4S8DAwvD388MDEwIBa9UXjAw7mFkYGAFCgIVMDH8/Qdk/GP4bw/kAWlRaVGIBpD4v39AE/4AOUANBTcKGP47/Wdg3AXkwABQDSPDBga4G/57ARVsQ1IAtuIuQxPILhBm3AyUhLLB9H0GBgAFIDuj7CIn3QAAAABJRU5ErkJggg==")


def get_data(API_BASE_URL, token, site):
    call = "%s/api/s/%s/stat/health" % (API_BASE_URL, site)
    rep = http.get(call, headers = {"Cookie": "TOKEN %s" % token})
    
    data = rep.json()
    if rep.status_code != 200:
        return None
    else
        return data
),

def get_apstatus(data)
    ap_online = data()["data"][1]("num_adopted", "")
    ap_offline = data()["data"][1]("num_disconnected", "")

    return {
        "ap_online": ap_online,
        "ap_offline": ap_offline,
    }

),
def main(config):
    username = config.get("username")
    password = config.get("password")
    url = config.get ("url")
    site = config.get("site")
    data = get_data(API_BASE_URL, token, site)
    ap_data = get_apstatus(data)
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
    ap_render = render.Column(
        children = [
            render.Row(
                cross_align = "center",
                children = [render.Padding(render.Image(src = CHECKBOX, width = 7, height = 7), pad = (0, 0, 0, 2))],
            ),
            render.Text(usage_data["upload"]["unit"], font = "tom-thumb"),
        ],
        cross_align = "center",
    )

    data_row = render.Padding(
        child = render.Row(
            children = [
                ap_render,
            ],
            expanded = True,
            main_align = "space_around",
            cross_align = "end",
        ),
        pad = (0, 2, 0, 3),
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