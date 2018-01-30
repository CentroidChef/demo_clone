#
# Cookbook Name:: sjPOC
# Library:: control
#
# Contains the class structure definition for a control object
# Copyright (c) 2018 Centroid, All Rights Reserved.

# Build the control class structure, initilize method, and properties
class ControlData
  def initialize(server, step, executionStart, executionEnd, success)
    @server = server
    @step = step
    @executionStart = executionStart
    @executionEnd = executionEnd
    @success = success
  end

  def display 
    puts "Executed on Server : #{@server}"
    puts "Step : #{@step}"
    puts "Execution start time : #{@executionStart}"
    puts "Execution end time : #{@executionEnd}"
    puts "Success : #{@success}"
  end

  def server
    @server
  end

  def step
    @step
  end

  def executionStart 
    @executionStart
  end

  def executionEnd
    @executionEnd
  end

  def success
    @success
  end
end