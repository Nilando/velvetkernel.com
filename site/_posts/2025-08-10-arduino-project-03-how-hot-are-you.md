---
layout: post
title:  "Arduino Project 03 - How Hot Are You?"
date:   2025-08-10 12:00:00 -0800
categories: Arduino Software
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/FapRsXNX0mA?si=gE9PmEEkmJ8BoXIl" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

This project introduces you to analog input by introducing a temperature sensor. 
In the previous project the pins we used were digital meaning they either had a 
high voltage or a low voltage. However an analog pin can input/receive a range 
of decimal values between zero and one. Once you understand the difference 
between analog and digital pins, this project was quite simple to complete. 

First I placed the temperature sensor into the breadboard and hooked it up to 
an analog pin. Then I changed my program so that the 8 LEDs from the last 
project would now display the temperature in celsius. This required a bit of 
conversion to get the temperature in celsius as reading the pin first. First we 
convert the value returned into voltage by dividing by 1024 and multiplying by 5. 
Then to convert to celsius you subtract 0.5 and multiply by 100. With the 
reading now in celsius I went ahead and displayed it on the LEDs.

One interesting note I had while completing this project was that in order to 
read the analog pin, the arduino library required an analog to digital 
converter(ADC). Doing a little bit of research revealed that this is a circuit 
that is responsible for turning the analog input into a digital value we can 
work with. Apparently it's common for ADCs to be implemented by using lots of 
comparators which are electrical components that are able to compare to voltages 
and give an output indicating which is higher.

Anyways this was a relatively simple project(but fun!), on to the next!
