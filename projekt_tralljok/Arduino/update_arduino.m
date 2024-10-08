
servo_value = radians2servo_value(mjolnir.guidance.alpha*2*pi/360)
writePosition(x_servo, servo_value)
