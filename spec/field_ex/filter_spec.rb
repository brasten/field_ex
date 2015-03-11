require "spec_helper"

module FieldEx
  describe Filter do
    let(:nested_data) do
      {
        users: [
          {
            id: "1",
            name: {
              first: "Lisa",
              middle: "Nice",
              last: "Karr"
            }
          },
          {
            id: "2",
            name: {
              first: "Xavier",
              last: "Self"
            }
          },
          {
            id: "3",
            name: {
              first: "Brasten",
              middle: "Lee",
              last: "Sager"
            }
          },
          {
            id: "4",
            name: {
              last: "Justlast"
            }
          }
        ],
        items: [
          { name: "item-1" },
          { name: "item-2" },
          { name: "item-3" }
        ],
        somethingElse: {
          none: "of",
          this: "should",
          get: 2,
          the: "final output."
        }
      }
    end

    subject(:result) {
      Filter.new( Parser.new.parse(query) ).on(nested_data)
    }

    context "with 'users(name(first,last)),items,photos(url)'" do
      let(:query) { "users(name(first,last)),items,photos(url)" }

      it "filters" do
        expect(result).to eq({
          users: [
            {
              name: {
                first: "Lisa",
                last: "Karr"
              }
            },
            {
              name: {
                first: "Xavier",
                last: "Self"
              }
            },
            {
              name: {
                first: "Brasten",
                last: "Sager"
              }
            },
            {
              name: {
                last: "Justlast"
              }
            }
          ],
          items: [
            { name: "item-1" },
            { name: "item-2" },
            { name: "item-3" }
          ]
        })
      end
    end

    context "with 'users(*,name(first,last)),items,photos(url)'" do
      let(:query) { "users(*,name(first,last)),items,photos(url)" }

      it "filters" do
        expect(result).to eq({
          users: [
            {
              id: "1",
              name: {
                first: "Lisa",
                last: "Karr"
              }
            },
            {
              id: "2",
              name: {
                first: "Xavier",
                last: "Self"
              }
            },
            {
              id: "3",
              name: {
                first: "Brasten",
                last: "Sager"
              }
            },
            {
              id: "4",
              name: {
                last: "Justlast"
              }
            }
          ],
          items: [
            { name: "item-1" },
            { name: "item-2" },
            { name: "item-3" }
          ]
        })
      end
    end

    context "with 'users(*,!name)'" do
      let(:query) { "users(*,!name)" }

      it "filters" do
        expect(result).to eq({
          users: [
            {
              id: "1",
            },
            {
              id: "2",
            },
            {
              id: "3",
            },
            {
              id: "4",
            }
          ]
        })
      end
    end

    context "with 'users(*,!name,name)'" do
      let(:query) { "users(*,!name,name)" }

      it "filters" do
        expect(result).to eq({
          users: [
            {
              id: "1",
              name: {
                first: "Lisa",
                middle: "Nice",
                last: "Karr"
              }
            },
            {
              id: "2",
              name: {
                first: "Xavier",
                last: "Self"
              }
            },
            {
              id: "3",
              name: {
                first: "Brasten",
                middle: "Lee",
                last: "Sager"
              }
            },
            {
              id: "4",
              name: {
                last: "Justlast"
              }
            }
          ]
        })
      end
    end

    context "with 'users(* , name(first,last)),items,photos(url)'" do
      let(:query) { "users(* , name(first,last)),items,photos(url)" }

      it "filters out whitespace" do
        expect(result).to eq({
          users: [
            {
              id: "1",
              name: {
                first: "Lisa",
                last: "Karr"
              }
            },
            {
              id: "2",
              name: {
                first: "Xavier",
                last: "Self"
              }
            },
            {
              id: "3",
              name: {
                first: "Brasten",
                last: "Sager"
              }
            },
            {
              id: "4",
              name: {
                last: "Justlast"
              }
            }
          ],
          items: [
            { name: "item-1" },
            { name: "item-2" },
            { name: "item-3" }
          ]
        })
      end
    end

  end
end
