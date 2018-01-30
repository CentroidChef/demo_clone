#
# Cookbook Name:: demo_clone
# Recipe:: default
#
# Copyright (c) 2018 Centroid, All Rights Reserved.

# include recipe to load the control information
include_recipe 'demo_clone::_load_control'

ruby_block 'iterate_control_items' do
    block do
  
      # control data bag should exist at this point
      control_items = data_bag('control')
  
      # initialize the previous data bag item and status
      previous_item = nil
      previous_status = nil
  
      # loop through each control item 
      control_items.each do |id|
  
        # load the control item from the data bag item
        control_item = data_bag_item('control',id)
  
        puts "Control Item #{control_item['id']} ; Server : #{control_item['Server']}; Node Host Name : #{node['hostname']} Step : #{control_item['Step']}; Success : #{control_item['Success']}"
  
        # if its the not the first iteration set the previous status to the last iteration's status
        unless previous_item == nil
          previous_status = previous_item.success
        end
  
        # if the control item's server is the server we're running and it hasnt' been started
        if control_item['Server'] == node['hostname'] && control_item['ExecutionStart'] == nil
          # if this is the first iteration or the previous item has successfully concluded (status == 1) then execute the current step
          if previous_item == nil || previous_status == '1'
            # set the execution start time to the current time stamp and save data bag item
            control_item['ExecutionStart'] = Time.now.getutc
            control_item.save
  
            # execute current step (named to match recipes)
            run_context.include_recipe "demo_clone::#{control_item['Step']}"
  
            # set the execution end time to the current time stamp, set success to 1, and save data bag item
            control_item['ExecutionEnd'] = Time.now.getutc
            control_item['Success'] = '1'
            control_item.save
          end
        end
  
        previous_item = ControlData.new(control_item['Server'], control_item['Step'], control_item['executionStart'], control_item['executionEnd'], control_item['Success'])
      end
  
      puts 'End : Clone'
  
    end
    action :run
  end