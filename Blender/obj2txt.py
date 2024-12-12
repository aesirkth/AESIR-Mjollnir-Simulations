import bpy, mathutils, numpy, os, shutil

def obj2txt(obj, path, *args, **kwargs):
    
    filename = kwargs.get('filename', None)
    address  = kwargs.get('address',  None)
    
    if filename == None:
        if os.path.exists(path):
            shutil.rmtree(path)
        os.makedirs(path)
        filename = path+"\\"+obj.name+".txt"
    
    if address == None:
        address = obj.name
    
    for child in obj.children:
    
        with open(filename, 'a') as file:
            child_address       = address + "." + child.name
            child.rotation_mode = 'QUATERNION'
            position            = numpy.array(child.location)
            attitude            = numpy.array(child.rotation_quaternion.to_matrix())
            
            file.write(child_address+'.position\n')
            numpy.savetxt(file, position, delimiter=',')
            file.write(child_address+'.attitude\n')
            numpy.savetxt(file, attitude, delimiter=',')
            
            if child.type == 'MESH':
                file.write(child_address+'.mesh\n')
                file.write(child.name+'.stl\n')
                stl_path = path+'\\'+child.name+'.stl'
                
                
                # Un-parenting and saving logic
                matrix_world_child  = child.matrix_world.copy()
                matrix_world_parent = obj  .matrix_world.copy()
                matrix_world_parent.invert()
                matrix_local = matrix_world_parent @ matrix_world_child
                child.matrix_world = matrix_local
                
                #bpy.ops.object.transform_apply(location = True, rotation = True, scale = True)
                bpy.ops.object.select_all(action='DESELECT')
                child.select_set(True)
                
                bpy.ops.export_mesh.stl(
                                        filepath=stl_path,
                                        use_selection=True)
                #bpy.ops.object.parent_set(type='OBJECT')
                child.matrix_world = matrix_world_child
                #bpy.ops.object.transform_apply(location = True, rotation = True, scale = True)
                child.select_set(False)
        
        obj2txt(child, path, filename=filename, address = child_address)