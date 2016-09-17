require 'test_helper'

class FormsMailerTest < ActionMailer::TestCase
  test "new_feedback" do
    mail = FormsMailer.new_feedback
    assert_equal "New feedback", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
