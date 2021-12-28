#!bin/bash

echo Welcome viewer

echo -e "Welcome Viewer \n\t Thanks for Viewing"

#Syntax for printing color message: echo -e "\e[COL-CODEmMessage\e[0m"
# echo - print message
# -e to enable colors with \e
# \e - enable color
# [COL-CODE - some color code
# m - End of color code
# MESSAGE - Message to print
# \e - enable one more color
# [0m - Zero is going to disable the color.

#Color Codes
#1 - Bold
#2 - Dim
#4 - Underline
#5 - Blink
#7 - Inverted
#8 - Hidden

#31(Text Color), 41(Background Color) - Red
#32(Text Color), 42(Background Color) - Green
#33(Text Color), 43(Background Color) - Yellow
#34(Text Color), 44(Background Color) - Blue
#35(Text Color), 45(Background Color) - Magenta
#36(Text Color), 46(Background Color) - Cyan

echo -e "\e[1mHello World in Bold text\e[0m"
echo -e "\e[4mHello World in Underlined text\e[0m"

echo -e "\e[31mHello World in Red Color\e[0m"
echo -e "Yellow Color, But only \e[33mYellow\e[0m word is Yellow color "

echo -e "\e[42mGreen Background\e[0m"

## Combinations

echo -e "\e[1;33mBold Yellow\e[0m"
echo -e "\e[31;43;4mRed On Yellow with underlined\e[0m"
