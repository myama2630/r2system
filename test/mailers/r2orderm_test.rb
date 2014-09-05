require 'test_helper'

class R2ordermTest < ActionMailer::TestCase
  test "r2orderm" do
    mail = R2orderm.r2orderm
    assert_equal "R2orderm", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
