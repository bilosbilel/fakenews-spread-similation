# fakenews-spread-similation
With the technological revolution of the twenty-first century and the huge spread of smartphones
and as a result of the rapid growth of the Internet, particularly social media sites, which have
become an integral part of everyone’s life on the planet. Obtaining information through these
sites has become very familiar, but this matter leads us to the problem of the spread of fake-news
that often disturbed researchers and in various fields, and caused by this this development and
spread the problem moved to the field of computer science, which makes many academics got
interested in finding a way to reduce the speed and the depth of the propagation of a fake-news.
And because, we are attracted by this initiative, we decided and based on the characteristics of the user and the content of the information spreaded,
to develop a model based on
the epidemiological model (SIR), that would be able to determine the depth of the spread of
information through the network by highlighting the role of influential users in social media, as
well as the association of common interests among users.
As a result, our contribution consists in developing a simulation model for this phenomena.
The SIR epidemic model has been improved by adding the multi-agent systems paradigm and
user characteristics. satisfying results were achieved once we implemented our model in Netlogo.

# NetLogo
NetLogo is a programmable modeling environment for simulating natural and social phenomena.
It was authored by Uri Wilensky in 1999 and has been in continuous development ever since at
the Center for Connected Learning and Computer-Based Modeling [7]. NetLogo as a modeling
tool has many features,we cite :
• System:
– Free, open source
– Cross-platform: runs on Mac, Windows, Linux
• Programming:
– Fully programmable
– Approachable syntax
– Language is Logo dialect extended to support agents
• APIs:
– extensions API allows adding new commands and reporters to the NetLogo language
# Agent concepts
In NetLogo, there are four types of agents: turtles, patches, links, and the observer.
Turtles are agents that move around in the world. The world is two dimensional and is
divided up into a grid of patches. Each patch is a square piece of “ground” over which turtles can
move. Links are agents that connect two turtles. The observer doesn’t have a location – you can
imagine it as looking out over the world of turtles and patches.

# Agent variables
Agent variables are places to store values (such as numbers) in an agent. An agent variable can
be a global variable, a turtle variable, a patch variable, or a link variable. If a variable is a global
variable, there is only one value for the variable, and every agent can access it. You can think of
global variables as belonging to the observer. Turtle, patch, and link variables are different. Each
turtle has its own value for every turtle variable. The same goes for patches and links. You can
also define your own variables by using the globals keyword at the beginning of your code, like
this: globale score.
# Local variables
A local variable is defined and used only in the context of a particular procedure or part of
a procedure. To create a local variable, use the let command. If you use let at the top of a
procedure, the variable will exist throughout the procedure. If you use it inside a set of square
brackets, for example inside an “ask”, then it will exist only inside those brackets.
Setup and Go
A NetLogo template typically contains two main buttons are: setup and go. These two buttons
call the setup and go procedures.
- setup allows the preparation of an environment for a simulation such as the initialization
of variables, imports of agents, creation of turtles, etc .
- go to trigger the execution of the simulation.
# Implementation
In this section, we used the NetLogo tool to simulate the model proposed in the previous chapter
and to better understand the logo language we gonna explain some parts of our program .

# Deploying Agents
First of all we have four agent types :
• susceptible agent.
• infected agent.
• negative-infected agent.
• removed agent.
each agent have his characteristics defined by turtle-own which defines the variables
belonging to each turtle (agent in our case).
