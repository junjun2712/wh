#pip install pillow
#pip install python-telegram-bot==9.0.0
#wget https://github.com/python-telegram-bot/python-telegram-bot/releases/download/9.0.0/python-telegram-bot-9.0.0.tar.gz
# cd python-telegram-bot
# python setup.py install

# -*- coding: UTF-8 -*-
import os
import time
from PIL import ImageGrab
from PIL import Image
import math
import operator
from functools import reduce
import telegram
bot = telegram.Bot(token="888888888888888888888")
chatID = "-8888888888" 


def image_contrast(img1, img2):

  image1 = Image.open(img1)
  image2 = Image.open(img2)

  h1 = image1.histogram()
  h2 = image2.histogram()

  result = math.sqrt(reduce(operator.add, list(map(lambda a,b: (a-b)**2, h1, h2)))/len(h1) )
  return result

if __name__ == '__main__':
  while 1==1:
    time.sleep(60)
    bbox = (15, 206, 113, 668)
    img = ImageGrab.grab(bbox)
    img.save("img1.png")
    #os.rename('c:\\img1.png','c:\\img2.png')
    #img.show()
    img1 = "c:\\img1.png" # 指定图片路径
    img2 = "c:\\img3.png"
    result = image_contrast(img1,img2)
    print(result) 
    if int(result) > 0:
        bot.sendMessage(chat_id=chatID, text='买')
        os.remove('c:\\img3.png')  
        os.rename('c:\\img1.png','c:\\img3.png')
  
