#encoding:utf-8
#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 　商店画面
#==============================================================================

class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 准备
  #--------------------------------------------------------------------------
  def prepare(goods, purchase_only)
    @goods = goods
    @purchase_only = purchase_only
  end
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_number_window
    create_status_window
    create_buy_window
    create_category_window
    create_sell_window
  end
  #--------------------------------------------------------------------------
  # ● 生成金钱窗口
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ShopCommand.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● 生成填充窗口
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● 生成数值输入窗口
  #--------------------------------------------------------------------------
  def create_number_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @number_window = Window_ShopNumber.new(0, wy, wh)
    @number_window.viewport = @viewport
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    wx = @number_window.width
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_ShopStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 生成买入窗口
  #--------------------------------------------------------------------------
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_ShopBuy.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成分类窗口
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @dummy_window.y
    @category_window.hide.deactivate
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成卖出窗口
  #--------------------------------------------------------------------------
  def create_sell_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @sell_window = Window_ShopSell.new(0, wy, Graphics.width, wh)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
    @category_window.item_window = @sell_window
  end
  #--------------------------------------------------------------------------
  # ● 启用买入窗口
  #--------------------------------------------------------------------------
  def activate_buy_window
    @buy_window.money = money
    @buy_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● 启用卖出窗口
  #--------------------------------------------------------------------------
  def activate_sell_window
    @category_window.show
    @sell_window.refresh
    @sell_window.show.activate
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 指令“买入”
  #--------------------------------------------------------------------------
  def command_buy
    @dummy_window.hide
    activate_buy_window
  end
  #--------------------------------------------------------------------------
  # ● 指令“卖出”
  #--------------------------------------------------------------------------
  def command_sell
    @dummy_window.hide
    @category_window.show.activate
    @sell_window.show
    @sell_window.unselect
    @sell_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 买入“确定”
  #--------------------------------------------------------------------------
  def on_buy_ok
    @item = @buy_window.item
    @buy_window.hide
    @number_window.set(@item, max_buy, buying_price, currency_unit)
    @number_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 买入“取消”
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    @dummy_window.show
    @buy_window.hide
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 分类“确定”
  #--------------------------------------------------------------------------
  def on_category_ok
    activate_sell_window
    @sell_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 分类“取消”
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @dummy_window.show
    @category_window.hide
    @sell_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 卖出“确定”
  #--------------------------------------------------------------------------
  def on_sell_ok
    @item = @sell_window.item
    @status_window.item = @item
    @category_window.hide
    @sell_window.hide
    @number_window.set(@item, max_sell, selling_price, currency_unit)
    @number_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● 卖出“取消”
  #--------------------------------------------------------------------------
  def on_sell_cancel
    @sell_window.unselect
    @category_window.activate
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 数值输入“确定”
  #--------------------------------------------------------------------------
  def on_number_ok
    Sound.play_shop
    case @command_window.current_symbol
    when :buy
      do_buy(@number_window.number)
    when :sell
      do_sell(@number_window.number)
    end
    end_number_input
    @gold_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 数值输入“取消”
  #--------------------------------------------------------------------------
  def on_number_cancel
    Sound.play_cancel
    end_number_input
  end
  #--------------------------------------------------------------------------
  # ● 执行买入
  #--------------------------------------------------------------------------
  def do_buy(number)
    $game_party.lose_gold(number * buying_price)
    $game_party.gain_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # ● 执行卖出
  #--------------------------------------------------------------------------
  def do_sell(number)
    $game_party.gain_gold(number * selling_price)
    $game_party.lose_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # ● 结束数值输入
  #--------------------------------------------------------------------------
  def end_number_input
    @number_window.hide
    case @command_window.current_symbol
    when :buy
      activate_buy_window
    when :sell
      activate_sell_window
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取可以买入的最大值
  #--------------------------------------------------------------------------
  def max_buy
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    buying_price == 0 ? max : [max, money / buying_price].min
  end
  #--------------------------------------------------------------------------
  # ● 获取可以卖出的最大值
  #--------------------------------------------------------------------------
  def max_sell
    $game_party.item_number(@item)
  end
  #--------------------------------------------------------------------------
  # ● 获取持有金钱
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # ● 获取货币单位
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  #--------------------------------------------------------------------------
  # ● 获取买入价格
  #--------------------------------------------------------------------------
  def buying_price
    @buy_window.price(@item)
  end
  #--------------------------------------------------------------------------
  # ● 获取卖出价格
  #--------------------------------------------------------------------------
  def selling_price
    @item.price / 2
  end
end
