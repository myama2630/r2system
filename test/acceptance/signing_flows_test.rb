# coding: utf-8

require 'test_helper'

class SigningFlowsTest < AcceptanceTest
  fixtures :users, :companies

  # [正常系] 妥当なユーザ情報を入力してサインアップ -> サインアウト
  # users テーブルにレコードを追加して、メニュー画面に遷移することを確認
  test "sign up with valid user information and then sign out" do
    visit_root
    click_link "サインアップ"

    assert_difference "User.count" do
      fill_in "ログインＩＤ", with: "YA900001"
      fill_in "氏名", with: "てすと花子"
      fill_in "Ｅメール", with: "YA900001@test.org"
      fill_in "パスワード", with: "passpass"
      fill_in "パスワード（確認）", with: "passpass"
      select "法華倶楽部", from: "user_company_id"
      click_button "サインアップ"
      assert_equal root_path, current_path
    end

    new_user = User.find_by_userid("YA900001")
    assert_not_nil new_user
    assert_equal "てすと花子", new_user.name
    assert_not_nil new_user.last_sign_in_at

    sign_out
  end

  # [異常系] ユーザ ID を入力しないでサインアップ
  # users テーブルに変化が無いことを確認
  test "try to sign up without userid" do
    visit_root
    click_link "サインアップ"

    assert_no_difference "User.count" do
      fill_in "ログインＩＤ", with: "" # A userid must not be empty
      fill_in "氏名", with: "てすと花子"
      fill_in "Ｅメール", with: "YA900001@test.org"
      fill_in "パスワード", with: "passpass"
      fill_in "パスワード（確認）", with: "passpass"
      select "法華倶楽部", from: "user_company_id"
      click_button "サインアップ"
      assert_equal user_registration_path, current_path
    end
  end

  # [異常系] 他のユーザと同じユーザ ID を入力してサインアップ
  # users テーブルに変化が無いことを確認
  test "try to sign up with userid same as one of existing user" do
    visit_root
    click_link "サインアップ"

    assert_no_difference "User.count" do
      fill_in "ログインＩＤ", with: "YA000001" # A userid must be unique
      fill_in "氏名", with: "てすと花子"
      fill_in "Ｅメール", with: "YA900001@test.org"
      fill_in "パスワード", with: "passpass"
      fill_in "パスワード（確認）", with: "passpass"
      select "法華倶楽部", from: "user_company_id"
      click_button "サインアップ"
      assert_equal user_registration_path, current_path
    end
  end

  # [異常系] フォーマットが妥当ではないユーザ ID を入力してサインアップ
  # users テーブルに変化が無いことを確認
  test "try to sign up with ill-formed userid" do
    visit_root
    click_link "サインアップ"

    assert_no_difference "User.count" do
      # A userid must match with /[a-z]{2}[0-9]{6}/i
      fill_in "ログインＩＤ", with: "900001"
      fill_in "氏名", with: "てすと花子"
      fill_in "Ｅメール", with: "YA900001@test.org"
      fill_in "パスワード", with: "passpass"
      fill_in "パスワード（確認）", with: "passpass"
      select "法華倶楽部", from: "user_company_id"
      click_button "サインアップ"
      assert_equal user_registration_path, current_path
    end
  end

  # [異常系] ユーザ名を入力しないでサインアップ
  # users テーブルに変化が無いことを確認
  test "try to sign up without name" do
    visit_root
    click_link "サインアップ"

    assert_no_difference "User.count" do
      fill_in "ログインＩＤ", with: "YA900001"
      fill_in "氏名", with: "" # A name must not be empty
      fill_in "Ｅメール", with: "YA900001@test.org"
      fill_in "パスワード", with: "passpass"
      fill_in "パスワード（確認）", with: "passpass"
      select "法華倶楽部", from: "user_company_id"
      click_button "サインアップ"
      assert_equal user_registration_path, current_path
    end
  end



  # [異常系] 正しくないログインＩＤ（日本語）でサインアップしようとする
  # users テーブルに変化が無いことを確認
  test "try to sign up wrong loginID" do
    visit_root
    click_link "サインアップ"

    assert_no_difference "User.count" do
      fill_in "ログインＩＤ", with: "てすと花子"
      fill_in "氏名", with: "てすと花子" 
      fill_in "Ｅメール", with: "YA900001@test.org"
      fill_in "パスワード", with: "passpass"
      fill_in "パスワード（確認）", with: "passpass"
      select "法華倶楽部", from: "user_company_id"
      click_button "サインアップ"
      assert_equal user_registration_path, current_path
    end
  end

  # [正常系] サインアップ済みのユーザ ID でサインイン -> サインアウト
  # 正常にサインインし、メニュー画面に遷移、サインアウトリンク押下により正常に
  # サインアウトすることを確認
  test "sign in as existing user and then sign out" do
    visit_root

    fill_in "ログインＩＤ", with: users(:test_tarou).userid
    fill_in "パスワード", with: "test0001"
    click_button "ログイン"
    assert_equal root_path, current_path
    sign_out
  end

  # [異常系] サインアップしていないユーザ ID でサインイン
  # サインインせずに、サインイン画面に留まることを確認
  test "try to sign in with unknown userid" do
    visit_root

    fill_in "ログインＩＤ", with: "YA999999"
    fill_in "パスワード", with: "passpass"
    click_button "ログイン"
    assert_equal new_user_session_path, current_path
  end
end
