#!/bin/sh

# Starts the FITRender Compute Adaptor normally so it is available only inside the VM on localhost
# The port used is 9292

cd lib
bundle exec rackup
