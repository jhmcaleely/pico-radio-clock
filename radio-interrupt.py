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

def showlen(p):
    val = p.value()
    transition_ms = time.ticks_ms()

    print("ms",transition_ms, "val", val,sep=",")
    
signal.irq(handler=showlen, trigger=Pin.IRQ_RISING | Pin.IRQ_FALLING )

time.sleep_ms(80000)

signal.irq()