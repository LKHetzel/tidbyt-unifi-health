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

def UDMAuth(API_AUTH_URL, USERNAME, PASSWORD):
    jsonBody = {"username": USERNAME, "password": PASSWORD}
    resp = http.post(API_AUTH_URL, headers = {"Content-Type": "application/json"}, json_body = jsonBody)
    headers = resp.headers
    cookie = headers["Set-Cookie"]
    return str(cookie)

def getHealthData(API_BASE_URL, AUTH_TOKEN, SITE):
    print("get status of udm from", API_BASE_URL)
    call = "%s/api/s/%s/stat/health" % (API_BASE_URL, SITE)
    print("getting from:", call)
    resp = http.get(call, headers = {"cookie": "%s" % AUTH_TOKEN})
    data = resp.json()
    scode = str(resp.status_code)
#    errtext = "Error"
#    if scode != 200:
#        return errtext
#    else:
    return data


def main(config):
    USERNAME = config.get("username")
    PASSWORD = config.get("password")
    BASE_URL = config.get("url")
    udm = config.bool("udm_check", True)
    if udm == True:
        API_BASE_URL = "%s/proxy/network" % (BASE_URL)
        API_AUTH_URL = "%s/api/auth/login" % (BASE_URL)
    else:
        API_BASE_URL = "%s/" % (BASE_URL)
        API_AUTH_URL = "%s/api/login" % (BASE_URL)
    SITE = config.get("site")
    AUTH_TOKEN = UDMAuth(API_AUTH_URL, USERNAME, PASSWORD)

    healthData = getHealthData(API_BASE_URL, AUTH_TOKEN, SITE)
    ap_online = (str(int(healthData["data"][0]["num_ap"])))
    ap_offline = (str(int(healthData["data"][0]["num_disconnected"])))



# Renders

    top_bar = render.Stack(
        children = [
            render.Box(width = 64, height = 8, color = "#007AFF", child = render.Box(color = "#000000", width = 48, height = 6)),
            render.Row(
                main_align = "center",
                cross_align = "center",
                expanded = True,
                children = [render.Text("Unifi APs", height = 7, font = "tom-thumb", color = "#ffffff")],
            ),
        ],
    )
    online = render.Stack(
        children = [
            render.Column(
                expanded=True,
                main_align="space_evenly",
                cross_align="start",
                children=[
                    render.Row(
                        children=[
                        render.Text("Online: ", font = "tom-thumb"), 
                        render.Text(ap_online, font = "tom-thumb"),
                        ]
                    ),
                    render.Row(
                        children=[
                        render.Text("Offline: ", font = "tom-thumb"), 
                        render.Text(ap_offline, font = "tom-thumb"),
                        ]
                    ),
                ],
            ),
        ]    
    )

    return render.Root(
        child = render.Column(
            children = [top_bar, online],
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
