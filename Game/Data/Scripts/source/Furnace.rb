class Furnace
  def initialize
    @gold = 0
    @iron = 0
    @mana = 0
    @silver = 0
    @copper = 0
    @mythic = 0
    @mystrile = 0
  end
  :public
  # ------------------------------------------------------------------ #
  # 吞入物品，分解素材
  # param: item = 物品
  # ------------------------------------------------------------------ #
  def drop(item)
    case item
    when RPG::EquipItem then decomposeEquipment(item);
    end
  end
  # ------------------------------------------------------------------ #
  # 生產
  # param: model = 模版
  # ------------------------------------------------------------------ #
  def produce(model)
    return
  end
  # ------------------------------------------------------------------ #
  # 設置環境
  # param: environ = 環境
  # ------------------------------------------------------------------ #
  def adjust(environ)
  end
  :protected
  def decomposeEquipment(item)
    @gold += item.price/10  #價值
    @iron += item.params[2] #最大攻撃力
    @iron += item.params[3] #防御力 
    @mana += item.params[1] #最大MP
    @copper += item.params[6] #敏捷性
    @silver += item.params[7] #運
    @mythic += item.params[5] #魔法防御
    @mythic += item.params[0] #最大HP
    @mystrile += item.params[4] #魔法力 
  end
end