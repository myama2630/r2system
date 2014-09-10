require "test_helper"

class UndoReturnTest < AcceptanceTest
  fixtures :users, :companies, :enginestatuses, :businessstatuses, :enginemodels,
           :engines, :repairs, :places

  test "拠点ユーザが登録した返却を取り消す" do
    # 1. 拠点ユーザが引合登録する
    sign_in "KT000001", "password"
    save_screenshot "UndoReturnTest1-01.png"
    click_link "流通情報一覧"
    save_screenshot "UndoReturnTest1-02.png"
    click_link "新規引合"
    save_screenshot "UndoReturnTest1-03.png"
    fill_in "物件名", with: "物件1"
    save_screenshot "UndoReturnTest1-04.png"
    select "エンジンモデル名1", from: "engineorder_old_engine_attributes_engine_model_name"
    save_screenshot "UndoReturnTest1-05.png"
    fill_in "engineorder_old_engine_attributes_serialno", with: "222"
    save_screenshot "UndoReturnTest1-06.png"
    click_button "引合登録"
    confirm
    save_screenshot "UndoReturnTest1-07.png"

    # 2. 拠点ユーザが受注登録する
    click_link "戻る"
    save_screenshot "UndoReturnTest1-08.png"
    click_link "受注"
    save_screenshot "UndoReturnTest1-09.png"
    click_button "受注登録"
    confirm
    save_screenshot "UndoReturnTest1-10.png"
    sign_out

    # 3. 本社ユーザが引当登録する
    sign_in "AA000001", "password"
    save_screenshot "UndoReturnTest1-11.png"
    click_link "流通情報一覧"
    save_screenshot "UndoReturnTest1-12.png"
    click_link "引当"
    save_screenshot "UndoReturnTest1-13.png"
    select "エンジンモデルコード1", from: "engineorder_new_engine_attributes_engine_model_name"
    save_screenshot "UndoReturnTest1-14.png"
    select "111", from: "engineorder_new_engine_attributes_serialno"
    save_screenshot "UndoReturnTest1-15.png"
    select "西宮戎リペア", from: "select_returning_place"
    save_screenshot "UndoReturnTest1-16.png"
    click_button "引当登録"
    confirm
    save_screenshot "UndoReturnTest1-17.png"
    sign_out

    # 4. 整備会社ユーザが出荷登録する
    sign_in "SG000001", "password"
    save_screenshot "UndoReturnTest1-18.png"
    click_link "整備会社作業一覧"
    save_screenshot "UndoReturnTest1-19.png"
    click_link "出荷"
    save_screenshot "UndoReturnTest1-20.png"
    fill_in "送り状No（新エンジン）", with: "111"
    save_screenshot "UndoReturnTest1-21.png"
    fill_in "出荷コメント", with: "111を出荷します"
    save_screenshot "UndoReturnTest1-22.png"
    click_button "出荷登録"
    confirm
    save_screenshot "UndoReturnTest1-23.png"
    sign_out

    # 5. 拠点ユーザが返却登録する
    sign_in "KT000001", "password"
    save_screenshot "UndoReturnTest1-24.png"
    click_link "流通情報一覧"
    save_screenshot "UndoReturnTest1-25.png"
    click_link "返却"
    save_screenshot "UndoReturnTest1-26.png"
    fill_in "送り状No（旧エンジン）", with: "222"
    save_screenshot "UndoReturnTest1-27.png"
    fill_in "返却コメント", with: "222を返却します"
    save_screenshot "UndoReturnTest1-28.png"
    click_button "返却登録"
    confirm
    save_screenshot "UndoReturnTest1-29.png"
    sign_out

    # 旧エンジンの管轄が整備会社に移ったことを確認
    assert_equal companies(:company2), Engine.find_by(serialno: "222").company

    # 6. 拠点ユーザが返却を取り消す
    sign_in "KT000001", "password"
    save_screenshot "UndoReturnTest1-30.png"
    click_link "流通情報一覧"
    save_screenshot "UndoReturnTest1-31.png"
    click_link "詳細"
    save_screenshot "UndoReturnTest1-32.png"
    click_link "返却の取り消し"
    confirm
    save_screenshot "UndoReturnTest1-33.png"
    sign_out

    # 旧エンジンの管轄が拠点に戻っていることを確認
    assert_equal companies(:company8), Engine.find_by(serialno: "222").company
  end
end
