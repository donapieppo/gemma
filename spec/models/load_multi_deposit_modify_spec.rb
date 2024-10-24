require "rails_helper"

describe Load do
  before(:each) do
    @num = [40, 20] # numero casuale :-)
    @now = GEMMA_TEST_NOW
    @load = FactoryBot.create(:load, number_in_deposits: @num)
    @thing = @load.thing
    @deposits = @thing.deposits
  end

  it "should be possible to change load number so that unload becomes 0" do
    unload = FactoryBot.create(:unload, numbers: {@deposits[1].id => 1 - @num[1]}, thing: @thing, date: @now + 5.days)
    expect(@load.aggiorna(numbers: {@deposits[0].id => @num[0], @deposits[1].id => @num[1] - 1})).to be
    expect(@deposits[1].reload.actual).to eq 0
    expect(@deposits[0].reload.actual).to eq @num[0]
  end

  it "should not be possible to change load date so that one deposit actual becomes negative" do
    unload = FactoryBot.create(:unload, numbers: {@deposits[1].id => 1 - @num[1]}, thing: @thing, date: @now)
    expect { @load.aggiorna(date: @now + 1.day) }.to raise_error(Gemma::NegativeDeposit)
    expect(@load.reload.date).to eq @now.change(hour: 0, min: 0)
  end

  it "should not be possible to change load number so that unload becomes negative" do
    # ne resta uno
    unload = FactoryBot.create(:unload, numbers: {@deposits[1].id => 1 - @num[1]}, thing: @thing, date: @now + 5.days)
    expect { @load.aggiorna(numbers: {@deposits[0].id => @num[0], @deposits[1].id => @num[1] - 3}) }.to raise_error(Gemma::NegativeDeposit)
    expect(@deposits[1].reload.actual).to eq 1
    expect(@deposits[0].reload.actual).to eq @num[0]
  end
end
