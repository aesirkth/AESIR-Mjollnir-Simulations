# Trallgok Control-Algorithm
Author: Vilgot Lötberg, vilgotl@kth.se, 0725079097

<h2>Summary</h2>
PID-controllers have many diverse applications, and can be made to work in rocketry, though they come with a few problems, as has been discovered experimentally through simulation.



PD-controllers, as has been establised, only gives a response linearly proportional to the error. No error, no correction. The common way to combat this is to introduce an I-controller that integrates the error, and this works, though for dynamically unstable systems its not very well suited, as it's ment to handle stabile tendencies in the system. While stabile tendensies do occour in unstabile systems, like the above mentioned case where the controller intentionally introduces a constant error, it often instead leads to the I-controller becoming over-saturated and tipping the system over to a region where the accumulated history it has built up no longer applies. 

Think of an integral controller learning that it takes a certain amount of force to push a ball up a hill, only to think it requires the same amount of force in the same direction once the ball crosses over the top to the opposite hill. This can be mitigated to some extent by increasing the derivative-controllers athority or gain-value, and by limiting the range in which the I-controller is active, though the phenomenon persists to some extent. What is needed is an I-controller that is observant to local tendensies in the system, but ignorant of the global tendensies. A mix between a P and I controller, a non-linear controller.

A convenient technique for PD-controllers however; for many systems the gain-values for the P and the D term can be solved for such that one gets a system becomes critically damped. Even though instabilities in the system can offset these gains somewhat, the solution often ends up in the same order of magnitude. This makes the process of tuning the controller a lot easier, as it effectivly reduces the space of possibilities by one whole dimension.



Analytical form:
$$
E_P(t) = \int_{t_0}^{t} \theta(\tau -t)e^{-\tau T_P} \cdot T_P \cdot  \partial \tau  = (\theta * e^{-tT_P})(t)\cdot T_P \\
E_D(t) = \int_{t_0}^{t} \dot{\theta}(\tau -t)e^{-\tau T_D} \cdot T_D \cdot \partial \tau = (\dot{\theta} * e^{-tT_P})(t)\cdot T_D \\

M(t) = K_P\cdot E_P(t) + K_D\cdot  E_D(t)

$$

Differential form:

$$
\frac{\partial E_P}{\partial t} = -E_P(t)\cdot T_P + \theta(t) \cdot T_P \\
\frac{\partial E_D}{\partial t} = -E_D(t)\cdot T_D + \dot{\theta}(t) \cdot T_D \\

M(t) = K_P\cdot E_P(t) + K_D\cdot E_D(t)
$$