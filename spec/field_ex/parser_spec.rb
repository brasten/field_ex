require "spec_helper"

describe FieldEx::Parser do

  it "should parse things up" do
    parser = FieldEx::Parser.new
    nodes = parser.parse("users(firstName,lastName),items,photos(url)")

    first_level = nodes.children
    users_children = nodes.children[0].children
    items_children = nodes.children[1].children
    photos_children = nodes.children[2].children

    expect( first_level.size ).to eq 3
    expect( users_children.size ).to eq 2
    expect( items_children.size ).to eq 0
    expect( photos_children.size ).to eq 1
  end

  it "should parse wildcards" do
    parser = FieldEx::Parser.new
    nodes = parser.parse("users(*,name(first,last)),items,photos(url)")

    first_level = nodes.children
    users_children = nodes.children[0].children
    items_children = nodes.children[1].children
    photos_children = nodes.children[2].children

    expect( first_level.size ).to eq 3
    expect( users_children.size ).to eq 3
    expect( items_children.size ).to eq 0
    expect( photos_children.size ).to eq 1
  end


end
