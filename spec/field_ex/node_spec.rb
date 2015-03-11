require "spec_helper"

module FieldEx
  describe Node do

    describe "#<<(node)" do
      context "with node that already exists" do
        let(:parent) { Node.new {} }
        let(:first_node) { Node.new("users") }
        let(:second_node) { Node.new("users") }

        it "merges nodes into one" do
          parent << first_node
          expect( parent ).to have(1).children

          parent << second_node
          expect( parent ).to have(1).children
        end

      end
    end

    describe "#allowed_from(...)" do
      subject(:node) { Parser.new.parse(expression) }

      context "with no wildcard nodes" do
        let(:expression) { "a(a1),b,c,d" }

        specify "it returns the list of allowed fields" do
          expect( node.allowed_from(:b, :e, :a, :f, :g) ).to eql([:b, :a])
        end
      end

      context "with '*,!name,!_embedded'" do
        let(:expression) { "*,!name,!_embedded" }

        it "returns only keys that are not negated" do
          expect(
            node.allowed_from(:_links, :id, :createdAt, :name, :_embedded, :status)
          ).to eql([:_links, :id, :createdAt, :status])
        end
      end
    end

    describe "#has_path?(path)" do
      let(:nodes) { Parser.new.parse("_links,users(lastName),items(id),photos(thumbnail(url))") }

      it "returns true if path exists" do
        expect( nodes.has_path?("_links") ).to be true
        expect( nodes.has_path?("items.id") ).to be true
        expect( nodes.has_path?("photos.thumbnail.url") ).to be true
      end

      it "returns false if path doesn't exist" do
        expect( nodes.has_path?("_links.self") ).to be false
        expect( nodes.has_path?("items.url") ).to be false
      end
    end

    describe "#+(other)" do
      let(:node_one) { Parser.new.parse("users(firstName),items,photos(url)") }
      let(:node_two) { Parser.new.parse("_links,users(lastName),items(id),photos(url)") }

      subject(:combined) { node_one + node_two }

      it "merges the nodes" do
        expect( combined ).to be_kind_of(Node)
        expect( combined.has_path?("_links") ).to be true
        expect( combined.has_path?("users.firstName") ).to be true
        expect( combined.has_path?("users.lastName") ).to be true
        expect( combined.has_path?("items.id") ).to be true
        expect( combined.has_path?("photos.url") ).to be true

        # sanity check
        expect( combined.has_path?("users.middleName") ).to be false
      end

      it "collapsed child nodes with same names" do
        expect( combined.node_for("users") ).to have(2).children
      end
    end

  end
end
