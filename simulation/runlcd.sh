#!/bin/sh

# Stop on first error (similar to IF ERRORLEVEL checks)
set -e

# Testbench filename (without extension)
TBNAME="testbenchV2_LCDlogic"

# Files in proper compilation order
FILES="../LCDpackV2.vhd ../L10Rom.vhd ../LCDlogic0.vhd"

# Simulation time
SIMTIME="20ms"

# GHDL flags
GHDL_FLAGS="-fsynopsys --std=08"

echo "Analyzing files..."
ghdl -a $GHDL_FLAGS $FILES ../${TBNAME}.vhd

echo "Elaborating testbench..."
ghdl -e $GHDL_FLAGS $TBNAME

echo "Running simulation..."
ghdl -r $GHDL_FLAGS $TBNAME --stop-time=$SIMTIME

echo "Done."
