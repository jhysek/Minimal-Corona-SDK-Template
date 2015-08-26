--------------------------------------------------------------------------------
local widget   = require "widget"
local class    = require "lib.middleclass"
local Color    = require "lib.Color"
local _        = require "lib.underscore"
--------------------------------------------------------------------------------

local GridView = class("GridView")

function GridView:initialize(parent, x, y, width, height, options)
  options = options or {}

  local default_options = {
    padding = 20,
    item_height = 100,
    center = true,
    hideBackground = true
  }
  self.options = _.extend(default_options, options)

  self.items = {}

  self.x, self.y = x, y
  self.width, self.height  = width, height
  self.parent = parent

  self:recount()

  self.scrollView = widget.newScrollView({
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
    horizontalScrollDisabled = self.options.horizontalScrollDisabled,
    verticalScrollDisabled = self.options.verticalScrollDisabled,
  })
  self.displayObject = self.scrollView
  self.parent:insert(self.scrollView)
end

function GridView:recount()
  -- pokud je definovan pocet sloupcu, nastavi sirku sloupce tak, aby to
  -- spolu s paddingem pokryvalo celou sirku gridViewu
  if self.options.columns and not self.options.item_width then
    self.options.horizontalScrollDisabled = true
    self.options.item_width = math.floor((self.width - ((self.options.columns - 1) * self.options.padding)) / self.options.columns)
  end

  -- pokud se definuje sirka a chce se variabilni pocet sloupcu (responzivni grid),
  -- pak je potreba zadat wrap = true - nastavi pocet sloupcu podle sirky gridu
  if self.options.wrap and self.options.item_width then
    self.options.horizontalScrollDisabled = true
    self.options.columns = math.floor((self.width + self.options.padding) / (self.options.item_width + self.options.padding))
  end
end

function GridView:clear()
  self.items = {}
  self:redraw()
end

function GridView:insert(itemGroup)
  self.items[#self.items + 1] = itemGroup
end

function GridView:scrollRelative(offset)
  local ex, ey = self.scrollView:getContentPosition()
  self.scrollView:scrollToPosition({ y = ey + offset })
end

function GridView:redraw()
  display.remove(self.scrollView)
  self.scroscrollView = nil
  self.list_y = 0
  self.scrollView = widget.newScrollView({
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
    horizontalScrollDisabled = self.options.horizontalScrollDisabled,
    verticalScrollDisabled = self.options.verticalScrollDisabled,
    hideBackground = self.options.hideBackground
  })
  self.parent:insert(self.scrollView)
  self.displayObject = self.scrollView

  self:recount()
  local columns = self.options.columns or #self.items

  for i = 1, #self.items do
    local item = self.items[i]

    if item then
      local itemContainer = display.newContainer(self.options.item_width, self.options.item_height)
      itemContainer:insert(item)
      itemContainer.anchorX = 0
      itemContainer.anchorY = 0
      itemContainer.x = math.fmod(i - 1, columns) * self.options.item_width + math.fmod(i - 1, columns) * self.options.padding
      itemContainer.y = math.floor((i - 1) / columns) * (self.options.item_height + self.options.padding)

      if self.options.center then
        itemContainer.x = itemContainer.x + (self.width - (columns * (self.options.item_width + self.options.padding) - self.options.padding)) / 2
      end

      self.scrollView:insert(itemContainer)
    end

  end

  local y = math.floor(#self.items / columns) * (self.options.item_height + self.options.padding)
  local padding = display.newRect(0, y, self.options.item_width, _H / 2)
  padding.anchorX = 0
  padding.anchorY = 0
  self.scrollView:insert(padding)

end

return GridView

