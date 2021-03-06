# -*- encoding : utf-8 -*-
class Preferences < ActiveRecord::Base
  self.table_name = "preferences"
  belongs_to :user

  after_save :capital_to_credit
#  validates_uniqueness_of :user_id
  
#  def self.get(user_id)
#    return find(:first, :conditions => ["user_id = ?", user_id]) || Preferences.new(:user_id => user_id)
#  end

  private
  
  # セーブ後、事業利用フラグがオフの場合は特殊な処置をする
  def capital_to_credit
    unless self.business_use?
      # 資本金タイプの口座はすべて債権タイプに変更する
      Account::Base.update_all("asset_kind = 'credit'", "asset_kind = 'capital_fund'")
    end
  end
  
end