# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# マスタデータの id 値定数を参照するため。
require_relative "../config/initializers/constants"

# db/seeds.rb は、稼働用の仕込みデータを作成できます。
# データの作成は、ふつうに ActiveRecord の機能で行えます。
# アプリの初回セットアップ時に rake db:seed でデータを仕込みますが、念のため何
# 度も実行できるよう、データ作成前に既存データを削除しています。
# データの削除を delete_all で書いているので、取扱いにはご注意ください。。

# ビジネスステータスのマスターデータ
Businessstatus.delete_all
Businessstatus.create([
  {name: "引合",       id: Businessstatus::ID_INQUIRY},
  {name: "受注",       id: Businessstatus::ID_ORDERED},
  {name: "出荷準備中", id: Businessstatus::ID_SHIPPING_PREPARATION},
  {name: "出荷済",     id: Businessstatus::ID_SHIPPED},
  {name: "返却済",     id: Businessstatus::ID_RETURNED},
  {name: "キャンセル", id: Businessstatus::ID_CANCELED}
])

# エンジンステータスのマスターデータ
Enginestatus.delete_all
Enginestatus.create([
  {name: "受領前",     id: Enginestatus::ID_BEFORE_ARRIVE},
  {name: "整備前",     id: Enginestatus::ID_BEFORE_REPAIR},
  {name: "整備中",     id: Enginestatus::ID_UNDER_REPAIR},
  {name: "完成品",     id: Enginestatus::ID_FINISHED_REPAIR},
  {name: "出荷準備中", id: Enginestatus::ID_BEFORE_SHIPPING},
  {name: "出荷済",     id: Enginestatus::ID_AFTER_SHIPPING},
  {name: "返却予定",   id: Enginestatus::ID_ABOUT_TO_RETURN},
  {name: "廃却済",     id: Enginestatus::ID_ABOLISHED}
])


# 法人のデフォルト登録（削除して登録）
Company.delete_all

aa = Company.create(
  name: "YES本社", category: "YES本社",
  postcode: "531-0076", address: "大阪市大淀区大淀中5丁目",
  phone_no: "06-6451-7838", destination_name: "荒井様")

sg = Company.create(
  name: "ダミー整備会社", category: "整備会社",
  postcode: "123-4567", address: "兵庫県西宮市戎西町",
  phone_no: "00-000-0000", destination_name: "整備太郎様")

kt = Company.create(
  name: "ダミー拠点", category: "YES拠点",
  postcode: "234-5678", address: "名古屋市中区東新町",
  phone_no: "000-555-6666", destination_name: "拠点次郎様")


# エンジンの情報は空にする
Engine.delete_all


# 流通の情報は空にする
Engineorder.delete_all


# 整備の情報は空にする
Repair.delete_all


# ユーザーのデフォルト登録（削除して登録）
User.delete_all
User.create([
  {
    name: "YES本社担当者(ダミー)", company: aa,
    userid: "AA000001", email: "aa000001@test.org", password: "password"
  },
  {
    name: "YES拠点担当者(ダミー)", company: kt,
    userid: "KT000001", email: "kt000001@test.org", password: "password"
  },
  {
    name: "整備会社担当者(ダミー)", company: sg,
    userid: "SG000001", email: "sg000001@test.org", password: "password"
  }
])
