# -*- coding:UTF-8 -*-
import cv2
import colorList


def get_color(frame):
    print('go in get_color')
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    maxsum = 0
    color = None
    color_dict = colorList.getColorList()
    for d in color_dict:
        mask = cv2.inRange(hsv, color_dict[d][0], color_dict[d][1])
        # cv2.imwrite(d + ".png", mask)
        binary = cv2.threshold(mask, 127, 255, cv2.THRESH_BINARY)[1]
        binary = cv2.dilate(binary, None, iterations=2)
        # cv2.imwrite(d +"1.png", binary)
        cnts = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]
        sum = 0
        for c in cnts:
            sum += cv2.contourArea(c)
        # print("%s  , %d" %(d, sum ))
        if sum > maxsum:
            maxsum = sum
            color = d
    return color


if __name__ == '__main__':
    filename = "./test2.png"
    frame = cv2.imread(filename)
    print(get_color(frame))
