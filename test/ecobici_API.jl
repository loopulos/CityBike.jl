using Requests

client_id = "583_1tsiascnb45c4s888sws844kgkgo4w0wcwk4g4k84w4co4osow"
client_secret = "6dec8xpcz2g4ggkw8s4wgcc0w88c4skg4sgw4kcc448swko40c"

URL = "https://pubsbapi.smartbike.com/oauth/v2/token?client_id=$(client_id)&client_secret=$(client_secret)&grant_type=client_credentials"

response = Requests.json(get(URL))

response["access_token"]
response["refresh_token"]

refresh_token_URL = "https://pubsbapi.smartbike.com/oauth/v2/token?client_id=$(client_id)&client_secret=$(client_secret)&grant_type=refresh_token&refresh_token=$(response["refresh_token"])"

stations = Requests.json(get("https://pubsbapi.smartbike.com/api/v1/stations.json?access_token=$(response["access_token"])"))

stations

availability = Requests.json(get("https://pubsbapi.smartbike.com/api/v1/stations/status.json?access_token=$(response["access_token"])"))

i = 1

availability["stationsStatus"][98]

[availability["stationsStatus"][i]["status"] == "OPN"]

find(x -> x == "CLS", [availability["stationsStatus"][i]["status"] for i in 1:length(availability["stationsStatus"])])
