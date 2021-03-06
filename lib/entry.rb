# -*- encoding : utf-8 -*-
module Entry

  def self.included(base)
    base.validates :amount, :numericality => {:only_integer => true, :allow_blank => true}
    base.validate :validate_amount_is_not_zero

    base.before_save :reject_if_empty
  end

  def copyable_attributes
    HashWithIndifferentAccess.new(attributes).slice(:account_id, :amount, :line_number, :summary)
  end

  def reversed_amount=(ra)
    # まずそのまま入れて、コンパ入りの場合のパーズと、before_type_cast の保存をする
    # これによりフォーマット不正の検証がそのまま動く
    self.amount = ra
    @reversed_amount_before_type_cast = amount_before_type_cast
    # 数値として意味があり、文字列でないか、正しい文字列である場合は符号逆転の値を入れ直す
    self.amount *= -1 if ra.to_i != 0 && (!ra.kind_of?(String) || ra =~ /^-?([0-9]|,)*$/)
    # 正しい値であった場合は、amount_before_type_cast は変化する
  end

  def reversed_amount
    self.amount.blank? ? self.amount : self.amount.to_i * -1
  end

  # 検証エラー時、フォーマット不正の状態を画面を残すため
  def reversed_amount_before_type_cast
    @reversed_amount_before_type_cast || reversed_amount
  end

  # 勘定ID、金額、摘要がいずれもない場合は空とみなす
  def empty?
    account_id.blank? && amount.blank? && summary.blank?
  end

  def debtor?
    !creditor?
  end

  def debtor_amount
    debtor? ? amount : nil
  end

  def creditor_amount
    creditor? ? (amount ? amount * -1 : nil) : nil
  end

  # attributes と内容が等しいかを調べる
  # デフォルト動作として、idだけ調べる
  def matched_with_attributes?(attributes)
    !id.to_s.blank? && attributes[:id].to_s == id.to_s
  end

  private

  def validate_amount_is_not_zero
    errors.add :amount, "に0を指定することはできません。" if amount && amount.to_i == 0 && errors[:amount].empty?
  end

  # 空の場合は例外を発生させる
  # 通常利用では発生しないことを想定しているため検証ではなく例外発生とする
  def reject_if_empty
    raise "Empty entry can't be saved! : #{self.inspect}" if empty?
  end

end
