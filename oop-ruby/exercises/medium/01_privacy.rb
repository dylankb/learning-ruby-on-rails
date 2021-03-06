class Machine

  def start
    flip_switch(:on)
  end

  def stop
    flip_switch(:off)
  end

  def settings
    switch
  end

  private

  attr_accessor :switch

  def flip_switch(desired_state)
    self.switch = desired_state
  end

end

puts Machine.new().flip_switch(:on)  # fails

zorb.start
zorb.settings # > :on
