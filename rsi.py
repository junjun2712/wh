# -*- coding: UTF-8 -*-
import os
import time
from PIL import ImageGrab
from PIL import Image
import pytesseract
from decimal import Decimal
import urllib.request
from decimal import Decimal
import datetime
#from tkinter import * 
#from tkinter import messagebox
from apscheduler.schedulers.blocking import BlockingScheduler
from playsound import playsound
#import telegram
#bot = telegram.Bot(token="xxxxx")
#chatID = "-xxxxxxx" 

def job_function():
    bbox = (246, 554, 328, 578) 
    img = ImageGrab.grab(bbox)
    img.save(r"c:\rsi.jpg")
    num_1 = Image.open(r"c:\rsi.jpg")
    #print(pytesseract.image_to_string(num_1))
    num_2 =pytesseract.image_to_string(num_1)
    num_3 = Decimal(num_2[0:2])
    print (num_2)
    print (num_3)
    print(datetime.datetime.now())
    

	   
    if num_3 > 69:
       print ('shell')
      # bot.sendMessage(chat_id=chatID, text='buy')
       playsound('Windowserro.wav')
       playsound('Windowserro.wav')
       playsound('Windowserro.wav')
    if num_3 < 31:
       print ('buy')
     #  bot.sendMessage(chat_id=chatID, text='shell')
       playsound('Windowserro.wav')
       playsound('Windowserro.wav')
       playsound('Windowserro.wav')

scheduler = BlockingScheduler()
#scheduler.add_job(job_function, 'cron', day_of_week='0-6', minute="*/1")
scheduler.add_job(job_function,  'interval', seconds=20)
scheduler.start()
