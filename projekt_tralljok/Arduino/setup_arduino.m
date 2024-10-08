if exist("my_arduino", "var") == false
    my_arduino = arduino("COM5", "Uno")
    x_servo = servo(my_arduino, "D3");
    writePosition(x_servo, 0);
end


radians2servo_value = @(rad) rad*1/(2*pi) + 0.5;
pause(2)