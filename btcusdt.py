# -*- coding: UTF-8 -*-
import os
import time
from PIL import ImageGrab
from PIL import Image
import pytesseract
from decimal import Decimal
import telegram
bot = telegram.Bot(token="xxxxx")
chatID = "-xxxxxxx" 



if __name__ == '__main__':
    bbox = (53, 183, 435, 233) 
    img = ImageGrab.grab(bbox)
    img.save(r"c:\btcusdt.jpg")
    num_1 = Image.open(r"c:\btcusdt.jpg")
    print(pytesseract.image_to_string(num_1))
    num_2 = pytesseract.image_to_string(num_1)
    num_3 = num_2.split(" ")
    print (num_3)
    
    ma5_1 = num_3[1]
    ma5 = Decimal(ma5_1)
    print (ma5)
   
    bollhig_1 = num_3[10]
    bollhig = Decimal(bollhig_1)
    print (bollhig)

    bolllow_1 = num_3[12]
    bolllow = Decimal(bolllow_1)
    print (bolllow)

    if ma5 > bollhig:
       print ('buy')
       bot.sendMessage(chat_id=chatID, text='buy')
    if ma5 < bolllow:
       print ('shell')
       bot.sendMessage(chat_id=chatID, text='shell')
