#!/usr/bin/env python3

from discord_webhook import DiscordWebhook, DiscordEmbed
# pip install discord-webhook python-dotenv
# https://github.com/lovvskillz/python-discord-webhook
# python3 /opt/discord-monitoring.py

from dotenv import load_dotenv
load_dotenv()
# /opt/.env:
# pull in the vars:
#   webhook_url = ""
#   icon = ""

import time
import os
hostname = os.uname()[1]
username = os.environ.get('USER')
webhook_url = os.getenv('webhook_url')
icon = os.getenv('icon')
# change to use the variables right away

if username == None:
  username = "unknown" 

import random
rand = lambda: random.randint(0,255)
randcolor = ('%02X%02X%02X' % (rand(),rand(),rand()))


import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--pull", help="Update the script via github",
                    action="store_true")
args = parser.parse_args()
if args.pull:
    print("Downloading newer version")
    import requests
    url = 'https://raw.githubusercontent.com/Underknowledge/installation-scripts/master/python3/discord-monitoring.py'
    update = requests.get(url)
    open('/opt/discord-monitoring.py', 'wb').write(update.content)
    print(webhook_url)
    exit()

comands = ["cat /proc/loadavg", "w", "df -H | grep -v 'Filesystem\|tmpfs\|cdrom\|loop\|overlay'","docker ps" , "crontab -l", " dmesg -T | grep -i 'error\|warn'", "systemctl | grep -i error", "ip a", "ss -tlnp", "curl ifconfig.co/json" ]

for cmd in comands:
  out = (os.popen(cmd).read())
  webhook = DiscordWebhook(url=(webhook_url), rate_limit_retry=True )
  embed = DiscordEmbed(
      title="Comand: ", description=(cmd), color=(randcolor)
  )
  embed.set_author(
      name=(hostname),
      icon_url=(icon),
  )
  embed.set_timestamp()
  embed.add_embed_field(name="Run from:", value=(hostname))
  embed.add_embed_field(name="User:", value=(username))
  webhook.add_embed(embed)
  response = webhook.execute()

  if (len(out))>1990:
    discordlimit = 1990
    chunks = [out[i:i+discordlimit] for i in range(0, len(out), discordlimit)]
    for part in chunks:
      webhook = DiscordWebhook(url=(webhook_url), rate_limit_retry=True, content='```' + (part) + '```' )
      if out != "":
        response = webhook.execute()
        time.sleep(1)
  else:
    out = out[:1990]
    webhook = DiscordWebhook(url=(webhook_url), rate_limit_retry=True, content='```' + (out) + '```' )
    if out != "":
      response = webhook.execute()
      time.sleep(0.75)

# https://pythonexamples.org/python-split-string-into-specific-length-chunks/
# https://stackoverflow.com/questions/18854620/whats-the-best-way-to-split-a-string-into-fixed-length-chunks-and-work-with-the/18854817


from pathlib import Path
# print("File      Path:", Path(__file__).absolute())


servicepath = "/etc/systemd/system/discord-monitoring.service"
servicefile = """
[Unit]
Description=Python Discord Service
[Service]
ExecStart=/usr/bin/python3 /opt/discord-monitoring.py
WorkingDirectory=/opt
Environment=PYTHONUNBUFFERED=1
Type=oneshot
[Install]
WantedBy=default.target
"""

timerpath = "/etc/systemd/system/discord-monitoring.timer"
timerfile = """
[Unit]
Description=run Discord Service
[Timer]
OnBootSec=1min
OnUnitActiveSec=8h
[Install]
WantedBy=timers.target
"""

# types = ["service", "timer"]
# for type in types:
#   systemdservice = Path( (type) + 'path')
#   if not systemdservice.is_file():
#     f = open(( (type) + 'path'), "a")
#     f.write ( (type) + 'file')
#     f.close()

systemdservice = Path(servicepath)
if not systemdservice.is_file():
  f = open((servicepath), "a")
  f.write (servicefile)
  f.close()
systemdtimer = Path(timerpath)
if not systemdtimer.is_file():
  f = open((timerpath), "a")
  f.write (timerfile)
  f.close()
  #os.system("systemctl --user daemon-reload; systemctl daemon-reload; systemctl start discord-monitoring.service ;systemctl  enable --now discord-monitoring.timer; systemctl status discord-monitoring.timer")
  os.system(" systemctl daemon-reload")
  #os.system("systemctl start discord-monitoring.service")
  os.system("systemctl enable --now discord-monitoring.timer")
  os.system("systemctl status discord-monitoring.timer")
