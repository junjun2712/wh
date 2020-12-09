# encoding:utf-8
import json
import re
import os
import filecmp
import urllib.request
import requests
import telegram
bot = telegram.Bot(token="xxxxxxx:xxxxxxxxxx")
chatID = "-xxxxxx"





r = requests.get('https://hero-api.jin10.com/accounts/67692/ticket?status=open')
#print(type(r.text))

json_str=r.text
results=json.loads(json_str)
print(results)
#print(type(results))


man_file = open('man_data.txt', 'w')
for i in results['data']:

    print (list(i.values())[0])
    print (list(i.values())[0],file=man_file)

man_file.close()


x = filecmp.cmp("/root/man_data.txt","/root/old_man_data.txt")
#print (x)

if x == 0:
    bot.sendMessage(chat_id=chatID, text='买 https://hero.jin10.com/#/personal_center/2433699_67692')
    os.rename("/root/man_data.txt","/root/old_man_data.txt")
