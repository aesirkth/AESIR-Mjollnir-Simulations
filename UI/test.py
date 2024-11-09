import csv, re
import numpy as np
import mathutils as mt

def read_rocket_file(filename):
    rocket = dict()

    reader = open(filepath, 'r')


    line_nr = 1
    done = False

    while not done:
        line = reader.readline().replace('\n', '')
        if 'rocket' in line:
            name         = line.replace('rocket.', '')
            rocket[name] = list()
        elif len(line) != 0:
            rocket[name].append(line)

        if len(line) == 0:
            done = True

    reader.close        

    for key in rocket.keys():
        for index in range(len(rocket[key])):
            if 'i' in rocket[key][index]:
                Complex = True
            else:
                Complex = False

            rocket[key][index] = rocket[key][index].split(',')
            if '' in rocket[key][index]:
                rocket[key][index].remove('')

            if Complex:
                rocket[key][index] = [element.replace('i','j') for element in rocket[key][index]]
                rocket[key][index] = [complex(element)         for element in rocket[key][index]]
            else:
                rocket[key][index] = [float  (element)         for element in rocket[key][index]]

        

        if len(rocket[key]) != 0:
            rocket[key] = np.vstack(rocket[key])

    return rocket


filepath = 'C:\\Users\\jonas\\OneDrive - KTH\\Matlab-drive\\AESIR-Mjolnir-Simulations\\test.txt'
rocket = read_rocket_file(filepath)
print(rocket['t'].size)

for index in range(0,rocket['t'].size):
    attitude = np.hstack( (rocket['attitude'][:,index].reshape(3,3), mt.Vector(0,0,0)) )
    attitude = np.vstack( (attitude, mt.Vector(0,0,0,1)) )
    print(attitude)