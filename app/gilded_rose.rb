module Inventory
  class Quality
    attr_reader :amount

    def initialize(amount:)
      @amount = amount
    end

    def degrade
      @amount -= 1 if @amount > 0
    end

    def increase
      @amount += 1 if @amount < 50
    end

    def reset
      @amount = 0
    end
  end

  class Generic
    attr_accessor :quality

    def initialize(quality:)
      @quality = Quality.new(amount: quality)
    end

    def update(sell_in:)
      @quality.degrade

      @quality.degrade if sell_in < 0
    end
  end

  class AgedBrie
    attr_accessor :quality

    class Expired
      attr_accessor :quality

      def initialize(quality:)
        @quality = Quality.new(amount: quality)
      end

      def update(sell_in: nil)
        @quality.increase
        @quality.increase
      end
    end

    def initialize(quality:)
      @quality = Quality.new(amount: quality)
    end

    def update(sell_in: nil)
      @quality.increase
    end
  end

  class BackstagePass
    attr_accessor :quality

    def initialize(quality:)
      @quality = Quality.new(amount: quality)
    end

    def update(sell_in:)
      @quality.increase

      @quality.increase if sell_in < 10
      @quality.increase if sell_in < 5

      @quality.reset if sell_in < 0
    end
  end
end

class GildedRose
  class GoodsCategory
    def build_for(item:)
      case
      when generic?(item)
        Inventory::Generic.new(quality: item.quality)
      when aged_brie?(item)
        if item.sell_in.negative?
          Inventory::AgedBrie::Expired.new(quality: item.quality)
        else
          Inventory::AgedBrie.new(quality: item.quality)
        end
      when backstage_pass?(item)
        Inventory::BackstagePass.new(quality: item.quality)
      end
    end

    private

    def generic?(item)
      !(aged_brie?(item) || backstage_pass?(item))
    end

    def aged_brie?(item)
      item.name == "Aged Brie"
    end

    def backstage_pass?(item)
      item.name == "Backstage passes to a TAFKAL80ETC concert"
    end
  end

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      next if sulfuras?(item)

      item.sell_in -= 1
      good = GoodsCategory.new.build_for(item: item)
      good.update(sell_in: item.sell_in)
      item.quality = good.quality.amount
    end
  end

  private

  def sulfuras?(item)
    item.name == "Sulfuras, Hand of Ragnaros"
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
