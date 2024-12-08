# Creating and modelling rockets
Author: Vilgot Lötberg, vilgotl@kth.se, 0725079097

![](./Assets/mjollnir2.png)

The below code can be found at: https://github.com/aesirkth/AESIR-Mjollnir-Simulations

<h2>Contents:</h2>

- Understanding how the main script and the other high level scripts work
- Understanding the rocket-structure
    - Coordinate-systems and basis
- Understanding models and ODE-structure
    - Models
    - ODE-structure and derivatives


**NOTE!**
In this article, the words struct, structure and object are used interchangably to refer to the same thing.
Similarly, the words list and cell are used interchangably to refer to the same thing.
The name ``my_rocket`` is primarily used as a variable when the variable is an 
**instance** of a certain rocket, for example when using the command-line to spawn a rocket or in a main-script, while ``rocket`` is used in code that can deal with any possible instance.


<h2>Understanding how the main script and the other high level scripts work</h2>




<h2>Understanding the rocket-structure</h2>

**NOTE!** This is not a comprehensive guide to what fields are contained in the rocket-struct at any given instance, as this is an ever changing code-base. This is simply meant as a guide to navigating the rocket-structure. To get a detailed view of what fields and parameters are contained in a given rocket, the instructions below describe how to obtain that information.

Creating a new rocket using this codebase requires a basic understanding of how, and why the codebase is structured. Typing into the MATLAB command-line interface (the reader is encouraged to type along):

```
>> setup

>> my_rocket = mjollnir

my_rocket = 

  struct with fields:

                name: "Mjöllnir"
         dont_record: [""    ""]
              models: {[@propulsion_model]  [@aerodynamics_model]  [@gravity_model]}
     state_variables: {["attitude"]  ["angular_momentum"]  ["position"]  ["velocity"]}
          enviroment: [1×1 struct]
          rigid_body: [1×1 struct]
              forces: [1×1 struct]
             moments: [1×1 struct]
            attitude: [3×3 double]
    angular_momentum: [3×1 double]
       rotation_rate: [3×1 double]
            position: [3×1 double]
            velocity: [3×1 double]
                mass: 80
        length_scale: 4
                mesh: "Assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl"
        aerodynamics: [1×1 struct]
              engine: [1×1 struct]

```


