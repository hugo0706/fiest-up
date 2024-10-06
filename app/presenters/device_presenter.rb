# frozen_string_literal: true

class DevicePresenter
  attr_reader :device

  def initialize(device)
    @device = device
  end

  def icon
    case device["type"]
    when 'Computer'
      '🖵'
    when 'Smartphone'
      '📱' 
    else
      '🕪'
    end
  end
  
  def name
    device["name"]
  end
  
  def id
    device["id"]
  end
  
  def is_active
    device["is_active"]
  end
  
  def type
    device["type"]
  end
end
