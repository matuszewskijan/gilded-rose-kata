module Inventory
  class Generic
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = quality
      @sell_in = sell_in
    end

    def update
      @quality -= 1 if @quality > 0

      @sell_in = @sell_in - 1

      @quality -= 1 if @sell_in < 0 && @quality > 0
    end
  end

  class AgedBrie
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = quality
      @sell_in = sell_in
    end

    def update
      @quality += 1 if @quality < 50

      @sell_in -= 1

      @quality += 1 if @sell_in < 0 && @quality < 50
    end
  end

  class BackstagePass
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = quality
      @sell_in = sell_in
    end

    def update
      @quality += 1 if @quality < 50

      if @sell_in < 11
        if @quality < 50
          @quality += 1
        end
      end

      if @sell_in < 6
        if @quality < 50
          @quality += 1
        end
      end

      @sell_in -= 1

      @quality = @quality - @quality if @sell_in < 0
    end
  end

  class Sulfuras
    attr_accessor :quality, :sell_in

    def initialize(quality:, sell_in:)
      @quality = quality
      @sell_in = sell_in
    end

    def update; end
  end

  class GoodsCategory
    def build_for(item:)
      case
      when sulfuras?(item)
        Inventory::Sulfuras.new(quality: item.quality, sell_in: item.sell_in)
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
      !(aged_brie?(item) || backstage_pass?(item) || sulfuras?(item))
    end

    def aged_brie?(item)
      item.name == "Aged Brie"
    end

    def backstage_pass?(item)
      item.name == "Backstage passes to a TAFKAL80ETC concert"
    end

    def sulfuras?(item)
      item.name == "Sulfuras, Hand of Ragnaros"
    end
  end
end

class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      good = Inventory::GoodsCategory.new.build_for(item: item)
      good.update
      item.quality = good.quality
      item.sell_in = good.sell_in
    end
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
