class TestController < ActionController::Base
  def user_for_object_diff_trail
    Thread.current.object_id
  end
end
