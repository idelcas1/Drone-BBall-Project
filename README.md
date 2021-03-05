# Drone-BBall-Project
## Design Philosophy
### What shortcoming did you observe in the original controller performance that prompted you to consider this priority/goal?
In the original controller performance, the controller would be very unstable when tracking the thrust and flight paths thus prompting us to modify the drone controller and the preamp.
Also, after playing a few games against the qualification drone, we saw that when the ball was on the ground, the drone would go to pick up the ball but freeze when it reached the ball.
 
### What specific design decisions and/or improvements did you make to pursue this priority/goal?
In order to pursue these goals, we were experimenting with changing the preamp parameters and ultimately ended up decreasing the natural frequency of x_d and y_d.
In order to pursue the goal of stopping the drone from freezing when it had possession of the ball on the ground, we integrated simple if statements into the possession detection and finite state machine code.
 
### What tradeoffs were made by setting this as a priority/goal? What aspect of performance might have to suffer to achieve this priority/goal?
By making the drone more stable by tuning the preamp, the drone was ultimately more slow to responding to the ball location.
Also, since the drone does not move exactly to the right location how we desire, the drone sometimes misses the ball on the ground by assuming possession too early and goes for a shot without the ball. Therefore, the drone wastes a few seconds by having to go back to the ball after sensing it does not have the ball.
 
### How might pursuing this priority/goal make your drone competitive against drones that were designed without considering this priority/goal?
By making the drone more stable, the drone was able to make more accurate shots. We observed that when the drone had a more unstable preamp setting, the shots that missed the basket missed by a greater margin, which not only made it harder to make baskets, but more difficult to respond to the ball when it started to bounce around the court. Also, by making the drone more stable, the drone has the advantage to pick up the ball in a more timely manner, instead of hitting walls, the ground, or missing the ball altogether.
By stopping the drone from freezing on the ground, our drone would be able to pick up the ball and have a chance to score when other drones may still freeze. Also, after playing so many games against the qualification drone, it was seen that the drone with just a slight lag or freeze was not able to regain any competitive advantage or keep up with the other drones movements and lost almost every time; the drone with the first “jump” on the ball tended to win.
 
### What strategies might other drones use to counter the advantages of this priority/goal? 
To counter the goal of stabilizing our drone, opponent  drones may try to shoot an EMP or speed up and knock our drone to become unstable. To counter our goal of not freezing on the ground, other drones may not even go after the ball, rather go straight to their basket to block our shot, or attack us while we try to pick up the ball.

## Dynamical Controller Refinement
### Discuss your choice of which dynamics controller to use (e.g., Global Frame PID, Drone Frame PID, or State Feedback).
For the dynamics controller, we chose to go with the Global Frame PID controller since we have already had a robust controller from lab 4.
 
### Describe the test procedure used to quantify the performance of your dynamical controller. Use the “Reference Inputs for Testing” Signal Builder to create a test that is representative of some aspect of the competition (e.g., a sharp turn during fast movement, recovering from a flip, flying while stunned, flying upside-down during a dive, etc.).
The test procedure consisted of creating a test that would show the drone recover from a flip without spinning out of control. As a result from the animation plot, we can verify that the controller is robust from the drone reliably recovering from the flip.

