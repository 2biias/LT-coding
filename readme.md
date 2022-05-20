## Project structure
- The *gateway* directory contains code for the gateway (sender)
- The *node* directory contains code for the network nodes (receivers)

## How to build and run the project
1. Clone the repository to /home/vagrant
2. Go to either the gateway or node directory
3. Type "make" to build the project to the mote. "make TARGET=native" will build the project for the host machine
4. Type "make MOTES=/dev/ttyUSB0 node.upload login" while in the node directory to run the code on the mote
5. Type "make MOTES=/dev/ttyUSB0 gateway.upload login" while in the gateway directory to run the code on the mote  
