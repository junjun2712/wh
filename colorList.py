# -*- coding:UTF-8 -*-
import numpy as np
import collections


def getColorList():
    dict = collections.defaultdict(list)




    # blue
    lower_blue = np.array([100, 43, 46])
    upper_blue = np.array([124, 255, 255])
    color_list_blue = []
    color_list_blue.append(lower_blue)
    color_list_blue.append(upper_blue)
    dict['blue'] = color_list_blue


    return dict


if __name__ == '__main__':
    color_dict = getColorList()
    print(color_dict)

    num = len(color_dict)
    print('num=', num)

    for d in color_dict:
        print('key=', d)
        print('value=', color_dict[d][1])