![Screenshot 2021-03-04 230148](https://user-images.githubusercontent.com/22143323/110079416-f281c500-7d3d-11eb-952a-c69264cb47b5.png)

### State two quantifiable control objectives that were used to evaluate your dynamical controller’s performance during this test procedure. Discuss how these quantifiable objectives relate to one (or both) of the priorities/goals discussed above.
We designed the x-axis PID controller using the default linearization about the upright, stationary operating point, ẋ0 = 0 and 𝛳0 = 0. Then, we ensured that all poles of the root locus satisfy the design requirement that the settling time meet ts < 4 s. Also, we ensured that the maximum overshoot when following the "X-Axis Only" reference trajectory is less than 0.5 m. These objectives relate to the goal of making the drone stable and reliable by keeping a low overshoot from the desired path as well as having a low settling time which increases the responsiveness of the drone.

### Include and discuss root locus plot(s) and/or theoretical step response(s) used to refine your dynamical controller, and describe this refinement process (e.g., how did you linearize the model, where did you try to locate the closed loop poles, what features did you try to achieve in the theoretical step responses, etc.).
The approximate step response of the refined dynamical controller for x(t) from the Control System Designer app was as shown below. In the theoretical step response, we tried to achieve a low settling time along with a gradual slope to the desired trajectory.

![Screenshot 2021-03-04 230208](https://user-images.githubusercontent.com/22143323/110079426-f4e41f00-7d3d-11eb-8613-28fdab06cd16.png)

We have also designed for a maximum overshoot of 0.5 m which can be seen and measured by the Drone Kinematics scope shown below.

![Screenshot 2021-03-04 230224](https://user-images.githubusercontent.com/22143323/110079428-f6154c00-7d3d-11eb-9abe-4f16bca8a7ce.png)

As for the root locus plot, we developed one tuning of the x-axis/pitch controller/compensator blocks. In the tuning, the drone controller was designed to be as robust as possible, so that it can reliably recover from a flip. We tried to locate closed loop poles according to the design requirements stated earlier which are located around the cusp of the v-shaped design restraint.

![Screenshot 2021-03-04 230240](https://user-images.githubusercontent.com/22143323/110079432-f7df0f80-7d3d-11eb-93e5-31c8f42eb9ed.png)

### Include plots of the drone’s movement during the test both before and after refining your dynamical controller. Measure and state the performance related to each quantifiable control objective before and after this refinement.
The drone’s movement with the original controller was very unstable and aggressive by drastically veering away from the desired thrust and flight paths. However, after refining the dynamical controller the drone’s movement was more stabilized and reliable than the original controller, as seen by the drone kinematic scope below.

 ![Screenshot 2021-03-04 230301](https://user-images.githubusercontent.com/22143323/110079435-f9a8d300-7d3d-11eb-85bf-09121db3eecf.png)
 
## Finite State Machine Design
### Sketch a diagram of the finite state machine used by your controller. Then briefly discuss two additions or improvements you made to the original finite state machine and how these improved the control system’s performance in a manner consistent with one or both of your priorities/goals above. These can include improvements to the inputs or outputs of the finite state machine as well, like “possession”, “mag_on”, the Pre-Amp, etc. (or you can talk about these as your additional improvements below).

![Screenshot 2021-03-04 230315](https://user-images.githubusercontent.com/22143323/110079440-fada0000-7d3d-11eb-9253-d19a2f8e2fa4.png)

The two additions or improvements made to the original finite state machine consisted of getting the drone unstuck when the ball was not moving on the ground, instructing the drone to catch the ball instead of waiting for a rebound, and changing the height of the desired location after gaining possession in order for the drone to have a better arc when throwing the ball. These additions improved the control systems’ performance according to our goals of being steady and reliable by preventing the drone from having an instance where it's stuck or just hovering like when the ball is not moving or when the drone is just waiting for a rebound. 
 
 
## One Additional Improvement
### Describe the feature you improved or designed.
The original drone design’s only way to score was to drop the ball when hovering over the hoop. So, improving the magnet controller by implementing projectile dynamics would increase the shot opportunities of the drone. By setting the 3-point shot as a goal, we sacrificed the reliability when hovering over the hoop for a shot. For example, sometimes the drone would nearly miss the hoop when shooting, resulting in the drone having to chase and pick up the ball again in order to have another attempt at a shot, thus losing valuable time. By implementing projectile shooting, our drone would have the advantage to score more points in a more timely manner. Instead of having to move exactly over the basket and drop the ball, the drone would only need to reach a certain height and velocity anywhere on the court to make a shot. This would also allow the drone to have better vantage points and react quicker to rebounds if the drone misses, or on ball resets if the drone makes a basket. 
 
### Describe the test procedure used to quantify the performance of this controller feature. You
might again use the “Reference Inputs for Testing” Signal Builder, or set up a specific scenario to test this feature (e.g., start in possession of the ball at half-court), or count a relevant measure during several games of normal play (e.g., basket shooting percent, EMP shooting percent, etc.).
The test procedure used to quantify the performance of the controller was observing whether or not the drone shot the ball rather than hover over the basket during several games of normal play. Also, we analyzed the basket shooting percentage of the drone during several games in order to achieve an average shooting average of over 50%.
 
### State two quantifiable control objectives that were used to evaluate this feature’s performance during this test procedure. Discuss how these quantifiable objectives relate to one (or both) of the priorities/goals discussed above.
The two quantifiable control objectives that were used to evaluate the magnet controller’s performance during the test procedure were using a range between -0.1 and +0.1 in order for the projectile motion to operate in between as well as the time equation defined using the kinematics of the x-axis. Another control objective used in the magnet controller was the relationship between the x-axis and the y-axis velocities being ± 0.1.

### (Optional) Include any analytical work you used to support your design process.

![Screenshot 2021-03-04 230338](https://user-images.githubusercontent.com/22143323/110079443-fc0b2d00-7d3d-11eb-918a-ca8eb7d85225.png)

### Include plots of the drone’s movement during the test both before (if applicable) and after refining your dynamical controller. Measure and state the performance related to each quantifiable control objective before and after this refinement.
When analyzing the drone’s movement from before and after refining the magnet controller, the drone is much more stable and reliable than the original due to its ability to convert all of its attempted shots from a distance. The original magnet controller only took a shot if it was 2m above the hoop while also missing because of the incorrect hoop position used. The quantifiable control objectives allowed the drone to estimate the projectile motion of the ball within a range of ±0.1 and shoot the ball according to the velocity relationship of the x-axis and y-axis within ±0.1.

![Screenshot 2021-03-04 230353](https://user-images.githubusercontent.com/22143323/110079448-fca3c380-7d3d-11eb-8166-3c4e2957c3fa.png)
