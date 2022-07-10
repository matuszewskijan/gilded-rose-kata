require 'simplecov'
SimpleCov.start

require_relative '../gilded_rose'

describe GildedRose do
  describe "#update_quality" do
    it "does not change the name" do
      items = [Item.new("foo", 0, 0)]
      GildedRose.new(items).update_quality()
      expect(items[0].name).to eq "foo"
    end

    it 'creates report lines' do
      report_lines = []
      items = [
        Item.new(name="+5 Dexterity Vest", sell_in=10, quality=20),
        Item.new(name="Aged Brie", sell_in=2, quality=0),
        Item.new(name="Elixir of the Mongoose", sell_in=5, quality=7),
        Item.new(name="Sulfuras, Hand of Ragnaros", sell_in=0, quality=80),
        Item.new(name="Sulfuras, Hand of Ragnaros", sell_in=-1, quality=80),
        Item.new(name="Backstage passes to a TAFKAL80ETC concert", sell_in=15, quality=20),
        Item.new(name="Backstage passes to a TAFKAL80ETC concert", sell_in=10, quality=49),
        Item.new(name="Backstage passes to a TAFKAL80ETC concert", sell_in=5, quality=49),
        # This Conjured item does not work properly yet
        Item.new(name="Conjured Mana Cake", sell_in=3, quality=6), # <-- :O
      ]

      days = 2

      gilded_rose = GildedRose.new items
      (0...days).each do |day|
        report_lines << "-------- day #{day} --------"
        report_lines << "name, sellIn, quality"
        items.each do |item|
          report_lines << item.to_s
        end
        report_lines << ""
        gilded_rose.update_quality
      end

      expected_report_lines = [
        "-------- day 0 --------", "name, sellIn, quality", "+5 Dexterity Vest, 10, 20",
        "Aged Brie, 2, 0", "Elixir of the Mongoose, 5, 7","Sulfuras, Hand of Ragnaros, 0, 80",
        "Sulfuras, Hand of Ragnaros, -1, 80", "Backstage passes to a TAFKAL80ETC concert, 15, 20",
        "Backstage passes to a TAFKAL80ETC concert, 10, 49", "Backstage passes to a TAFKAL80ETC concert, 5, 49",
        "Conjured Mana Cake, 3, 6", "", "-------- day 1 --------", "name, sellIn, quality", "+5 Dexterity Vest, 9, 19",
        "Aged Brie, 1, 1", "Elixir of the Mongoose, 4, 6", "Sulfuras, Hand of Ragnaros, 0, 80",
        "Sulfuras, Hand of Ragnaros, -1, 80", "Backstage passes to a TAFKAL80ETC concert, 14, 21",
        "Backstage passes to a TAFKAL80ETC concert, 9, 50", "Backstage passes to a TAFKAL80ETC concert, 4, 50",
        "Conjured Mana Cake, 2, 5", ""
      ]
      expect(expected_report_lines).to eq(report_lines)
    end

    def expect_product_quality(product:, expected:, sell_in:, quality:)
      items = [Item.new(product, sell_in, quality)]
      GildedRose.new(items).update_quality
      expect(expected).to eq items[0].quality
    end

    context 'when backstage passes' do
      let(:product) { 'Backstage passes to a TAFKAL80ETC concert' }

      context 'when sell in is below 11' do
        it 'increases item quality by 2' do
          expect_product_quality(product: product, expected: 22, sell_in: 8, quality: 20)
        end
      end

      context 'when sell in is below 6' do
        it 'increases item quality by 3' do
          expect_product_quality(product: product, expected: 23, sell_in: 4, quality: 20)
        end
      end
    end

    context 'when aged brie' do
      let(:product) { 'Aged Brie' }

      context 'when sell in date is over' do
        it 'increase item quality by 2' do
          expect_product_quality(product: product, expected: 22, sell_in: 0, quality: 20)
        end
      end
    end
  end
end
