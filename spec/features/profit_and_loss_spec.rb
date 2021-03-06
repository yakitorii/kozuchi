# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ProfitAndLossController do
  fixtures :users, :accounts, :preferences
  set_fixture_class  :accounts => Account::Base

  include_context "太郎 logged in"

  before do
    visit 'profit_and_loss'
  end

  describe "メニュー「収支表」のクリック" do
    it "今月の収支表が表示される" do
      page.should have_content("#{Date.today.year}年#{Date.today.month}月末日の収支表")
    end
  end

end