#
# Cookbook Name:: sjPOC
# Attributes:: default
#
# Copyright (c) 2018 Centroid, All Rights Reserved.

# General control settings
default[:control][:staging_dir] = '/stage/clone'
default[:control][:owner] = 'root'
default[:control][:group] = 'root'
default[:control][:mode] = '0755'
default[:control][:control_file] = 'control.csv'