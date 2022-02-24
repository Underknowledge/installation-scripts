#!/usr/bin/env python3

# https://github.com/lovvskillz/python-discord-webhook
# python3 /opt/discord-monitoring.py

comands = [ "w", "free -h", "timeout 5 df -H | grep -v 'Filesystem\|tmpfs\|cdrom\|loop\|overlay'", "curl ifconfig.co/json", " dmesg -T | grep -i 'error\|warn'", "systemctl | grep -i error", "docker ps", "hostname -I"]

from pathlib import Path
import subprocess
import sys
import time
import os

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])
try:
  import argparse
except ModuleNotFoundError:
  print("Module 'argparse' not installed. Installing...")
  install("argparse")
  print("Module 'argparse' installed.")
  import argparse
try:
  from environs import Env
except ModuleNotFoundError:
  print("Module 'environs' not installed. Installing...")
  install("environs")
  print("Module 'environs' installed.")
  from environs import Env
try:
  from discord_webhook import DiscordWebhook, DiscordEmbed
except ModuleNotFoundError:
  print("Module 'environs' not installed. Installing...")
  install("discord-webhook")
  print("Module 'discord-webhook' installed.")
  from discord_webhook import DiscordWebhook, DiscordEmbed

parser = argparse.ArgumentParser()
parser.add_argument('--pull', help='Update the script via github',
                    action='store_true'
                    )
parser.add_argument('--cmd', '--arbitrary', help='Run additionaly a command like \'ls - lah\'',
                    action='append', default=[], dest='cmd_line_arg', nargs='+', type=str
                    )
parser.add_argument('--systemd', help='define a systemd service to check', 
                    action='append', default=[], dest='systemd', nargs='+', type=str.lower
                    )
parser.add_argument('--clean', help='empty the default commands, best used with --cmd/--arbitrary',
                    action='store_true', required=False
                    )
parser.add_argument('--stin', help='Use it in a pipe to send it to discord',
                    action='store_true', required=False
                    )
parser.add_argument('--install', help='install a systemd service what runs every 8h',
                    action='store_true' ,required=False
                    )
parser.add_argument('--env', '-e', '-dot', help='Define another Channnel/webhook file, best to add an dot (.webhook) to have a hidden file',
                    default='.webhook', dest='dotwebhook_file', type=str
                    )

args = parser.parse_args()
# digest --clean
if args.clean:
  comands = []
if args.stin:
  comands = [ 'stin' ]
# digest --arbitrary
for cmd in args.cmd_line_arg:
  comands = comands + cmd
# digest --systemd
for cmd in args.systemd:
  systemd_listToStr = ' '.join([str(elem) for elem in cmd])
  systemd_check = ("systemctl status " + systemd_listToStr + " -l" )
  comands += [systemd_check] 

env = Env()
# add the script path to the dotwebhook_file
script_dir = os.path.abspath( os.path.dirname( __file__ ) )
if not "/" in args.dotwebhook_file:
  dotwebhook_file = ( script_dir + '/' + args.dotwebhook_file )
else:
  dotwebhook_file = ( args.dotwebhook_file )
env.read_env(dotwebhook_file)


if not Path(dotwebhook_file).exists():
    webhook_url = input("Enter your Discord webhook: \n")
    file_name = dotwebhook_file
    icon = "https://cdn.discordapp.com/attachments/879486731454406728/923670082377355304/unknown.png"
    custom_icon = input("enter the URL of your Custom Icon. leave empty to use fallback: \n")
    if custom_icon != "":
      icon = custom_icon
    dotwebhook = (f"webhook_url = \"{ webhook_url }\" \nicon = \"{ icon }\"")
    mask = 0o0027
    os.umask(mask)
    f = open(file_name, 'a+')
    f.write(dotwebhook)
    f.close()
env.read_env(dotwebhook_file)

exit()




# update
if args.pull:
  print("Downloading newer version")
  import requests
  import json
  url = 'https://api.github.com/repos/Underknowledge/installation-scripts/commits'
  params = ( ('path/python3/discord-monitoring.py', ''),  )
  r = requests.get(url, params=params )
  loadedjson = r.json()
  def get_commit_date(github_commit_dict):
      return github_commit_dict["commit"]["committer"]["date"]
  latest = max(loadedjson, key=get_commit_date)
  print(latest["commit"]["committer"]["date"])
  print(latest["commit"]["message"])
  url = 'https://raw.githubusercontent.com/Underknowledge/installation-scripts/master/python3/discord-monitoring.py'
  update = requests.get(url)
  open('/opt/discord-monitoring.py', 'wb').write(update.content)
  exit()

hostname = os.uname()[1]
username = os.environ.get('USER')
if username == None:
  username = "unknown" 
webhook_url = os.getenv('webhook_url')
icon = os.getenv('icon')

# the bot can have colorful mesages. set here a random HEX color
import random
rand = lambda: random.randint(0,255)
randcolor = ('%02X%02X%02X' % (rand(),rand(),rand()))

for cmd in comands:
  if cmd == 'stin':
    out = (sys.stdin.read())
  else:
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
  # send the message
  if (len(out))>1990:
    discordlimit = 1990
    chunks = [out[i:i+discordlimit] for i in range(0, len(out), discordlimit)]
    for part in chunks:
      webhook = DiscordWebhook(url=(webhook_url), rate_limit_retry=True, content='```' + (part) + '```' )
      if out != "":
        response = webhook.execute()
  else:
    out = out[:1990]
    webhook = DiscordWebhook(url=(webhook_url), rate_limit_retry=True, content='```' + (out) + '```' )
    if out != "":
      response = webhook.execute()

# https://pythonexamples.org/python-split-string-into-specific-length-chunks/
# https://stackoverflow.com/questions/18854620/whats-the-best-way-to-split-a-string-into-fixed-length-chunks-and-work-with-the/18854817


if args.install:
  servicepath = "/etc/systemd/system/discord-monitoring.service"
  servicefile = """
  [Unit]
  Description=Python Discord Service
  Wants=network-online.target
  After=network-online.target
  [Service]
  ExecStart=/usr/bin/python3 /opt/discord-monitoring.py
  WorkingDirectory=/opt
  Environment=PYTHONUNBUFFERED=1
  Type=oneshot
  [Install]
  WantedBy=multi-user.target
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
    os.system(" systemctl daemon-reload")
    os.system("systemctl enable --now discord-monitoring.timer")
    os.system("systemctl enable --now discord-monitoring.service")
    os.system("systemctl status discord-monitoring.timer")