require 'rails_helper'

describe Load do

  before(:each) do
    @num     = [ 40, 20 ] # numero casuale :-)

    @now      = GEMMA_TEST_NOW
    @thing    = FactoryBot.create(:thing, :with_deposits, number_of_deposits: 3)
    @ddt      = FactoryBot.create(:ddt, :organization => @thing.organization, :date => @now - 1.day)
    @deposits = @thing.deposits
    @total    = @thing.total

    @user      = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)

    @ok = { :organization_id => @thing.organization.id,
            :numbers   => { @deposits[0].id => @num[0], @deposits[1].id => @num[1] },
            :thing_id  => @thing.id,
            :user_id   => @user.id,
            :recipient => nil, 
            :date      => @now, 
            :ddt_id    => @ddt.id }
  end

  it "should create a valid load on 2 deposit's thing and actual and total should be correct" do
    load = Load.new(@ok)
    expect(load.save).to be

    # il numero nell'operation deve essere la somma
    expect(load.number).to eq(@num[0] + @num[1])
    @deposits.each do |dep|
      @ok[:numbers][dep.id] or next
      expect(Deposit.find(dep.id).actual).to eq(dep.actual + @ok[:numbers][dep.id])
    end
    expect(@thing.reload.total).to eq(@num[0] + @num[1])
  end

  it "should create a valid load on 2 deposit's thing, destroy it and actual and total should be correct" do
    load = Load.new(@ok)
    expect(load.save).to be
    expect(load.destroy).to be

    @deposits.each do |dep|
      expect(Deposit.find(dep.id).actual).to eq(dep.actual)
    end
    expect(@thing.reload.total).to eq(@total)
  end

  it "should be possible to modify numbers and locatons" do
    load = Load.new(@ok)
    expect(load.save).to be
    # lo tengo tanto per sicurezza anche se non dovrebbe cambiare 
    load_id = load.id 

    # modifico uno in numero e l'altro anche in location
    expect(load.aggiorna({numbers: { @deposits[0].id => 111, @deposits[2].id => 224 }})).to be

    # verifico!
    expect(Move.where(:operation_id => load_id).where(:deposit_id => @deposits[0].id).first.number).to eq(111)
    expect(Move.where(:operation_id => load_id).where(:deposit_id => @deposits[1].id).count).to eq(0 )
    expect(Move.where(:operation_id => load_id).where(:deposit_id => @deposits[2].id).first.number).to eq(224)
  end

end

