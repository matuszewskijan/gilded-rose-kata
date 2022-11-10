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
end

class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      if item.sulfuras?
      elsif item.generic?
        generic = Inventory::Generic.new(quality: item.quality, sell_in: item.sell_in)
        generic.update
        item.quality = generic.quality
        item.sell_in = generic.sell_in
      elsif item.aged_brie?
        aged_brie = Inventory::AgedBrie.new(quality: item.quality, sell_in: item.sell_in)
        aged_brie.update
        item.quality = aged_brie.quality
        item.sell_in = aged_brie.sell_in
      elsif item.backstage_pass?
        aged_brie = Inventory::BackstagePass.new(quality: item.quality, sell_in: item.sell_in)
        aged_brie.update
        item.quality = aged_brie.quality
        item.sell_in = aged_brie.sell_in
      end
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

  def generic?
    !(aged_brie? || backstage_pass? || sulfuras?)
  end

  def aged_brie?
    name == "Aged Brie"
  end

  def backstage_pass?
    name == "Backstage passes to a TAFKAL80ETC concert"
  end

  def sulfuras?
    name == "Sulfuras, Hand of Ragnaros"
  end
end
