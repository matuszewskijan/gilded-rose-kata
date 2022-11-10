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
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = Quality.new(amount: quality)
      @sell_in = sell_in
    end

    def update
      @quality.degrade

      @sell_in = @sell_in - 1

      @quality.degrade if @sell_in < 0
    end
  end

  class AgedBrie
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = Quality.new(amount: quality)
      @sell_in = sell_in
    end

    def update
      @quality.increase

      @sell_in -= 1

      @quality.increase if @sell_in < 0
    end
  end

  class BackstagePass
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = Quality.new(amount: quality)
      @sell_in = sell_in
    end

    def update
      @quality.increase

      @quality.increase if @sell_in < 11
      @quality.increase if @sell_in < 6

      @sell_in -= 1

      @quality.reset if @sell_in < 0
    end
  end
end

class GildedRose
  class GoodsCategory
    def build_for(item:)
      case
      when generic?(item)
        Inventory::Generic.new(quality: item.quality, sell_in: item.sell_in)
      when aged_brie?(item)
        Inventory::AgedBrie.new(quality: item.quality, sell_in: item.sell_in)
      when backstage_pass?(item)
        Inventory::BackstagePass.new(quality: item.quality, sell_in: item.sell_in)
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

      good = GoodsCategory.new.build_for(item: item)
      good.update
      item.quality = good.quality.amount
      item.sell_in = good.sell_in
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
