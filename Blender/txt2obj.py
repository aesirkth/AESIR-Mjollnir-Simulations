import bpy, mathutils, numpy, os, shutil, re


def txt2obj(filename):
    
    file = open(filename, 'r')
    data = file.read()
    data = data.split('\n')
    
    
    for row in range(0,len(data)):
        is_position = (re.search('position' , data[row]) != None)
        is_mesh     = (re.search('mesh'     , data[row]) != None)
        is_attitude = (re.search('attitude' , data[row]) != None)
        
        is_body = is_position + is_mesh + is_attitude
        
        if is_body:
            address         = data[row].split('.')
            body_name       = address[-2]
            already_created = any(name==body_name for name in bpy.data.objects.keys())
            has_mesh        = any(
                                  re.search(body_name+".mesh", element)!= None,  
                                  for element in data
                                  )
            if has_mesh and not already_created:
                mesh_filename_index = data.index(data[row])