---
layout: post
title:  "Arduino Project 02 - Spaceship Interface"
date:   2025-08-07 12:00:00 -0800
categories: Computers Arduino
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/bGYJ7Q0106w?si=D2At6bJwbO8A2oSI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

In this project you learn how to load a program onto the arduino board and also how you can use that program to control a digital pin which can in turn blink some LEDs. This project has quite a steep learning curve from the last project, as the process of loading the software onto the board can be a little bit complex. To add to that, I decided to stray from the book and write my first arduino program in Rust rather than use the arduino IDE. Also instead of making the logic for the “spaceship interface” that the book describes I decided it would be more fun to just make a simple binary number display. This required a bit less imagination and I felt it still taught me the same concepts. So the rest of this blog post will go through the steps of how I got my rust code loaded onto the board, and then it will go into the circuit and matching program for displaying an incrementing binary number.

I’m going to breakdown the process of loading our rust code onto the the arduino into 3 main steps
Configure the compiler to compile our code for the Arduino board
Tweak our main file so that it is able to be compiled for the Arduino
Set up a system for loading our compiled program onto the board

### Step 1 - Tell the Compiler to Target the Arduino

Our arduino has an ATmega328p chip which has an AVR RISC architecture. It needs code compiled for an AVR chip so we need to tell the rust compiler to make the correct kind of code.

So the first thing I did was create a new crate and create a special config file(./.cargo/config.toml)  to instruct the compiler to compile to AVR

```
[build]
target = "avr-none"
rustflags = ["-C", "target-cpu=atmega328p"]

[unstable]
build-std=[“core”]
```
This requires we use the nightly compiler which can be set via
rustup override set nightly

### Step 2 -  Make our code AVR Compatible

Then we need to tweak our default main file so that the code can now be compiled to AVR. First we add a few crates to our dependencies that will make some of this process a bit easier. 

```
arduino-hal = { git = "https://github.com/Rahix/avr-hal.git", features = ["arduino-uno"] }
panic-halt = "1.0.0"
```

We then need to edit our main file to fix a few things. First we need to set no_std which is to inform the compiler that we will not be using the standard library which expects an operating system(and one will not be present on the arduino). Second, we need to use a custom main function meant for the arduino which we do by first declaring #![no_main] and then adding infront of our main function #[arduino_hal::entry] as well as declaring that the function never returns. Lastly, we need to add a custom panic handler as the standard unwinding that happens during a panic cannot be done on the AVR. I also found that I had to add to my Cargo.toml file under both the dev and release profiles a line that says panic=”abort”. This felt wrong and is something I want to revisit as the panic-halt crate seems to suggest that just including it should be enough.

```
#![no_std]
#![no_main]

use panic_halt as _;

#[arduino_hal::entry]
fn main() -> ! {
    let dp = arduino_hal::Peripherals::take().unwrap();
    let pins = arduino_hal::pins!(dp);

    loop { }
}
```

### Step 3 - Load Our Code onto the Board
To do this we will use the ravedude crate, which we can install with cargo install ravedude. Then if we add to our config file these lines

```
[target.'cfg(target_arch = "avr")']
runner = "ravedude"
```

Now if we plug in our arduino and call cargo run, ravedude should take our compiled program and flash it onto our board.

### Writing My First Program for the Arduino

After that I set out to write a program that would light up some LED’s on my bread board so that they display a binary number. First thing I had to do was make the circuit that hooked up the 8 LEDS on the bread board. Then writing the code was pretty straight forward, and the finished result was quite fun to watch. Here's a link to the repo that has the code for controlling the LEDs to display an incrementing binary number.

