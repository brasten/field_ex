require "spec_helper"

describe FieldEx::Extractor do

  it "should work on object" do
    extractor = FieldEx::Extractor.new("name(first,last)")
    res = extractor.on({ name: { first: "Lisa", middle: "Nice", last: "Karr" }})

    expect(res).to eq({ name: { first: "Lisa", last: "Karr" }})
  end

  it "should work on array" do
    extractor = FieldEx::Extractor.new("users(firstName,lastName)")
    res = extractor.on({
      users: [
        {firstName: "Lisa", lastName: "Karr", someData: "Some Value", somethingElse: "Yo"},
        {firstName: "Xavier", lastName: "Self", someData: "Some Value", somethingElse: "Yo"},
        {lastName: "Onlylast", someData: "Some Value", somethingElse: "Yo"}
      ]
    })

    expect(res).to eq({
      users: [
        {firstName: "Lisa", lastName: "Karr"},
        {firstName: "Xavier", lastName: "Self"},
        {lastName: "Onlylast"}
      ]
    })
  end
end
