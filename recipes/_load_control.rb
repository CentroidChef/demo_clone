#
# Cookbook Name:: sjPOC
# Recipe:: _load_control
#
# Loads the control records from a databag item called control.  
# If that databag item does not exist will create from a csv file included in the cookbook's files.
# Copyright (c) 2018 Centroid, All Rights Reserved.

require 'csv'

# Attempt to load the control items from the control databag.  Note, if the databag doesn't exist
#   will report error to the console, but will be handled correctly.
control_items = begin
  data_bag('control')
  rescue Net::HTTPServerException, Chef::Exceptions::InvalidDataBagPath
  nil
end

if control_items
  puts "Control data bag is defined"
else
  puts "Control data bag is not defined, loading from csv file."

  # ensure that the staging directory exists
  directory node['control']['staging_dir'] do
    owner node['control']['owner']
    group node['control']['group']
    mode node['control']['mode']
    recursive true
    action :create
  end

  # verify that source file exists on the node and if not pull it from the cookbook
  cookbook_file "#{node['control']['staging_dir']}/#{node['control']['control_file']}" do
    source node['control']['control_file']
    owner node['control']['owner']
    group node['control']['group']
    mode node['control']['mode']
    action :create
  end

  puts "CSV file coped locally."

  # intitialize databag
  control_databag = Chef::DataBag.new
  control_databag.name('control')

  ruby_block 'load_data_bag' do
    block do
      # initialize the row counter 
      row_counter = 1

      # verify that the file exists and then loop through each CSV record populating the data bag's items
      if File.exist?("/stage/clone/#{node['control']['control_file']}")
        CSV.foreach("/stage/clone/#{node['control']['control_file']}", quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
          if row_counter == 1
            # if this is the first record, create the data bag
            control_databag.create
          end

          # populate the JSON data for each item
          control_data = {
            'id' => row_counter.to_s,
            'Server' => row['Server'],
            'Step' => row['Step'],
            'ExecutionStart' => row['ExecutionStart'],
            'ExecutionEnd' => row['ExecutionEnd'],
            'Success' => row['Success']
            }

          # create data bag item and set its data
          control_item = Chef::DataBagItem.new
          control_item.data_bag('control')
          control_item.raw_data = control_data
          control_item.save

          # increment row counter
          row_counter += 1
        end
      else
        puts "Control file doesn't exist"
      end
    end
    action :run
  end
 
end
