%a = arduino("COM5", "Uno");

%while true
%writeDigitalPin(a, "D7", 1)
%pause(1)
%writeDigitalPin(a, "D7", 0)
%pause(1)
%end


s = servo(a, "D3");

while true
writePosition(s, 1);
pause(1)
writePosition(s, 0);
pause(1)
end