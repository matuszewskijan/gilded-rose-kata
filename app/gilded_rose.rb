module Inventory
  class Quality
    attr_reader :amount

    def initialize(amount:)
      @amount = amount
    end

    def degrade
      @amount -= 1 if @amount.positive?
    end

    def increase
      @amount += 1 if @amount < 50
    end

    def reset
      @amount = 0
    end
  end

  class Generic
    class Expired
      def update(quality:)
        quality.degrade
        quality.degrade
      end
    end

    def update(quality:)
      quality.degrade
    end
  end

  class Conjured
    class Expired
      def update(quality:)
        quality.degrade
        quality.degrade
        quality.degrade
        quality.degrade
      end
    end

    def update(quality:)
      quality.degrade
      quality.degrade
    end
  end

  class AgedBrie
    class Expired
      def update(quality:)
        quality.increase
        quality.increase
      end
    end

    def update(quality:)
      quality.increase
    end
  end

  class BackstagePass
    class ConcertIn10Days
      def update(quality:)
        quality.increase
        quality.increase
      end
    end

    class ConcertIn5Days
      def update(quality:)
        quality.increase
        quality.increase
        quality.increase
      end
    end

    class Expired
      def update(quality:)
        quality.reset
      end
    end

    def update(quality:)
      quality.increase
    end
  end
end

class GildedRose
  class GoodsCategory
    def build_for(item:)
      case
      when generic?(item)
        if item.sell_in.negative?
          Inventory::Generic::Expired.new
        else
          Inventory::Generic.new
        end
      when aged_brie?(item)
        if item.sell_in.negative?
          Inventory::AgedBrie::Expired.new
        else
          Inventory::AgedBrie.new
        end
      when backstage_pass?(item)
        if item.sell_in.negative?
          Inventory::BackstagePass::Expired.new
        elsif item.sell_in < 5
          Inventory::BackstagePass::ConcertIn5Days.new
        elsif item.sell_in < 10
          Inventory::BackstagePass::ConcertIn10Days.new
        else
          Inventory::BackstagePass.new
        end
      when conjured?(item)
        if item.sell_in.negative?
          Inventory::Conjured::Expired.new
        else
          Inventory::Conjured.new
        end
      end
    end

    private

    def generic?(item)
      !(aged_brie?(item) || backstage_pass?(item) || conjured?(item))
    end

    def aged_brie?(item)
      item.name == 'Aged Brie'
    end

    def backstage_pass?(item)
      item.name == 'Backstage passes to a TAFKAL80ETC concert'
    end

    def conjured?(item)
      item.name == 'Conjured Mana Cake'
    end
  end

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      next if sulfuras?(item)

      item.sell_in -= 1
      quality = Inventory::Quality.new(amount: item.quality)
      good = GoodsCategory.new.build_for(item: item)
      good.update(quality: quality)
      item.quality = quality.amount
    end
  end

  private

  def sulfuras?(item)
    item.name == 'Sulfuras, Hand of Ragnaros'
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
