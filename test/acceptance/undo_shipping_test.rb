require "test_helper"

class UndoShippingTest < AcceptanceTest
  fixtures :users, :companies, :enginestatuses, :businessstatuses, :enginemodels,
           :engines, :repairs, :places

  test "整備会社ユーザが登録した出荷をすぐに取り消す" do
    # 出荷登録後、エンジンの管轄が拠点に移ると、整備会社作業一覧には表示されな
    # くなる。
    # したがって、整備会社ユーザは、出荷登録後の結果画面からしか出荷取り消しが
    # できない。
    # これは、仕様として大丈夫？

    # 1. 拠点ユーザが引合登録する
    sign_in "KT000001", "password"
    save_screenshot "UndoShippingTest1-01.png"
    click_link "流通情報一覧"
    save_screenshot "UndoShippingTest1-02.png"
    click_link "新規引合"
    save_screenshot "UndoShippingTest1-03.png"
    fill_in "物件名", with: "物件1"
    save_screenshot "UndoShippingTest1-04.png"
    select "エンジンモデル名1", from: "engineorder_old_engine_attributes_engine_model_name"
    save_screenshot "UndoShippingTest1-05.png"
    fill_in "engineorder_old_engine_attributes_serialno", with: "222"
    save_screenshot "UndoShippingTest1-06.png"
    click_button "引合登録"
    confirm
    save_screenshot "UndoShippingTest1-07.png"

    # 2. 拠点ユーザが受注登録する
    click_link "戻る"
    save_screenshot "UndoShippingTest1-08.png"
    click_link "受注"
    save_screenshot "UndoShippingTest1-09.png"
    click_button "受注登録"
    confirm
    save_screenshot "UndoShippingTest1-10.png"
    sign_out

    # 3. 本社ユーザが引当登録する
    sign_in "AA000001", "password"
    save_screenshot "UndoShippingTest1-11.png"
    click_link "流通情報一覧"
    save_screenshot "UndoShippingTest1-12.png"
    click_link "引当"
    save_screenshot "UndoShippingTest1-13.png"
    select "エンジンモデルコード1", from: "engineorder_new_engine_attributes_engine_model_name"
    save_screenshot "UndoShippingTest1-14.png"
    select "111", from: "engineorder_new_engine_attributes_serialno"
    save_screenshot "UndoShippingTest1-15.png"
    select "西宮戎リペア", from: "select_returning_place"
    save_screenshot "UndoShippingTest1-16.png"
    click_button "引当登録"
    confirm
    save_screenshot "UndoShippingTest1-17.png"
    sign_out

    # 4. 整備会社ユーザが出荷登録する
    sign_in "SG000001", "password"
    save_screenshot "UndoShippingTest1-18.png"
    click_link "整備会社作業一覧"
    save_screenshot "UndoShippingTest1-19.png"
    click_link "出荷"
    save_screenshot "UndoShippingTest1-20.png"
    fill_in "送り状No（新エンジン）", with: "111"
    save_screenshot "UndoShippingTest1-21.png"
    fill_in "出荷コメント", with: "111を出荷します"
    save_screenshot "UndoShippingTest1-22.png"
    click_button "出荷登録"
    confirm
    save_screenshot "UndoShippingTest1-23.png"

    # 新エンジンの管轄が拠点に移ったことを確認
    assert_equal companies(:company8), Engine.find_by(serialno: "111").company

    # 5. 整備会社ユーザがすぐに出荷を取り消す
    click_link "出荷の取り消し"
    confirm
    save_screenshot "UndoShippingTest1-24.png"
    sign_out

    # 新エンジンの管轄が整備会社に戻っていることを確認
    assert_equal companies(:company2), Engine.find_by(serialno: "111").company
  end

  test "整備会社ユーザが登録した出荷を拠点ユーザが取り消す" do
    # 1. 拠点ユーザが引合登録する
    sign_in "KT000001", "password"
    save_screenshot "UndoShippingTest2-01.png"
    click_link "流通情報一覧"
    save_screenshot "UndoShippingTest2-02.png"
    click_link "新規引合"
    save_screenshot "UndoShippingTest2-03.png"
    fill_in "物件名", with: "物件1"
    save_screenshot "UndoShippingTest2-04.png"
    select "エンジンモデル名1", from: "engineorder_old_engine_attributes_engine_model_name"
    save_screenshot "UndoShippingTest2-05.png"
    fill_in "engineorder_old_engine_attributes_serialno", with: "222"
    save_screenshot "UndoShippingTest2-06.png"
    click_button "引合登録"
    confirm
    save_screenshot "UndoShippingTest2-07.png"

    # 2. 拠点ユーザが受注登録する
    click_link "戻る"
    save_screenshot "UndoShippingTest2-08.png"
    click_link "受注"
    save_screenshot "UndoShippingTest2-09.png"
    click_button "受注登録"
    confirm
    save_screenshot "UndoShippingTest2-10.png"
    sign_out

    # 3. 本社ユーザが引当登録する
    sign_in "AA000001", "password"
    save_screenshot "UndoShippingTest2-11.png"
    click_link "流通情報一覧"
    save_screenshot "UndoShippingTest2-12.png"
    click_link "引当"
    save_screenshot "UndoShippingTest2-13.png"
    select "エンジンモデルコード1", from: "engineorder_new_engine_attributes_engine_model_name"
    save_screenshot "UndoShippingTest2-14.png"
    select "111", from: "engineorder_new_engine_attributes_serialno"
    save_screenshot "UndoShippingTest2-15.png"
    select "西宮戎リペア", from: "select_returning_place"
    save_screenshot "UndoShippingTest2-16.png"
    click_button "引当登録"
    confirm
    save_screenshot "UndoShippingTest2-17.png"
    sign_out

    # 4. 整備会社ユーザが出荷登録する
    sign_in "SG000001", "password"
    save_screenshot "UndoShippingTest2-18.png"
    click_link "整備会社作業一覧"
    save_screenshot "UndoShippingTest2-19.png"
    click_link "出荷"
    save_screenshot "UndoShippingTest2-20.png"
    fill_in "送り状No（新エンジン）", with: "111"
    save_screenshot "UndoShippingTest2-21.png"
    fill_in "出荷コメント", with: "111を出荷します"
    save_screenshot "UndoShippingTest2-22.png"
    click_button "出荷登録"
    confirm
    save_screenshot "UndoShippingTest2-23.png"
    sign_out

    # 新エンジンの管轄が拠点に移ったことを確認
    assert_equal companies(:company8), Engine.find_by(serialno: "111").company

    # 5. 拠点ユーザが出荷を取り消す
    sign_in "KT000001", "password"
    save_screenshot "UndoShippingTest2-24.png"
    click_link "流通情報一覧"
    save_screenshot "UndoShippingTest2-25.png"
    click_link "詳細"
    save_screenshot "UndoShippingTest2-26.png"
    click_link "出荷の取り消し"
    confirm
    save_screenshot "UndoShippingTest2-27.png"
    sign_out

    # 新エンジンの管轄が整備会社に戻っていることを確認
    assert_equal companies(:company2), Engine.find_by(serialno: "111").company
  end
end
