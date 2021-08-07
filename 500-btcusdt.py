# encoding:utf-8

import urllib.request
import time
import datetime
from decimal import Decimal
import telegram
bot = telegram.Bot(token="xxxxxxxx")
chatID = "-xxxxxxxxx"


buy = Decimal('2400')

resp = urllib.request.urlopen('https://api.zb.today/data/v1/kline?market=btc_usdt&type=5min&size=1')
html = str(resp.read().split(str.encode('"')))
list = html.split(',')
#print (list)
hig = list[9]
low = list[10]
#print (hig)
#print (low)

price = Decimal(hig) - Decimal(low)

print (price)
datenow = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
print (datenow)

if price > 450:
   print ('buy')
   bot.sendMessage(chat_id=chatID, text='买')
