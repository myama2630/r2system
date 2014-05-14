require "test_helper"

class RegisterInquiryTest < AcceptanceTest
  fixtures :users, :companies, :enginestatuses, :businessstatuses, :enginemodels

  test "拠点ユーザが引合を新規登録する (正常系)" do
    # 1. 拠点ユーザがサインインする
    sign_in "KT000001", "password"
    save_screenshot "RegisterInquiryTest1-01.png"
    # 2. 流通情報一覧画面を開く
    click_link "流通情報一覧"
    save_screenshot "RegisterInquiryTest1-02.png"
    # 3. 引合登録画面を開く
    click_link "新規引合"
    save_screenshot "RegisterInquiryTest1-03.png"
    # 4. 物件名を入力する
    fill_in "物件名", with: "物件1"
    save_screenshot "RegisterInquiryTest1-04.png"
    # 5. 返却エンジンの型式を選択する
    select "エンジンモデル名2", from: "engineorder_old_engine_attributes_engine_model_name"
    save_screenshot "RegisterInquiryTest1-05.png"
    # 6. 返却エンジンのシリアルNo.を入力する
    fill_in "engineorder_old_engine_attributes_serialno", with: "001"
    save_screenshot "RegisterInquiryTest1-06.png"
    # 7. 引合を登録する
    click_button "引合登録"
    confirm
    within "body>div.container" do
      assert_match /物件1/, find("div.field:nth-child(3)").text
      assert_match /引合/, find("div.field:nth-child(4)").text
      assert_match /YES名古屋営業/, find("div.field:nth-child(7)").text
      assert_match /エンジンモデルコード2 \( 001 \)/, find("div.field:nth-child(27)").text
    end
    save_screenshot "RegisterInquiryTest1-07.png"
    # 8. 拠点ユーザがサインアウトする
    sign_out
    save_screenshot "RegisterInquiryTest1-08.png"
  end

  test "拠点ユーザが引合を新規登録する (返却エンジンのエンジンNo.入力なし)" do
    # 1. 拠点ユーザがサインインする
    sign_in "KT000001", "password"
    save_screenshot "RegisterInquiryTest2-01.png"
    # 2. 流通情報一覧画面を開く
    click_link "流通情報一覧"
    save_screenshot "RegisterInquiryTest2-02.png"
    # 3. 引合登録画面を開く
    click_link "新規引合"
    save_screenshot "RegisterInquiryTest2-03.png"
    # 4. 物件名を入力する
    fill_in "物件名", with: "物件1"
    save_screenshot "RegisterInquiryTest2-04.png"
    # 5. 返却エンジンの型式を選択する
    select "エンジンモデル名2", from: "engineorder_old_engine_attributes_engine_model_name"
    save_screenshot "RegisterInquiryTest2-05.png"
    # 6. 返却エンジンのシリアルNo.を入力*しない*
    # 7. 引合を登録しようとするが失敗する
    assert_no_difference "Engineorder.count" do
      click_button "引合登録"
      confirm
      save_screenshot "RegisterInquiryTest2-07.png"
    end
    # 8. 拠点ユーザがサインアウトする
    sign_out
    save_screenshot "RegisterInquiryTest2-08.png"
  end

  test "拠点ユーザが引合を新規登録する (返却エンジンのエンジン型式選択なし)" do
    # 1. 拠点ユーザがサインインする
    sign_in "KT000001", "password"
    save_screenshot "RegisterInquiryTest3-01.png"
    # 2. 流通情報一覧画面を開く
    click_link "流通情報一覧"
    save_screenshot "RegisterInquiryTest3-02.png"
    # 3. 引合登録画面を開く
    click_link "新規引合"
    save_screenshot "RegisterInquiryTest3-03.png"
    # 4. 物件名を入力する
    fill_in "物件名", with: "物件1"
    save_screenshot "RegisterInquiryTest3-04.png"
    # 5. 返却エンジンの型式を選択*しない*
    # 6. 返却エンジンのシリアルNo.を入力*しない*
    fill_in "engineorder_old_engine_attributes_serialno", with: "001"
    save_screenshot "RegisterInquiryTest3-06.png"
    # 7. 引合を登録しようとするが失敗する
    assert_no_difference "Engineorder.count" do
      click_button "引合登録"
      confirm
      save_screenshot "RegisterInquiryTest3-07.png"
    end
    # 8. 拠点ユーザがサインアウトする
    sign_out
    save_screenshot "RegisterInquiryTest3-08.png"
  end
end
