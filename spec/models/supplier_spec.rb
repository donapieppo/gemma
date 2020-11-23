require 'rails_helper'

describe Supplier do

  before(:each) do
    @ok = { name: 'supplier di prova', 
            pi:   '12121212121' }
  end

  it "should not create a valid supplier without :name or :pi" do
    expect(Supplier.new(@ok.merge({name: nil}))).not_to be_valid
    expect(Supplier.new(@ok.merge({pi: nil}))).not_to be_valid
  end

  it "should not create supplier if pi is invalid" do
    expect(Supplier.new(@ok.merge({pi: '1212121212'}))).not_to be_valid
    expect(Supplier.new(@ok.merge({pi: '121212121233'}))).not_to be_valid
  end

  it "should create a valid supplier" do
    supplier = Supplier.new(@ok)
    expect(supplier.save).to be
  end

  it "should not create supplier if pi is already there" do
    supplier = Supplier.new(@ok)
    expect(supplier.save).to be
    supplier = Supplier.new(@ok.merge({pi: '12121212121'}))
    expect(supplier.save).not_to be
    expect(supplier.errors["pi"].first).to match(/stessa partita iva/)
  end

end

