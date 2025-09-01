---
layout: post
title:  "Arduino Project 04 - Color Mixing Lamp"
date:   2025-08-24 12:00:00 -0800
categories: Computers Arduino
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/QNo-mNm9okY?si=8c4jXPIJfGFQLYal" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

This project introduces the use of pulse width modulation to control a three 
color led. Pulse width modulation is used to simulate an analog output from a 
digital output. This is done by modulating between the high and low states of 
the digital output with different length pulses to control the average voltage 
output. This project uses PWM to control the brightness of each color in the 3 
color led. To use an analog extending the pulse width is like turning a dimmer 
switch toward on, and turning the dimmer toward off would shorten the pulse 
width. Instead of using a dimmer switch this project introduces photo receptors 
to get an analog input that is used to then set the PWM duty cycle (which is 
essentially another term for the pulse width).

Technically this wasn’t a very challenging project as the rust arduino_hal 
library exposes a very simple API for enabling PWM and setting the duty cycle. 
My only hang up was realizing the pin needed to be enabled to use PWM before the 
duty cycle setting would do anything.
