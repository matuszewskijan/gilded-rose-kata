class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      if item.generic?
        handle_generic(item)
      elsif item.sulfuras?
      elsif item.aged_brie?
        handle_aged_brie?(item)
      elsif item.backstage_pass?
        handle_backstage_pass(item)
      end
    end
  end

  def handle_generic(item)
    item.decrease_quality if item.quality > 0

    item.sell_in = item.sell_in - 1

    item.decrease_quality if item.sell_in < 0 && item.quality > 0
  end

  def handle_aged_brie?(item)
    item.increase_quality if item.quality_less_than_50?

    item.sell_in = item.sell_in - 1

    item.increase_quality if item.sell_in < 0 && item.quality_less_than_50?
  end

  def handle_backstage_pass(item)
    item.increase_quality if item.quality_less_than_50?

    if item.sell_in < 11
      if item.quality_less_than_50?
        item.increase_quality
      end
    end
    if item.sell_in < 6
      if item.quality_less_than_50?
        item.increase_quality
      end
    end

    item.sell_in = item.sell_in - 1

    item.quality = item.quality - item.quality if item.sell_in < 0
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

  def decrease_quality
    self.quality -= 1
  end

  def increase_quality
    self.quality += 1
  end

  def quality_less_than_50?
    self.quality < 50
  end
end
