VHDL sensor board
# SPI Interface for MCP25625

This project develops an SPI (Serial Peripheral Interface) communication interface for the MCP25625, a CAN controller with integrated CAN transceiver. The primary goal is to facilitate data communication between a microcontroller and the MCP25625 using VHDL.

## Project Overview

The SPI interface implemented in this VHDL project enables communication with the MCP25625 CAN controller. The driver accepts data to send and uses a flag to initiate the transmission process.

## Current Status

- **Data Sending**: The driver accepts data that needs to be transmitted over SPI on a 24 bit bus.
- **Start Flag**: Transmission begins when the start control flag is set, allowing for controlled communication.

## Signal Analysis/Simulation

Example sending a sequence of signals serially: 0xAA, then 0xAABB then 0xAABBCC

![Signal Simulation](/images/MCP25625_SPI_AA_AABB_AABBCC.png)


## Directory Structure

Xilinx/Vivado

```plaintext
/
|-- WKSensors.srcs/sources1/new/
|   |-- MCP25625_SPI.vhdl
|
|-- WKSensors.srcs/sim_1/new
|   |-- MCP25625_SPI_TB.vhdl
|
