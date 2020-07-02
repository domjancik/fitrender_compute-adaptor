#!/bin/sh

# Starts the FITRender Compute Adaptor bound to the 0.0.0.0 address so it is available from outside the VM.
# The port used is 9292

cd lib
bundle exec rackup -o 0.0.0.0
