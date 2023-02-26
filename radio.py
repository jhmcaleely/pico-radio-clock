from machine import Pin, Timer
import time

# PDN: Power Down: High = on ('power down' on)
# 0 for normal operation
pdn = Pin(1, mode=Pin.OUT, value=0)

# AON: Auto Gain Control on/off: High = on
# 1 for normal operation
aon = Pin(0, mode=Pin.OUT, value=1)

# OUT: Non-inverted output signal
signal = Pin(2, mode=Pin.IN)


pulse_length = 0
prev_signal = 0

last_transition_ms = 0
last_width = 0


def showlen(p):
    global last_width, last_transition_ms, prev_signal
    val = p.value()
    transition_ms = time.ticks_ms()
    width = transition_ms - last_transition_ms
    if width % 100 > 75 or (width % 100 < 25 and width > 100):
        if val != prev_signal:
            last_width = width
            last_transition_ms = transition_ms
            prev_signal = val
  #  if last_width > 450 and last_width < 550 and val == 1:
            interval = last_width // 100
            if last_width % 100 > 75:
                interval += 1
            interval *= 100
            print(val, interval, last_width)

last_transition_ms = time.ticks_ms()
signal.irq(handler=showlen, trigger=Pin.IRQ_RISING | Pin.IRQ_FALLING)



def getvalue(t):
    global last_width, last_transition_ms, prev_signal
    value = signal.value()
    if prev_signal != value:
        transition_ms = time.ticks_ms()
        last_width = transition_ms - last_transition_ms
        last_transition_ms = transition_ms
        if last_width < 50:
            print(prev_signal, transition_ms, last_width)
    prev_signal = value
    

#timer = Timer(mode=Timer.PERIODIC, period=10, callback=getvalue)

time.sleep_ms(60000)

#timer.deinit()