This is the basic jist of it. The rocket is sorted into a hierarchy of structures (MATLAB struct, see https://se.mathworks.com/help/matlab/ref/struct.html). The reason for this is to make naming of variables easy, and improving code understandability. For example, when accessing a rocket parameter, say the orientation of the nozzle, one could index into the ``engine`` struct shown above as a field under ``my_rocket``, to see more closely what fields it has:

```
>> my_rocket.engine

ans = 

  struct with fields:

       burn_time: 20
    thrust_force: 4000
        position: [3×1 double]
        attitude: [3×3 double]
          nozzle: [1×1 struct]
```

Here one can see that the rocket contains a field called ``nozzle``:

```
>> my_rocket.engine.nozzle

ans = 

  struct with fields:

    position: [3×1 double]
    attitude: [3×3 double]

```

And bingo, the parameter describing the orientation of the nozzle has been found, namely ``attitude``:

```
>> my_attitude = my_rocket.engine.nozzle.attitude

my_attitude =

     1     0     0
     0     1     0
     0     0     1

```


Notice that if the line ``rocket.engine.nozzle.attitude`` was to appear in code, figuring out what property of the rocket it was reffering to and what was being calculated would be quite easy to figure out. Following this structure makes the code relatively self documenting, making it easy to backtrack and figure out what does what.

<h3>Coordinate-systems and basis</h3>
<h4>TLDR:</h4> 
In general, coordinate systems follow this pattern:

**All an objects properties are in the objects parents basis!**
If the parent has no specified basis, it inherets the basis of its next successive parent.


<h4>Extended:</h4>

In general when working with properties that are vectorized, they are ment to be interpreted as though they are in a certain basis. For example, properties like the rockets position: ``rocket.position `` are written in the worlds basis, i.e:

```
>> my_rocket.position

ans =

     0
     0
   990
```

means that the rocket is at z=900 relative to origin.

However, reading a property such as center of mass:


```
>> my_rocket.rigid_body.center_of_mass

ans =

         0
         0
    0.5000
```

This property is not defined relative to the world-basis, and is instead defined relative to the rockets internal coordinate system.


In general, coordinate systems follow this pattern:

**All an objects properties are in the objects parents basis!**

This is how things are usually structured in 3D-software, think Blender, Unity, CAD, etc.

For all properties under ``rocket``, like ``rocket.position``, they will be in the rockets's parents basis, ie the world. For properties under ``rocket.rigid_body``, they will be in the ``rocket.rigid_body``'s parent's basis, ie ``rocket``. 

For example ``rocket.rigid_body.center_of_mass`` will be in the basis of ``rocket``.

What this basis acually is is ALWAYS described by the property ``attitude``, whether it be ``rocket.attitude``, ``rocket.engine.nozzle.attitude``, or ``rocket.fins.attitude``, this 3x3 matrix describes the basis vectors of it's parent object.

If the parent has no property ``attitude``, then it assumes the basis is the same one as its parent.




<h2>Understanding models and ODE-structure</h2>

<h3>Models</h3> 

<h4>TLDR:</h4> 

A model is meant to encompass and model some behaviour of the rocket. For examples, see ``aerodynamics_model.m``, ``gravity_model.m`` or ``propulsion_model.m``.

All the rockets models get stored in a list (https://se.mathworks.com/help/matlab/ref/cell.html) inside the ``rocket`` -struct called ``rocket.models``.

```
>> my_rocket.models

ans =

  1×5 cell array

    {@equations_of_motion}    {@propulsion_model}    {@aerodynamics_model}    {@gravity_model}    {@equations_of_motion}
```


All models are functions with input and output ``rocket``. 

Thus, adding a model to a rocket can be done via:

```
rocket.models{end+1} = @my_model;
```

Or, inside the rockets own creation-function:

```
rocket.models = {@model1, @model2, @model3, .... @my_model};
```


Prefferably, the actual function script is stored in a .m file under /Models.

![](Documentation/models.png)




<h3>ODE-structure and derivatives</h3> 

<h4>TLDR:</h4> 

When working with and modelling a parameter that needs to be integrated, on the ODE form:

$$\frac{\partial \text{my parameter} }{\partial t} = f(\text{my parameter})$$

Or rather, since ``my_parameter`` is necessarily a property of ``rocket`` in some way, it instead becomes:

$$\frac{\partial \text{my parameter}}{\partial t} = f(\text{rocket})$$

For these occasions, the ``rocket`` has a field called ``rocket.derivative``.

(https://se.mathworks.com/help/matlab/ref/containers.map.html (used instead of dictionary, as dictionaries don't yet support vectorized values). Henceforth, the word dictionary will be used to refer to containers.Map()  ). 

The keys and size of the values of the ``rocket.derivative`` have to be specified before running the simulation, for example in the rocket initiation script. For example, with the parameter ``rocket.my_parameter``:

In the rocket initialization-script:
```
function rocket = some_rocket()
rocket = struct();
rocket.derivative = containers.Map();

rocket.my_parameter = zeros(3,1); 
rocket.derivative("my_parameter") = zeros(3,1);
```

The dictionary-key is the parameter name as a string. For examples of this, see ``mjollnir.m`` or ``trallgok.m``.

Assigning something to this derivative, say in a model-script:

```
function rocket = my_model(rocket)

dmy_parameter_dt = ...

rocket.derivative("my_parameter") = dmy_parameter_dt;

```

When the ODE is solved a script will automatically go through the derivative, integrate it, and assign the respective values back to the respective parameters inside ``rocket``.

This works similarly with nested paramters, except now the keyword is not just the variable name, but the entire **address** to the parameter inside ``rocket``:

In the rocket initialization-script:
```
function rocket = some_rocket()
rocket = struct();
rocket.derivative = containers.Map();

rocket.subcomponent = struct();
rocket.subcomponent.my_parameter = zeros(3,1); 
rocket.derivative("subcomponent.my_parameter") = zeros(3,1);
```

In a model-script:

```
function rocket = my_model(rocket)

dmy_parameter_dt = ...

rocket.derivative("subcomponent.my_parameter") = dmy_parameter_dt;

```

In general, think of the keyword as the address to the variable in question.


<h2>Reserved parameters</h2>

<h4>TLDR:</h4>   

The following keywords are reserved for specific purposes, but may be added, removed or changed, so long as the programmer is aware that they :

- **position** : position of parent in relation to grandparent (see  **Coordinate-systems and basis**)
- **attitude** : attitude - II -
- **center_of_mass** : center of mass - II -
- **moment_of_inertia** : moment of inertia -II-
- 


<h4>Extended:</h4> 

Some parameters in the model are reserved, or have a ready defined meaning.