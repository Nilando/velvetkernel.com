---
layout: post
title:  "Arduino Project 05 - Controller A Servo"
date:   2025-08-31 12:00:00 -0800
categories: Arduino Software
---

This is project 5 of the arduino project book where we learn how to control a servo. In this project we make use of PWM (which we learned about in the last project) to control a servo which is like a motor but can be controlled to rotate to specific angles. The project also introduces capacitors and got me looking into the datasheet of the ATmega328P in order to get PWM working with the servo. 

The first thing I did was build the circuit which uses lots of new components. This project introduces the capacitor which is a ubiquitous component in electronics that serves many uses. One thing they can be used for is smoothing out voltage fluctuations which is useful in the case of motors when changing from stopped and started states could cause sudden drops or spikes in voltage. Capacitors are able to smooth sudden changes in voltage by their nature of acting as voltage reservoirs. When the input voltage rises the capacitor begins to store charge, and when the input voltage falls the capacitor begins to release energy allowing the capacitor to fill the dips and the peaks of the input voltage. One important thing to call out that the book does a good job mentioning is that capacitors can be dangerous! The capacitor is a directional component that needs its positive and negative terminals connected correctly or else the capacitor could explode! So after carefully reviewing the books circuit diagram and connecting up the servo motor to the board along with a potentiometer as an analog input for controlling the motor, my circuit was complete.

The next step was to write the code to control the motor. The gist of the code is that the servo expects timed pulses at a certain frequency, and the width of those pulses determines the angle the servo will rotate to. To write this code I again have to deviate from the book since I am using rust along with the arduino_hal crate, and not the Arduino IDE. With the arduino IDE, I believe you get a very friendly servo API that allows you to simply call a function to set the angle of the servo. However, the rust arudino_hal crate is much less abstracted and requires a bit of tweaking of the actual registers of the ATmega328P chip to send the correctly timed pulses to the servo. I found this example code from the arduino_hal repository on how to control a basic servo and to my surprise running that code basically worked. It required a little debugging of the max and min duty cycles for controlling the servo but once I tweaked those values I was done with the code for this project. The only thing was I still had no idea what this section of the code was doing:

```
let tc1 = dp.TC1; tc1.icr1.write(|w| w.bits(4999)); 
tc1.tccr1a.write(|w| w.wgm1().bits(0b10).com1a().match_clear()); 
tc1.tccr1b.write(|w| w.wgm1().bits(0b11).cs1().prescale_64());
…
tc1.ocr1a.write(|w| w.bits(duty as u16));
```

Unfortunately the comments in the example I found were not very descriptive, so I took a look at the ardunio_hal crate and the ATmega328P datasheet to get some insight into what was going on here. 
While it is not my goal to fully understand and describe all the details of the ATmega328P in this introductory project, I still want to gain some understanding of what's going on here. First, we are getting a handle to the timer peripheral associated with digital port 9. This timer peripheral is a small circuit that has a few registers we can use to modify the timer's functionalities. We need to make sure that the timer is in a PWM mode and pulsing at the correct frequency and to do so we use the arduino hal’s crate provided methods for updating those registers on the timer 1 peripheral. I’m basically skipping over all the details and settings available on this timer peripheral, but for this intro project introducing a servo I think this is a good base level of understanding.
